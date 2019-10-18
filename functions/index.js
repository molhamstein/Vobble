const functions = require('firebase-functions');

// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
//
// exports.helloWorld = functions.https.onRequest((request, response) => {
//  response.send("Hello from Firebase!");
// });

// The Firebase Admin SDK to access the Firebase Realtime Database.
const admin = require('firebase-admin');
admin.initializeApp();

// Saves a message to the Firebase Realtime Database but sanitizes the text by removing swearwords.
exports.fetchReplies = functions.https.onCall((data, context) => {

	const id = data.id;
	var ref = admin.database().ref("conversations");

	ref.orderByChild("user2ID").equalTo(id).on('value', function(snapshot) {
		return snapshot;
	});
});