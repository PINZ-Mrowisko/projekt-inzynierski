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
  //console.log('background message received:', payload);

  const data = payload.data || {};

  const notificationTitle = payload.data?.title || 'Mrowisko';
  const notificationOptions = {
    body: payload.data?.body || '',
    icon: '/icons/icon-192x192.png',
    badge: '/icons/icon-72x72.png',
    data: payload.data,
  };

  // zapisujemy typ zdarzenia = zeby moc robic refresh na bg notifs

    self.clients.matchAll({ includeUncontrolled: true }).then(clients => {
      clients.forEach(client => {
        client.postMessage({
          type: 'FCM_EVENT',
          eventType: data.type,
        });
      });
    });

  return self.registration.showNotification(notificationTitle, notificationOptions);
});

// obsługujemy klikniecie w powaidomienie:

self.addEventListener('notificationclick', (event) => {
  event.notification.close();

  const eventType = event.notification.data?.type;

  event.waitUntil(
    self.clients.matchAll({ type: 'window', includeUncontrolled: true })
      .then((clients) => {
        if (clients.length > 0) {
          const client = clients[0];
          client.focus();
          client.postMessage({
            type: 'FCM_CLICK',
            eventType,
          });
          // if app not open then we need to openWidnow()
        } else {
          self.clients.openWindow('/').then((client) => {
            client?.postMessage({
              type: 'FCM_CLICK',
              eventType,
            });
          });
        }
      })
  );
});
