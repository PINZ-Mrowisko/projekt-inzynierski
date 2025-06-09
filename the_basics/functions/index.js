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
//
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

