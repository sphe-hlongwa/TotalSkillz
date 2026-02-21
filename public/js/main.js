/* ============================================
   Total Skillz.inc - Core JavaScript
   ============================================ */

// ---- Theme ----
function getTheme() { return 'dark'; }
function setTheme(theme) {
    document.documentElement.setAttribute('data-theme', 'dark');
    // Hide any residual theme buttons just in case
    document.querySelectorAll('.theme-btn').forEach(btn => btn.style.display = 'none');
}
function toggleTheme() {
    // Disabled
}

// ---- Auth helpers ----
function getUser() {
    const u = localStorage.getItem('mg12_user');
    return u ? JSON.parse(u) : null;
}
function setUser(user) {
    localStorage.setItem('mg12_user', JSON.stringify(user));
}
function logout() {
    localStorage.removeItem('mg12_user');
    window.location.href = 'index.html';
}
function requireAuth() {
    if (!getUser()) { window.location.href = 'index.html'; return false; }
    return true;
}
function getInitials(name) {
    return name.split(' ').map(w => w[0]).join('').toUpperCase().slice(0, 2);
}

// ---- Header scroll ----
function initHeader() {
    const header = document.querySelector('.header');
    if (!header) return;
    window.addEventListener('scroll', () => {
        header.classList.toggle('scrolled', window.scrollY > 8);
    }, { passive: true });

    // Set active nav link
    const page = window.location.pathname.split('/').pop() || 'dashboard.html';
    document.querySelectorAll('.header__nav-link, .mobile-nav__link').forEach(link => {
        const href = link.getAttribute('href');
        if (href === page) link.classList.add('active');
    });

    // User avatar
    const user = getUser();
    document.querySelectorAll('.user-avatar').forEach(el => {
        if (user) el.textContent = getInitials(user.name);
    });
}

// ---- Mobile nav ----
function initMobileNav() {
    const hamburger = document.querySelector('.hamburger');
    const mobileNav = document.querySelector('.mobile-nav');
    if (!hamburger || !mobileNav) return;

    hamburger.addEventListener('click', () => {
        hamburger.classList.toggle('active');
        mobileNav.classList.toggle('open');
        document.body.style.overflow = mobileNav.classList.contains('open') ? 'hidden' : '';
    });
    mobileNav.addEventListener('click', (e) => {
        if (e.target === mobileNav) {
            hamburger.classList.remove('active');
            mobileNav.classList.remove('open');
            document.body.style.overflow = '';
        }
    });
}

// ---- Scroll Reveal ----
function initReveal() {
    const els = document.querySelectorAll('.reveal');
    if (!els.length) return;
    const obs = new IntersectionObserver((entries) => {
        entries.forEach(e => { if (e.isIntersecting) { e.target.classList.add('visible'); obs.unobserve(e.target); } });
    }, { threshold: 0.1 });
    els.forEach(el => obs.observe(el));
}

// ---- Toast ----
function showToast(message, type = 'info') {
    let container = document.querySelector('.toast-container');
    if (!container) {
        container = document.createElement('div');
        container.className = 'toast-container';
        document.body.appendChild(container);
    }
    const icons = { success: 'fa-circle-check', error: 'fa-circle-xmark', info: 'fa-circle-info' };
    const toast = document.createElement('div');
    toast.className = 'toast toast-' + type;
    toast.innerHTML = '<i class="fa-solid ' + (icons[type] || icons.info) + ' toast-icon"></i><span>' + message + '</span>';
    container.appendChild(toast);
    setTimeout(() => { toast.style.opacity = '0'; toast.style.transform = 'translateX(60px)'; toast.style.transition = '0.3s'; setTimeout(() => toast.remove(), 300); }, 3500);
}

// ---- Progress / Tracking ----
function getProgress() {
    const p = localStorage.getItem('mg12_progress');
    return p ? JSON.parse(p) : {
        topics: {
            algebra: { correct: 0, total: 0, level: 0 },
            functions: { correct: 0, total: 0, level: 0 },
            trigonometry: { correct: 0, total: 0, level: 0 },
            calculus: { correct: 0, total: 0, level: 0 },
            geometry: { correct: 0, total: 0, level: 0 },
            probability: { correct: 0, total: 0, level: 0 }
        },
        streak: 0,
        lastPractice: null,
        totalCorrect: 0,
        totalAttempted: 0,
        badges: [],
        dailyDone: false
    };
}
function saveProgress(p) { localStorage.setItem('mg12_progress', JSON.stringify(p)); }

function updateStreak() {
    const p = getProgress();
    const today = new Date().toDateString();
    if (p.lastPractice === today) return p;
    const yesterday = new Date(Date.now() - 86400000).toDateString();
    if (p.lastPractice === yesterday) {
        p.streak++;
    } else if (p.lastPractice !== today) {
        p.streak = 1;
    }
    p.lastPractice = today;
    p.dailyDone = false;
    saveProgress(p);
    return p;
}

function recordAnswer(topic, correct) {
    const p = getProgress();
    if (!p.topics[topic]) return;
    p.topics[topic].total++;
    p.totalAttempted++;
    if (correct) {
        p.topics[topic].correct++;
        p.totalCorrect++;
    }
    // Recalculate level (0-100)
    const t = p.topics[topic];
    t.level = t.total > 0 ? Math.round((t.correct / t.total) * 100) : 0;
    // Check badges
    checkBadges(p);
    saveProgress(p);
    return p;
}

function checkBadges(p) {
    const badges = p.badges;
    if (p.totalCorrect >= 10 && !badges.includes('first10')) { badges.push('first10'); showToast('Badge unlocked: First 10 Correct!', 'success'); }
    if (p.totalCorrect >= 50 && !badges.includes('fifty')) { badges.push('fifty'); showToast('Badge unlocked: 50 Correct Answers!', 'success'); }
    if (p.streak >= 3 && !badges.includes('streak3')) { badges.push('streak3'); showToast('Badge unlocked: 3-Day Streak!', 'success'); }
    if (p.streak >= 7 && !badges.includes('streak7')) { badges.push('streak7'); showToast('Badge unlocked: Weekly Warrior!', 'success'); }
    Object.values(p.topics).forEach((t, i) => {
        const key = 'master_' + Object.keys(p.topics)[i];
        if (t.level >= 80 && t.total >= 5 && !badges.includes(key)) { badges.push(key); showToast('Badge unlocked: ' + Object.keys(p.topics)[i] + ' Master!', 'success'); }
    });
}

function getWeakTopics() {
    const p = getProgress();
    return Object.entries(p.topics)
        .filter(([_, t]) => t.total >= 2 && t.level < 60)
        .sort((a, b) => a[1].level - b[1].level)
        .map(([name, data]) => ({ name, ...data }));
}

// ---- Tabs ----
function initTabs() {
    document.querySelectorAll('.tabs').forEach(tabGroup => {
        tabGroup.querySelectorAll('.tab-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const target = btn.dataset.tab;
                tabGroup.querySelectorAll('.tab-btn').forEach(b => b.classList.remove('active'));
                btn.classList.add('active');
                const container = tabGroup.closest('.tab-container') || tabGroup.parentElement;
                container.querySelectorAll('.tab-panel').forEach(panel => {
                    panel.classList.toggle('active', panel.id === target);
                });
            });
        });
    });
}

// ---- KaTeX Math Rendering ----
function renderMath(el) {
    if (typeof renderMathInElement === 'function') {
        renderMathInElement(el || document.body, {
            delimiters: [
                { left: '$$', right: '$$', display: true },
                { left: '\\(', right: '\\)', display: false },
                { left: '\\[', right: '\\]', display: true }
            ],
            throwOnError: false
        });
    }
}

// ---- Init ----
document.addEventListener('DOMContentLoaded', () => {
    setTheme(getTheme());
    initHeader();
    initMobileNav();
    initReveal();
    initTabs();
    renderMath();
});
