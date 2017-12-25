if (navigator.serviceWorker) {
  navigator.serviceWorker.register('/serviceworker.js', { scope: '/' })
    .then(function(registration) {
      console.log('ServiceWorker registration successful with scope:',  registration.scope);
    });
}
