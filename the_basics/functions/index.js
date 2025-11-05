/* eslint-disable */
/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

// const {onCall} = require("firebase-functions/v2/https");
// const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {onCall} = require("firebase-functions/v2/https");
const functions = require("firebase-functions/v2");
const admin = require("firebase-admin");
const {setGlobalOptions} = require("firebase-functions/v2");
// const {initializeApp} = require("firebase-admin/app");

// const {getAuth} = require("firebase-admin/auth");

// The Firebase Admin SDK to access Firestore.
// const {initializeApp} = require("firebase-admin/app");
// const {getFirestore} = require("firebase-admin/firestore");


admin.initializeApp();
setGlobalOptions({region: "europe-central2"});

exports.createAuthUser = onCall(async (request) => {
  try {
    // DEBUGOWANIE - sprawdź co dociera
//    console.log("=== DEBUG START ===");
//    console.log("request:", request.data);
//    console.log("=== DEBUG END ===");

  const data = request.data;
//  console.log("data.password:", data.password);
//  console.log("data.email:", data.email);
//  console.log("Extracted data:", data);

  const user = await admin.auth().createUser({
      email: data.email,
      emailVerified: false,
      password: data.password,
      displayName: data.email,
      disabled: false,
    });

    // console.log(`User created: ${user.uid} for email: ${data.email}`);

    try {
          await admin.auth().generatePasswordResetLink(data.email);
          // console.log(`Password reset email sent to: ${data.email}`);
        } catch (emailError) {
          console.error("Error sending password reset email:", emailError);
          console.error("Error sending password reset email:", emailError);
          // Możesz zdecydować czy rzucić błąd czy nie
          throw new functions.https.HttpsError(
            "internal",
            "nie udało się wysłać emaila: " + emailError.message,
           );
        }

          return {uid: user.uid, email: user.email};
        } catch (error) {
          console.error("Error creating user:", error);
          throw new functions.https.HttpsError(
            "internal",
            "Failed to create user: " + error.message,
          );
        }
    });

/// SECOND FUNCTION : sending notifs after creating new schedule to all included users

exports.sendScheduleNotification = onCall(async (request) =>
{
  const data = request.data;
  const marketId = data.marketId;
  const scheduleName = data.scheduleName || "Nowy grafik";

  if (!marketId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "marketId is required"
    );
  }

  try {
    const title = "Nowy grafik opublikowany";
    const body = "Kierownik opublikował nowy grafik";

    // Step 1: we fetch all active tokens for all members
    const membersSnapshot = await admin
      .firestore()
      .collection("Markets")
      .doc(marketId)
      .collection("members")
      .get();

    let tokens = [];

    for (const memberDoc of membersSnapshot.docs) {
      const tokensSnapshot = await memberDoc.ref
        .collection("FCMTokens")
        .where("isActive", "==", true)
        .get();

      tokensSnapshot.forEach((t) => tokens.push(t.data().token));
    }

    if (tokens.length === 0)
    {console.log(`No active tokens found for market ${marketId}`);
      return { success: false, message: "No active tokens found" };}

    // Step 2: Create the notif payload
    const payload = {
      notification: {
        title,
        body,
      },
      data: {
        type: "NEW_SCHEDULE",
        marketId,
      },
    };

    // Step 3: send notification
    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: payload.notification,
      data: payload.data,
    });

    console.log(`Notifications sent: ${response.successCount}`);

    // Step 4: clean up invalid tokens
    const invalidTokens = [];
    response.responses.forEach((res, idx) => {
      if (!res.success) {
        const error = res.error;
        if (
          error.code === "messaging/invalid-registration-token" ||
          error.code === "messaging/registration-token-not-registered"
        ) {
          invalidTokens.push(tokens[idx]);
        }
      }
    });

    // and at the end delete invalid tokens from Firestore
    for (const invalidToken of invalidTokens) {
      const memberDocs = await admin
        .firestore()
        .collection("Markets")
        .doc(marketId)
        .collection("members")
        .get();

      for (const memberDoc of memberDocs.docs) {
        const tokenDoc = await memberDoc.ref
          .collection("FCMTokens")
          .doc(invalidToken)
          .get();

        if (tokenDoc.exists) {
          await tokenDoc.ref.delete();
          console.log(`Deleted invalid token: ${invalidToken}`);
        }
      }
    }

    return { success: true, sent: response.successCount };
  } catch (error) {
    console.error("Error sending notifications:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Error sending notifications: " + error.message
    );
  }
});


// third function : notify user when their leave request status changes

exports.sendLeaveStatusNotification = onCall(async (request) => {
  const data = request.data;
  const marketId = data.marketId;
  const userId = data.userId;
  const decision = data.decision;

  if (!marketId || !userId || !decision) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "marketId, userId, and decision are required"
    );
  }

  try {

    const title = "Status prośby o nieobecność";
    const body =
      decision === "accepted"
        ? "Twoja prośba o nieobecność została zaakceptowana"
        : "Twoja prośba o nieobecność została odrzucona";

    const tokensSnapshot = await admin
      .firestore()
      .collection("Markets")
      .doc(marketId)
      .collection("members")
      .doc(userId)
      .collection("FCMTokens")
      .where("isActive", "==", true)
      .get();

    if (tokensSnapshot.empty) {
      console.log(`No active tokens for user ${userId} in market ${marketId}`);
      return { success: false, message: "No active tokens found" };
    }

    const tokens = tokensSnapshot.docs.map((doc) => doc.data().token);

    const payload = {
      notification: {
        title,
        body,
      },
      data: {
        type: "LEAVE_STATUS_CHANGE",
        decision,
        marketId,
        userId,
      },
    };

    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      notification: payload.notification,
      data: payload.data,
    });

    console.log(`Leave status notifications sent: ${response.successCount}`);

    // clean up invalid tokens
    const invalidTokens = [];
    response.responses.forEach((res, idx) => {
      if (!res.success) {
        const error = res.error;
        if (
          error.code === "messaging/invalid-registration-token" ||
          error.code === "messaging/registration-token-not-registered"
        ) {
          invalidTokens.push(tokens[idx]);
        }
      }
    });

    for (const invalidToken of invalidTokens) {
      const tokenDocs = await admin
        .firestore()
        .collection("Markets")
        .doc(marketId)
        .collection("members")
        .doc(userId)
        .collection("FCMTokens")
        .where("token", "==", invalidToken)
        .get();

      for (const doc of tokenDocs.docs) {
        await doc.ref.delete();
        console.log(`Deleted invalid token for user ${userId}: ${invalidToken}`);
      }
    }

    return { success: true, sent: response.successCount };
  } catch (error) {
    console.error("Error sending leave status notification:", error);
    throw new functions.https.HttpsError(
      "internal",
      "Error sending leave status notification: " + error.message
    );
  }
});
