importScripts('https://www.gstatic.com/firebasejs/10.0.0/firebase-app.js');
importScripts('https://www.gstatic.com/firebasejs/10.0.0/firebase-messaging.js');

firebase.initializeApp({
  apiKey: 'AIzaSyB7wZb2tO1-Fs6GbDADUSTs2Qs3w08Hovw',
      appId: '1:406099696497:web:87e25e51afe982cd3574d0',
      messagingSenderId: '406099696497',
      projectId: 'flutterfire-e2e-tests',
      authDomain: 'flutterfire-e2e-tests.firebaseapp.com',
      databaseURL:
          'https://flutterfire-e2e-tests-default-rtdb.europe-west1.firebasedatabase.app',
      storageBucket: 'flutterfire-e2e-tests.appspot.com',
      measurementId: 'G-JN95N1JV2E',
});

const messaging = firebase.messaging();

messaging.onBackgroundMessage((payload) => {
  console.log('Background message received in service worker: ', payload);

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
        return clients.openWindow(urlToOpen);
      }
    })
  );
});