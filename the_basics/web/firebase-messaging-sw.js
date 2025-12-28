// older version here cause 10.00 didnt work
importScripts('https://www.gstatic.com/firebasejs/9.2.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/9.2.0/firebase-messaging-compat.js');

firebase.initializeApp({
    apiKey: 'AIzaSyBiD7cMxRpDauXenVHRZQvq-cVDuWlAdz0',
    appId: '1:166365589002:web:f921b3c676a8fc2f6279f3',
    messagingSenderId: '166365589002',
    projectId: 'p-inz-719da',
    authDomain: 'p-inz-719da.firebaseapp.com',
    storageBucket: 'p-inz-719da.firebasestorage.app',
    measurementId: 'G-ZW7Z0S41QL',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('background message received:', payload);

  const notificationTitle = payload.data?.title || 'Mrowisko';
  const notificationOptions = {
    body: payload.data?.body || '',
    icon: '/icons/icon-192x192.png',
    badge: '/icons/icon-72x72.png',
    data: payload.data,
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

