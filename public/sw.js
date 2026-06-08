// TotalSkillz Service Worker — v5 (Smart Caching)
// Strategy:
//   • Shell assets (HTML, CSS, JS) → Network-first, fallback to cache
//   • Question JSON files → Cache-first (serve instantly from cache, refresh in background)
//   • Firestore/Firebase → Always network (never cached)

const CACHE_NAME = 'totalskillz-v5';
const QUESTION_CACHE = 'totalskillz-questions-v1';

// Core shell assets — cached on install
const SHELL_ASSETS = [
    '/',
    '/index.html',
    '/dashboard.html',
    '/practice.html',
    '/topics.html',
    '/interactive.html',
    '/examiner.html',
    '/vault.html',
    '/formula.html',
    '/exam.html',
    '/css/style.css',
    '/css/dashboard.css',
    '/css/practice.css',
    '/css/topics.css',
    '/css/settings.css',
    '/css/examiner.css',
    '/js/main.js',
    '/js/firebase-config.js',
    '/js/examiner-data.js',
    '/js/masterclass-data.js',
    '/logo.jpg'
];

// ---- Install: Pre-cache shell assets ----
self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            console.log('[SW] Pre-caching shell assets');
            return cache.addAll(SHELL_ASSETS);
        })
    );
    self.skipWaiting();
});

// ---- Activate: Clean up old caches ----
self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((keys) => {
            return Promise.all(
                keys
                    .filter((key) => key !== CACHE_NAME && key !== QUESTION_CACHE)
                    .map((key) => {
                        console.log('[SW] Deleting old cache:', key);
                        return caches.delete(key);
                    })
            );
        })
    );
    self.clients.claim();
});

// ---- Fetch: Smart routing ----
self.addEventListener('fetch', (event) => {
    const url = event.request.url;

    // Never intercept Firebase/Firestore/Auth network calls
    if (
        url.includes('firestore.googleapis.com') ||
        url.includes('firebase') ||
        url.includes('googleapis.com') ||
        url.includes('gstatic.com') ||
        url.includes('youtube') ||
        event.request.method !== 'GET'
    ) {
        return; // Let browser handle normally
    }

    // Question JSON files → Cache-First with background refresh (Stale-While-Revalidate)
    if (url.includes('/js/questions/')) {
        event.respondWith(staleWhileRevalidate(event.request, QUESTION_CACHE));
        return;
    }

    // Shell assets → Network-first, fallback to cache
    event.respondWith(networkFirstWithFallback(event.request));
});

// Strategy: Stale-While-Revalidate
// Returns cached version immediately (fast), then fetches fresh copy in background
async function staleWhileRevalidate(request, cacheName) {
    const cache = await caches.open(cacheName);
    const cached = await cache.match(request);

    // Fetch fresh in background regardless
    const fetchPromise = fetch(request)
        .then((response) => {
            if (response && response.ok) {
                cache.put(request, response.clone());
            }
            return response;
        })
        .catch(() => null);

    // Serve cached immediately if available, otherwise wait for network
    return cached || fetchPromise;
}

// Strategy: Network-first with cache fallback
async function networkFirstWithFallback(request) {
    try {
        const response = await fetch(request);
        if (response && response.ok) {
            const cache = await caches.open(CACHE_NAME);
            cache.put(request, response.clone());
        }
        return response;
    } catch {
        // Network failed — serve from cache
        const cached = await caches.match(request, { ignoreSearch: true });
        if (cached) return cached;

        // Navigation fallback
        if (request.mode === 'navigate') {
            return caches.match('/dashboard.html');
        }

        return new Response('Network error', { status: 503 });
    }
}
