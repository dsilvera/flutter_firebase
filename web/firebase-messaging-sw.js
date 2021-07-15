
importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-app.js");
importScripts("https://www.gstatic.com/firebasejs/8.6.1/firebase-messaging.js");

firebase.initializeApp({
    apiKey: "AIzaSyAMYeqrgrqgwKu4kwwIp6BdtE",
    authDomain: "flutterqgqgr95.firebaseapp.com",
    projectId: "flutterfireqgfqdfg95",
    storageBucket: "flutterfireqgdqfgqdfg95.appspot.com",
    messagingSenderId: "39qrgqdgqerg0",
    appId: "1:39qgdsgf5230:web:gqdrgf476605ef"
});
// Necessary to receive background messages:
const messaging = firebase.messaging();

// Optional:
messaging.onBackgroundMessage((m) => {
  console.log("onBackgroundMessage", m);
});