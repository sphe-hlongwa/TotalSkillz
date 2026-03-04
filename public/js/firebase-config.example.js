// Firebase Configuration Template
// 1. Copy this file and rename it to 'firebase-config.js'
// 2. Insert your credentials from the Firebase Console (Project Settings > General > Your Apps)

const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_AUTH_DOMAIN",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_STORAGE_BUCKET",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    appId: "YOUR_APP_ID"
};

// Initialize Firebase
if (typeof firebase !== 'undefined') {
    firebase.initializeApp(firebaseConfig);
    window.totalskillz_auth = firebase.auth();
    window.totalskillz_db = firebase.firestore();
}
