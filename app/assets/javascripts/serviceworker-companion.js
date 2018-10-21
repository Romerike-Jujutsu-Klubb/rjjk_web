if (navigator.serviceWorker) {
  navigator.serviceWorker.register('/serviceworker.js', { scope: '/' })
    .then(function(registration) {
      console.log('[Companion]', 'ServiceWorker registration successful with scope:',  registration.scope);
    });
}
