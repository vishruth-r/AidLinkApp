importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js");

firebase.initializeApp({
    apiKey: "AIzaSyDEQ1bH-4hs4EgtT6LrEe68tRvCNcC7sU0",
    appId: "1:594393011949:web:21595670cec2ca198adee4",
    messagingSenderId: "594393011949",
    projectId: "resq-14587",
    authDomain: "resq-14587.firebaseapp.com",
    storageBucket: "resq-14587.appspot.com",
    measurementId: "G-8VCN0XJ909"
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});