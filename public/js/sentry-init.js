// Sentry Browser Initialization
// This script dynamically loads the Sentry Browser SDK using your specific project key.

(function() {
    const script = document.createElement('script');
    script.src = 'https://js.sentry-cdn.com/d356cce2c490ef9d5200916ac003f331.min.js';
    script.crossOrigin = 'anonymous';
    
    // Sentry onLoad callback (optional, but good for custom configuration if needed later)
    Sentry = window.Sentry || {};
    Sentry.onLoad = function() {
        console.log("Sentry Web SDK loaded successfully!");
        Sentry.init({
            dsn: "https://d356cce2c490ef9d5200916ac003f331@o4511536084484096.ingest.us.sentry.io/4511536189931520",
            tracesSampleRate: 1.0,
            replaysSessionSampleRate: 0.1,
            replaysOnErrorSampleRate: 1.0,
        });
    };
    
    document.head.appendChild(script);
})();
