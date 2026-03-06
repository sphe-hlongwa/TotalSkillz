const CACHE_NAME = 'totalskillz-v4';
const ASSETS_TO_CACHE = [
    '/',
    '/index.html',
    '/dashboard.html',
    '/practice.html',
    '/topics.html',
    '/interactive.html',
    '/examiner.html',
    '/css/style.css',
    '/css/dashboard.css',
    '/css/practice.css',
    '/css/topics.css',
    '/css/settings.css',
    '/css/examiner.css',
    '/js/main.js',
    '/js/firebase-config.js',
    '/js/examiner-data.js',
    '/logo.jpg'
];

// Install Event
self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            console.log('Caching assets');
            return cache.addAll(ASSETS_TO_CACHE);
        })
    );
    self.skipWaiting();
});

// Activate Event
self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((keys) => {
            return Promise.all(
                keys.filter((key) => key !== CACHE_NAME).map((key) => caches.delete(key))
            );
        })
    );
    self.clients.claim();
});

// Fetch Event
self.addEventListener('fetch', (event) => {
    // Only handle GET requests and internal URLs
    if (event.request.method !== 'GET' || !event.request.url.startsWith(self.location.origin)) {
        return;
    }

    event.respondWith(
        fetch(event.request)
            .then((response) => {
                // If network works, return it
                return response;
            })
            .catch(() => {
                // If network fails (offline), try cache
                return caches.match(event.request, { ignoreSearch: true })
                    .then((cachedResponse) => {
                        if (cachedResponse) {
                            return cachedResponse;
                        }

                        // Fallback for navigation (if specifically /dashboard fails offline)
                        if (event.request.mode === 'navigate') {
                            return caches.match('/dashboard.html');
                        }

                        // Last resort: fail the request
                        return Promise.reject('no-match');
                    });
            })
    );
});
