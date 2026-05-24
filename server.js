const express = require('express');
const path = require('path');
const helmet = require('helmet');
const rateLimit = require('express-rate-limit');

const app = express();
const { generateAllQuestions } = require('./generate_questions');
const PORT = process.env.PORT || 3000;

// ---- VALID TOPICS WHITELIST ----
const VALID_TOPICS = new Set([
    'all', 'algebra', 'patterns', 'functions', 'calculus',
    'finance', 'probability', 'trigonometry', 'geometry'
]);

// Body parsing middleware with size limit to prevent payload attacks
app.use(express.json({ limit: '1kb' }));

// Security: Helmet helps secure Express apps by setting various HTTP headers
app.use(helmet({
    contentSecurityPolicy: {
        directives: {
            ...helmet.contentSecurityPolicy.getDefaultDirectives(),
            "script-src": [
                "'self'",
                "'unsafe-inline'",
                "'unsafe-eval'",
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
                "https://totalskillz-3bc18.web.app",
                "http://localhost:8000"
            ],
            "frame-src": [
                "'self'",
                "https://*.firebaseapp.com",
                "https://www.google.com/recaptcha/",
                "https://totalskillz.firebaseapp.com",
                "https://totalskillz-3bc18.firebaseapp.com"
            ],
            "img-src": [
                "'self'",
                "data:",
                "blob:",
                "https://*.googleusercontent.com",
                "https://www.gstatic.com",
                "https://*.googleapis.com"
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
app.use(express.static(path.join(__dirname, 'public')));


// Explicit route for the homepage
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

// Administrative API: Generate New Questions (with stricter rate limit + input validation)
app.post('/api/admin/generate-questions', adminLimiter, (req, res) => {
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
                message: `Invalid topic "${topic}". Allowed: ${[...VALID_TOPICS].join(', ')}`
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
        console.error('Error during question generation:', error);
        res.status(500).json({
            success: false,
            message: 'Failed to generate questions. Check server logs.',
            error: error.message
        });
    }
});

app.listen(PORT, () => {
    console.log(`Server is running at http://localhost:${PORT}`);
    console.log('Press Ctrl+C to stop the server.');
});
