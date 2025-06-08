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
const functions = require("firebase-functions");
const admin = require("firebase-admin");
const {setGlobalOptions} = require("firebase-functions/v2");
// const {getAuth} = require("firebase-admin/auth");

// The Firebase Admin SDK to access Firestore.
// const {initializeApp} = require("firebase-admin/app");
// const {getFirestore} = require("firebase-admin/firestore");


admin.initializeApp();
setGlobalOptions({region: "europe-central2"});

// exports.createUser = onDocumentCreated(
//    "/Markets/{marketId}/members/{id}", async (event) => {
//      // Grab the text parameter.
//      const original = "oto dowow dodania";
//      // Push the new message into Firestore using the Firebase Admin SDK.
//      await getFirestore()
//          .collection("messages")
//          .add({original: original});
//      // Send back a message that we've successfully written the message
//    });

exports.createAuthUser = functions.https.onCall(async (data, context) => {
  try {
  const user = await admin.auth().createUser({
      email: data.email,
      emailVerified: true,
      password: data.password,
      displayName: data.email,
      disabled: false,
    });

          return {uid: user.uid, email: user.email};
        } catch (error) {
          console.error("Error creating user:", error);
          throw new functions.https.HttpsError(
            "internal",
            "Failed to create user: " + error.message,
          );
        }
    });

