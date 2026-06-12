const firebaseConfig = {
    apiKey: "AIzaSyC2FW6zzT4zZJj__KY1OozMk0bIRqS8wN4",
    authDomain: "totalskillz-7193a.firebaseapp.com",
    databaseURL: "https://totalskillz-7193a-default-rtdb.firebaseio.com",
    projectId: "totalskillz-7193a",
    storageBucket: "totalskillz-7193a.firebasestorage.app",
    messagingSenderId: "991145221732",
    appId: "1:991145221732:web:2d684b3b66afba56570971"
};

// Initialize Firebase using the Compat SDK
if (typeof firebase !== 'undefined') {
    firebase.initializeApp(firebaseConfig);
    window.totalskillz_auth = firebase.auth();
    window.totalskillz_db = firebase.firestore();
}
