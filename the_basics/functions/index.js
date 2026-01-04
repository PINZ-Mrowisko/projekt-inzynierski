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
const { onDocumentCreated } = require("firebase-functions/v2/firestore");
const { getFirestore } = require("firebase-admin/firestore");
// const {initializeApp} = require("firebase-admin/app");

// const {getAuth} = require("firebase-admin/auth");

// The Firebase Admin SDK to access Firestore.
// const {initializeApp} = require("firebase-admin/app");
// const {getFirestore} = require("firebase-admin/firestore");


admin.initializeApp();
setGlobalOptions({region: "europe-central2"});

exports.createAuthUser = onCall(async (request) => {
  try {
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
/// now modified to actually include all the members and schedules

exports.sendScheduleNotification = onCall(async (request) => {
  const { marketId, scheduleId } = request.data;

  if (!marketId || !scheduleId) {
    throw new functions.https.HttpsError(
      "invalid-argument",
      "marketId and scheduleId are required!!!!!"
    );
  }

  try {
    // 1 grab specified schedule
    const scheduleSnap = await admin
      .firestore()
      .collection("Markets")
      .doc(marketId)
      .collection("Schedules")
      .doc(scheduleId)
      .get();

    if (!scheduleSnap.exists) {
      throw new functions.https.HttpsError("not-found", "Schedule not found");
    }

    const scheduleData = scheduleSnap.data();
    const generatedSchedule = scheduleData.generated_schedule;

    if (!generatedSchedule) {
      return { success: false, message: "No generated_schedule found" };
    }

    // get emps ids into a set
    const employeeIds = new Set();

    Object.values(generatedSchedule).forEach((dayShifts) => {
      if (!Array.isArray(dayShifts)) return;

      dayShifts.forEach((shift) => {
        const assignments = shift.assignments || [];
        assignments.forEach((a) => {
          if (a.workerId) employeeIds.add(a.workerId);
        });
      });
    });

    if (employeeIds.size === 0) {
      return { success: false, message: "No employees in schedule" };
    }

    // 3 get their tokens
    const tokens = [];
    const tokenRefs = [];

    for (const employeeId of employeeIds) {
      const memberRef = admin
        .firestore()
        .collection("Markets")
        .doc(marketId)
        .collection("members")
        .doc(employeeId);

      const memberSnap = await memberRef.get();
      if (!memberSnap.exists) continue;

      if (memberSnap.data().scheduleNotifs !== true) continue;

      const tokensSnap = await memberRef
        .collection("FCMTokens")
        .where("isActive", "==", true)
        .get();

      tokensSnap.forEach((doc) => {
        tokens.push(doc.data().token);
        tokenRefs.push(doc.ref);
      });
    }

    if (tokens.length === 0) {
      return { success: false, message: "No active tokens for members !!!" };
    }

    // 4 and send the notif
    const payload = {
      data: {
        title: "Nowy grafik",
        body: "Został opublikowany nowy grafik, w którym uczestniczysz",
        type: "NEW_SCHEDULE",
        marketId,
        scheduleId,
      },
    };

    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      data: payload.data,
    });

    return {
      success: true,
      sent: response.successCount,
      failed: response.failureCount,
    };

  } catch (error) {
    console.error("sendScheduleNotification error:", error);
    throw new functions.https.HttpsError(
      "internal",
      error.message || "Failed to send notifications"
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

        // check if user allows notifs
         const userDoc = await admin
              .firestore()
              .collection("Markets")
              .doc(marketId)
              .collection("members")
              .doc(userId)
              .get();

                      if (!userDoc.exists) {
                        console.log("no user data to be found:x", managerId);
                        return { success: false, message: "Notifications disabled" };
                      }

                  const userData = userDoc.data();

                  if (!userData.leaveNotifs) {
                         console.log(
                           `user has notifs disabled !!!`
                         );
                         return { success: false, message: "Notifications disabled" };
                       }


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
      data: {
        type: "LEAVE_STATUS_CHANGE",
        title: title,
        body: body,
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

// this will trigger automatically when user creates a new leave, manager will get notifed
exports.notifyNewLeaveRequest = onDocumentCreated(
  "Markets/{marketId}/LeaveReq/{leaveId}",
  async (event) => {
    const snap = event.data;
    if (!snap) return;

    const newLeave = snap.data();
    const marketId = event.params.marketId;
    const managerId = newLeave.managerId;

    if (!managerId) {
      console.log("No managerId found in leave request.");
      return;
    }

    // we will load the manager to see if they allow notifs

    const managerDoc = await admin
          .firestore()
          .collection("Markets")
          .doc(marketId)
          .collection("members")
          .doc(managerId)
          .get();

        if (!managerDoc.exists) {
          console.log("Manager doc not found:", managerId);
          return;
        }

    const managerData = managerDoc.data();

    if (!managerData.leaveNotifs) {
           console.log(
             `manager ${managerId} has leave notifications disabled !!!`
           );
           return;
         }


    // Fetch manager tokens
    const tokensSnapshot = await admin
      .firestore()
      .collection("Markets")
      .doc(marketId)
      .collection("members")
      .doc(managerId)
      .collection("FCMTokens")
      .where("isActive", "==", true)
      .get();

    const tokens = tokensSnapshot.docs.map((doc) => doc.data().token);
    if (tokens.length === 0) {
      console.log(`No active tokens for manager ${managerId}`);
      return;
    }

// modiffyied data !!
    const payload = {
      data: {
        type: "NEW_LEAVE_REQUEST",
        title: "Nowa prośba o nieobecność",
        body: "Jeden z pracowników wysłał nową prośbę o nieobecność.",
        marketId,
        leaveId: event.params.leaveId,
      },
    };

    // remove notif from here
    const response = await admin.messaging().sendEachForMulticast({
      tokens,
      data: payload.data,
    });

    console.log(`Leave request notification sent: ${response.successCount}`);
  }
);
