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

  const notificationTitle = payload.notification?.title || 'Mrowisko';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/icon-192x192.png',
    badge: '/icons/icon-72x72.png',
    data: payload.data || {},
    tag: `bg-notif-${Date.now()}`,
    requireInteraction: false
  };

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

self.addEventListener('install', (event) => {
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  return self.clients.claim();
});

self.addEventListener('push', (event) => {
  if (!event.data) return;

  try {
    const data = event.data.json();
    if (data && data['firebase-messaging-msg-type']) {
      return;
    }
  } catch (e) {

  }
});

// notification click handler - need changes here later
self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  const urlToOpen = self.location.origin;

  event.waitUntil(
    clients.matchAll({
      type: 'window',
      includeUncontrolled: true
    }).then((windowClients) => {
      for (const client of windowClients) {
        if (client.url === urlToOpen && 'focus' in client) {
          return client.focus();
        }
      }
      if (clients.openWindow) {
        return clients.openWindow('/');
      }
    })
  );
});