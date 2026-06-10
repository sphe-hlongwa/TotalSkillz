require("./instrument.js");

const express = require('express');
const path = require('path');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');
const crypto = require('crypto'); // built-in Node module — no install needed

const Sentry = require('@sentry/node');

const app = express();

const { generateAllQuestions } = require('../scripts/generate_questions');
const PORT = process.env.PORT || 3000;

// ---- VALID TOPICS WHITELIST ----
const VALID_TOPICS = new Set([
    'all', 'algebra', 'patterns', 'functions', 'calculus',
    'finance', 'probability', 'trigonometry', 'geometry'
]);

// ---- ADMIN SECRET ----
// Set ADMIN_SECRET in your environment (e.g. in a .env file or shell export).
// Example: ADMIN_SECRET=change-me-to-a-long-random-string
// The client must send: X-Admin-Secret: <value> with every admin API request.
const ADMIN_SECRET = process.env.ADMIN_SECRET || '';

/**
 * Middleware: verify the shared admin secret using a timing-safe comparison.
 * Returns 401 when the header is missing, 403 when it does not match.
 */
function requireAdminSecret(req, res, next) {
    const provided = req.headers['x-admin-secret'] || '';

    // Reject immediately if no secret is configured server-side (misconfiguration guard)
    if (!ADMIN_SECRET) {
        console.error('ADMIN_SECRET env var is not set — admin endpoint is disabled.');
        return res.status(503).json({ success: false, message: 'Admin endpoint not configured.' });
    }

    // Reject if the caller supplied no token
    if (!provided) {
        return res.status(401).json({ success: false, message: 'Unauthorized.' });
    }

    // Timing-safe comparison prevents secret-length leakage
    const secretBuf   = Buffer.from(ADMIN_SECRET);
    const providedBuf = Buffer.alloc(secretBuf.length);
    Buffer.from(provided).copy(providedBuf);

    if (!crypto.timingSafeEqual(secretBuf, providedBuf)) {
        return res.status(403).json({ success: false, message: 'Forbidden.' });
    }

    next();
}

// Body parsing middleware with size limit to prevent payload attacks
app.use(express.json({ limit: '1kb' }));

// Security: Helmet helps secure Express apps by setting various HTTP headers
app.use(helmet({
    contentSecurityPolicy: {
        directives: {
            ...helmet.contentSecurityPolicy.getDefaultDirectives(),
            "script-src": [
                "'self'",
                // TODO: Remove 'unsafe-inline' once all inline handlers are migrated
                "'unsafe-inline'",
                // 'unsafe-eval' intentionally omitted — nothing requires eval()
                "https://www.gstatic.com",
                "https://apis.google.com",
                "https://cdn.jsdelivr.net",
                "https://cdnjs.cloudflare.com",
                "https://unpkg.com",
                "https://www.google.com/recaptcha/",
                "https://www.gstatic.com/recaptcha/"
            ],
            "style-src": [
                "'self'",
                "'unsafe-inline'",
                "https://fonts.googleapis.com",
                "https://cdn.jsdelivr.net",
                "https://cdnjs.cloudflare.com"
            ],
            "font-src": [
                "'self'",
                "https://fonts.gstatic.com",
                "https://cdnjs.cloudflare.com",
                "https://cdn.jsdelivr.net"
            ],
            "connect-src": [
                "'self'",
                "https://*.googleapis.com",
                "https://*.firebaseio.com",
                "https://*.firebaseapp.com",
                "https://totalskillz.web.app",
                "https://totalskillz-7193a.web.app",
                "http://localhost:8000",
                "https://api.cloudinary.com",
                "https://www.gstatic.com"
            ],
            "frame-src": [
                "'self'",
                "https://*.firebaseapp.com",
                "https://www.google.com/recaptcha/",
                "https://totalskillz.firebaseapp.com",
                "https://totalskillz-7193a.firebaseapp.com"
            ],
            "img-src": [
                "'self'",
                "data:",
                "blob:",
                "https://*.googleusercontent.com",
                "https://www.gstatic.com",
                "https://*.googleapis.com",
                "https://res.cloudinary.com"
            ],
        },
    },
}));

// Security: Global rate limiting (100 req / 15 min per IP)
const globalLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 100,
    standardHeaders: true,
    legacyHeaders: false,
    message: { success: false, message: 'Too many requests from this IP, please try again after 15 minutes.' },
});
app.use(globalLimiter);

// Security: Stricter rate limit for admin API endpoints (5 req / 1 min per IP)
const adminLimiter = rateLimit({
    windowMs: 1 * 60 * 1000,
    max: 5,
    standardHeaders: true,
    legacyHeaders: false,
    message: { success: false, message: 'Admin API rate limit exceeded. Try again in 1 minute.' },
});

// Serve static files from the "public" directory
app.use(express.static(path.join(__dirname, '../public')));


// Explicit route for the homepage
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, '../public', 'index.html'));
});

// Administrative API: Generate New Questions
// Protected by: rate limiting (5/min), shared admin secret, topic whitelist.
app.post('/api/admin/generate-questions', adminLimiter, requireAdminSecret, (req, res) => {
    try {
        // Sanitize & validate input
        let { topic } = req.body;

        // Default to 'all' if not provided
        if (topic === undefined || topic === null || topic === '') {
            topic = 'all';
        }

        // Must be a string
        if (typeof topic !== 'string') {
            return res.status(400).json({
                success: false,
                message: 'Invalid input: topic must be a string.'
            });
        }

        // Strip to alphanumeric/underscore, lowercase
        topic = topic.toLowerCase().replace(/[^a-z_]/g, '');

        // Whitelist check
        if (!VALID_TOPICS.has(topic)) {
            return res.status(400).json({
                success: false,
                message: `Invalid topic. Allowed: ${[...VALID_TOPICS].join(', ')}`
            });
        }

        console.log(`Admin requested question generation for topic: ${topic}`);
        const result = generateAllQuestions({ topic });

        res.json({
            success: true,
            message: `Successfully generated ${result.newCount} new questions.`,
            newCount: result.newCount,
            totalCount: result.totalCount
        });
    } catch (error) {
        // Log full error server-side; return only a generic message to callers.
        console.error('Error during question generation:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to generate questions. Check server logs.'
        });
    }
});

// The error handler must be before any other error middleware and after all controllers
Sentry.setupExpressErrorHandler(app);

app.listen(PORT, () => {
    console.log(`Server is running at http://localhost:${PORT}`);
    console.log('Press Ctrl+C to stop the server.');
});

