/* ============================================
   Total Skill - Core JavaScript
   ============================================ */

// 2. Hardcoded localhost + mixed content - Configure base URL per environment
const API_BASE = window.APP_CONFIG?.apiBase ?? '';

// ---- Theme ----
function getTheme() {
    return localStorage.getItem('totalskillz_theme') || 'light';
}
function setTheme(theme) {
    const isAuthPage = window.location.pathname.endsWith('index.html') || window.location.pathname === '/' || window.location.pathname.includes('index.html');
    if (isAuthPage) {
        document.body.setAttribute('data-theme', 'dark');
    } else {
        document.body.setAttribute('data-theme', theme);
    }
    localStorage.setItem('totalskillz_theme', theme);
    updateThemeToggleIcon(theme);
}

function updateThemeToggleIcon(theme) {
    const btns = document.querySelectorAll('.modal-theme-toggle');
    btns.forEach(btn => {
        const icon = btn.querySelector('i');
        if (icon) icon.className = theme === 'dark' ? 'fa-solid fa-sun' : 'fa-solid fa-moon';
    });
}
function toggleTheme() {
    const current = getTheme();
    const next = current === 'dark' ? 'light' : 'dark';
    setTheme(next);

    // Keep progress object in sync (for cloud/offline persistence)
    try {
        const p = getProgress();
        if (!p.settings) p.settings = {};
        p.settings.theme = next;
        saveProgress(p);
    } catch (e) { console.warn("Failed to save theme to progress", e); }
}

// ---- Auth helpers ----
function getUser() {
    // Firebase manages user state globally via auth.currentUser
    const user = window.totalskillz_auth ? window.totalskillz_auth.currentUser : null;
    if (user) {
        return { name: user.displayName || 'User', email: user.email, uid: user.uid };
    }
    // Fallback to legacy check during migration
    const u = localStorage.getItem('totalskillz_user');
    return u ? JSON.parse(u) : null;
}
function setUser(user) {
    // This is now handled by Firebase Auth state changes
    if (user) localStorage.setItem('totalskillz_user', JSON.stringify(user));
    else localStorage.removeItem('totalskillz_user');
}
function logout() {
    if (window.totalskillz_auth) {
        window.totalskillz_auth.signOut().then(() => {
            localStorage.removeItem('totalskillz_user');
            localStorage.removeItem('totalskillz_progress'); // Clear legacy progress on sign out
            window.location.href = 'index.html';
        });
    } else {
        localStorage.removeItem('totalskillz_user');
        localStorage.removeItem('totalskillz_progress');
        window.location.href = 'index.html';
    }
}
function requireAuth() {
    // We'll primarily use the onAuthStateChanged listener for redirects
    if (!getUser()) {
        // Small delay to allow Firebase to initialize
        setTimeout(() => {
            if (!getUser()) window.location.href = 'index.html';
        }, 1000);
        return false;
    }
    return true;
}
// ---- Security Helpers ----
function sanitizeHTML(str) {
    const div = document.createElement('div');
    div.textContent = str;
    return div.innerHTML;
}

function sanitizeText(str) {
    return str.replace(/[&<>"']/g, (m) => ({
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#39;'
    }[m]));
}

function getInitials(name) {
    if (!name) return '??';
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

    initBottomNav();

    // Register Service Worker for Offline Mode
    if ('serviceWorker' in navigator) {
        window.addEventListener('load', () => {
            navigator.serviceWorker.register('/sw.js')
                .then(reg => console.log('SW Registered', reg))
                .catch(err => {
                    console.warn('SW Registration Failed', err);
                    if (typeof showToast === 'function') {
                        showToast('Offline mode disabled (storage access blocked)', 'info');
                    }
                });
        });
    }
}

// ---- Bottom Nav ----
function initBottomNav() {
    if (document.getElementById('bottomNav')) return;

    const nav = document.createElement('nav');
    nav.className = 'bottom-nav';
    nav.id = 'bottomNav';

    const page = window.location.pathname.split('/').pop() || 'dashboard.html';

    const navItems = [
        { id: 'practice', icon: 'fa-solid fa-dumbbell', label: 'Practice', href: 'practice.html' },
        { id: 'topics', icon: 'fa-solid fa-book-open', label: 'Topics', href: 'topics.html' },
        { id: 'exam', icon: 'fa-solid fa-stopwatch', label: 'Exam Mode', href: 'exam.html' },
        { id: 'manage', icon: 'fa-solid fa-gear', label: 'Manage', action: 'toggleSettingsOverlay()' }
    ];

    nav.innerHTML = navItems.map(item => {
        const isActive = item.href === page;
        const attr = item.action ? `onclick="${item.action}"` : `href="${item.href}"`;
        const tag = item.action ? 'button' : 'a';

        return `
            <${tag} ${attr} class="bottom-nav__item ${isActive ? 'active' : ''}">
                <div class="bottom-nav__icon-wrap">
                    <i class="${item.icon}"></i>
                </div>
                <span class="bottom-nav__label">${item.label}</span>
            </${tag}>
        `;
    }).join('');

    document.body.appendChild(nav);
}

// ---- UI Animations ----
function animateCounter(el, target, duration = 1500) {
    if (!el) return;
    let start = 0;
    const isPercentage = typeof target === 'string' && target.includes('%');
    const targetValue = isPercentage ? parseInt(target) : parseInt(target);
    const startTime = performance.now();

    function update(currentTime) {
        const elapsed = currentTime - startTime;
        const progress = Math.min(elapsed / duration, 1);
        const ease = 1 - Math.pow(1 - progress, 3); // easeOutCubic
        const current = Math.floor(ease * targetValue);

        el.textContent = isPercentage ? current + '%' : current;

        if (progress < 1) {
            requestAnimationFrame(update);
        } else {
            el.textContent = target; // Ensure exact final value
        }
    }
    requestAnimationFrame(update);
}

function updateProgressRing(id, percent) {
    const ring = document.getElementById(id);
    if (!ring) return;
    const p = Math.min(Math.max(percent, 0), 100);
    // Stroke-dasharray for svg circle (circumference 100)
    ring.style.strokeDasharray = `${p}, 100`;
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

// ---- Utility: Question Hashing ----
function getQuestionHash(qText) {
    let hash = 0;
    for (let i = 0; i < qText.length; i++) {
        const char = qText.charCodeAt(i);
        hash = ((hash << 5) - hash) + char;
        hash = hash & hash; // Convert to 32bit integer
    }
    return 'q_' + Math.abs(hash).toString(36);
}

// ---- Progress / Tracking ----
function getInitialProgress() {
    return {
        topics: {
            algebra: { correct: 0, total: 0, level: 0 },
            patterns: { correct: 0, total: 0, level: 0 },
            functions: { correct: 0, total: 0, level: 0 },
            finance: { correct: 0, total: 0, level: 0 },
            trigonometry: { correct: 0, total: 0, level: 0 },
            analytical_geometry: { correct: 0, total: 0, level: 0 },
            euclidean_geometry: { correct: 0, total: 0, level: 0 },
            calculus: { correct: 0, total: 0, level: 0 },
            probability: { correct: 0, total: 0, level: 0 },
            statistics: { correct: 0, total: 0, level: 0 }
        },
        streak: 0,
        lastPractice: null,
        totalCorrect: 0,
        totalAttempted: 0,
        badges: [],
        lastDailyDate: null,
        bio: '',
        province: '',
        school: '',
        missedQuestions: [], // legacy support
        mistakeVault: [],    // [{ id, topic, qText, streak, lastSeen }]
        settings: {
            theme: 'light',
            dailyGoal: 10,
            publicProfile: true,
            weakAreas: [],
            examDate: null,
            reminders: false,
            targetMark: 80,
            weeklyHours: 5
        }
    };
}

function getProgress(uid) {
    // If no UID is provided, try to get it from current session
    if (!uid) {
        const user = firebase.auth().currentUser;
        if (user) uid = user.uid;
    }

    if (uid) {
        const userKey = `totalskillz_progress_${uid}`;
        const p = localStorage.getItem(userKey);
        if (p) {
            const data = JSON.parse(p);
            // Ensure new fields exist
            if (!data.settings) data.settings = getInitialProgress().settings;
            if (data.bio === undefined) data.bio = '';
            if (!data.mistakeVault) data.mistakeVault = [];
            return data;
        }
    }

    // Fallback to legacy key (migration path)
    const legacyProgress = localStorage.getItem('totalskillz_progress');
    if (legacyProgress) {
        const data = JSON.parse(legacyProgress);
        // If we have a UID now, migrate it immediately
        if (uid) {
            localStorage.setItem(`totalskillz_progress_${uid}`, legacyProgress);
            localStorage.removeItem('totalskillz_progress'); // Remove legacy after migration to avoid double-dipping
        }
        return data;
    }

    return getInitialProgress();
}
function validateEmail(email) {
    return /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email);
}

async function handleForgotPassword(e) {
    e.preventDefault();
    const email = document.getElementById('forgotEmail').value.trim();
    if (!validateEmail(email)) {
        showError('forgotEmail', 'forgotEmailErr');
        return;
    }
    try {
        await firebase.auth().sendPasswordResetEmail(email);
        showToast('Password reset link sent to your email!', 'success');
        showPanel('loginPanel');
    } catch (error) {
        console.error("Reset error:", error);
        showToast('Failed to send reset link. ' + error.message, 'error');
    }
}

function showError(inputId, errId) {
    const input = document.getElementById(inputId);
    const err = document.getElementById(errId);
    if (input) input.classList.add('error');
    if (err) err.classList.add('visible');
}

function clearErrors() {
    document.querySelectorAll('.form-input').forEach(i => i.classList.remove('error'));
    document.querySelectorAll('.form-error').forEach(e => e.classList.remove('visible'));
}

// --- Settings Logic ---
function injectSettingsOverlay() {
    if (document.getElementById('settingsOverlay')) return;

    const overlay = document.createElement('div');
    overlay.className = 'settings-overlay';
    overlay.id = 'settingsOverlay';
    overlay.onclick = (e) => closeSettingsIfOutside(e);

    overlay.innerHTML = `
        <div class="settings-drawer" id="settingsDrawer">
            <div class="settings-header">
                <h2><i class="fa-solid fa-gears"></i> Manage Account</h2>
                <button class="close-settings" onclick="toggleSettingsOverlay()"><i class="fa-solid fa-xmark"></i></button>
            </div>
            <div class="settings-content">
                <!-- Identity Section -->
                <div class="settings-section" data-section="identity">
                    <h3 class="settings-section__title">Identity</h3>
                    <div class="setting-item">
                        <label class="setting-item__label">Display Name</label>
                        <div class="setting-control">
                            <input type="text" id="settingsName" class="form-input" placeholder="Your name">
                            <button class="btn btn-primary btn-sm" onclick="saveNameChange()">Update</button>
                        </div>
                    </div>
                    <div class="setting-item">
                        <label class="setting-item__label">Study Bio</label>
                        <textarea id="settingsBio" class="form-input" style="height:80px; resize:none;" placeholder="What is your goal?" onblur="saveBio(this.value)"></textarea>
                    </div>
                    <!-- Province and School -->
                    <div style="display:grid; grid-template-columns: 1fr 1fr; gap:1rem;">
                        <div class="setting-item">
                            <label class="setting-item__label">Province</label>
                            <select id="settingsProvince" class="form-input" onchange="saveLocationInfo()">
                                <option value="">Select Province</option>
                                <option value="Gauteng">Gauteng</option>
                                <option value="Western Cape">Western Cape</option>
                                <option value="KwaZulu-Natal">KwaZulu-Natal</option>
                                <option value="Eastern Cape">Eastern Cape</option>
                                <option value="Free State">Free State</option>
                                <option value="Limpopo">Limpopo</option>
                                <option value="Mpumalanga">Mpumalanga</option>
                                <option value="North West">North West</option>
                                <option value="Northern Cape">Northern Cape</option>
                            </select>
                        </div>
                        <div class="setting-item">
                            <label class="setting-item__label">School Name</label>
                            <input type="text" id="settingsSchool" class="form-input" placeholder="e.g. Khuzani High" onblur="saveLocationInfo()">
                        </div>
                    </div>
                </div>
                <!-- Security Section -->
                <div class="settings-section" data-section="security">
                    <h3 class="settings-section__title">Security</h3>
                    <div class="security-score">
                        <div class="score-circle" id="securityScoreRing">0%</div>
                        <div>
                            <div style="font-weight:700;">Security Score</div>
                            <div style="font-size:0.8rem; opacity:0.7;">Verify email & add phone to hit 100%</div>
                        </div>
                    </div>
                    <button class="btn btn-secondary btn-block" onclick="window.location.href='index.html?action=change_password'">Change Password</button>
                </div>
                <!-- Preferences Section -->
                <div class="settings-section" data-section="preferences">
                    <h3 class="settings-section__title">Learning Preferences</h3>
                    <div class="setting-item">
                        <div class="setting-control">
                            <div>
                                <div class="setting-item__label">Daily Question Goal</div>
                                <div id="goalValue" style="color:var(--primary); font-weight:700;">10 Questions</div>
                            </div>
                        </div>
                        <input type="range" class="range-slider" min="5" max="50" step="5" value="10" id="goalSlider" oninput="updateGoalPreview(this.value)" onchange="saveGoal(this.value)">
                    </div>
                    <div class="setting-item">
                        <div class="setting-control">
                            <div>
                                <div class="setting-item__label">Target Matric Mark</div>
                                <div id="targetMarkValue" style="color:var(--primary); font-weight:700;">80%</div>
                            </div>
                        </div>
                        <input type="range" class="range-slider" min="30" max="100" step="5" value="80" id="targetMarkSlider" oninput="updateTargetMarkPreview(this.value)" onchange="saveTargetMark(this.value)">
                    </div>
                    <div class="setting-item">
                        <div class="setting-control">
                            <div>
                                <div class="setting-item__label">Weekly Study Goal</div>
                                <div class="setting-item__desc">Target hours per week</div>
                            </div>
                            <div style="display:flex; align-items:center; gap:0.5rem;">
                                <button class="btn btn-secondary btn-sm" style="padding:0.25rem 0.5rem; font-size:1.2rem;" onclick="adjustWeeklyHours(-1)">-</button>
                                <span id="weeklyHoursValue" style="font-weight:700; width:3ch; text-align:center;">5</span>
                                <button class="btn btn-secondary btn-sm" style="padding:0.25rem 0.5rem; font-size:1.2rem;" onclick="adjustWeeklyHours(1)">+</button>
                            </div>
                        </div>
                    </div>
                    <div class="setting-item">
                        <div class="setting-item__label">Weak Area Focus</div>
                        <div class="setting-item__desc">Select topics to prioritize in your practice feed</div>
                        <div class="topic-pills" id="weakAreaPills"></div>
                    </div>
                    <div class="setting-item">
                        <div class="setting-control">
                            <div><div class="setting-item__label">Final Exam Date</div></div>
                            <input type="date" class="form-input" id="examDateInput" onchange="saveExamDate(this.value)">
                        </div>
                        <div class="countdown-box" id="examCountdownBox" style="display:none;">
                            <div><div class="countdown-box__days" id="examDaysLeft">0</div><div class="countdown-box__label">Days Left</div></div>
                            <i class="fa-regular fa-calendar-check countdown-box__icon"></i>
                        </div>
                    </div>
                    <div class="setting-item">
                        <div class="setting-control">
                            <div>
                                <div class="setting-item__label">Study Reminders</div>
                                <div class="setting-item__desc">Daily push notifications</div>
                            </div>
                            <label class="switch">
                                <input type="checkbox" id="remindersToggle" onchange="saveReminders(this.checked)">
                                <span class="slider"></span>
                            </label>
                        </div>
                    </div>
                </div>
                <!-- Data Section -->
                <div class="settings-section danger-section" data-section="danger">
                    <h3 class="settings-section__title" style="color:var(--accent-red);">Danger Zone</h3>
                    <button class="danger-btn" onclick="exportProgressData()"><i class="fa-solid fa-download"></i> Export Progress (JSON)</button>
                    <button class="danger-btn" onclick="confirmResetProgress()"><i class="fa-solid fa-rotate-left"></i> Reset Learning Progress</button>
                    <button class="danger-btn" style="background:var(--accent-red); color:white;" onclick="confirmDeleteAccount()"><i class="fa-solid fa-trash-can"></i> Delete Account permanently</button>
                </div>
            </div>
            <div class="settings-footer" style="padding:1.5rem; border-top:1px solid var(--border); text-align:center;">
                <div class="sidebar-custom-footer" style="margin-bottom: 1rem;">
                    <p style="font-size: 0.8rem; margin-bottom: 0.5rem;">Crafted by <span style="color: var(--primary); font-weight: 700;">Sphephelo Hlongwa</span></p>
                    <div class="sidebar-socials" style="display: flex; justify-content: center; gap: 1rem;">
                        <a href="#" style="color: var(--text-muted); font-size: 1.1rem;"><i class="fa-brands fa-x-twitter"></i></a>
                        <a href="#" style="color: var(--text-muted); font-size: 1.1rem;"><i class="fa-brands fa-linkedin"></i></a>
                        <a href="https://t.me/+LYN7mLk7K8I4ZjM0" target="_blank" style="color: var(--text-muted); font-size: 1.1rem;"><i class="fa-brands fa-telegram"></i></a>
                        <a href="https://github.com/sphe-hlongwa" target="_blank" style="color: var(--text-muted); font-size: 1.1rem;"><i class="fa-brands fa-github"></i></a>
                    </div>
                </div>
                <p style="font-size:0.7rem; color:var(--text-muted); opacity: 0.8;">TotalSkillz v2.4.0 - Built For Success</p>
                <a href="privacy.html" target="_blank" style="font-size:0.7rem; color:var(--text-muted); text-decoration:underline; opacity:0.7;"><i class="fa-solid fa-shield-halved"></i> Privacy Policy</a>
            </div>
        </div>
    `;

    document.body.appendChild(overlay);
}

function toggleSettingsOverlay() {
    let overlay = document.getElementById('settingsOverlay');
    if (!overlay) {
        injectSettingsOverlay();
        overlay = document.getElementById('settingsOverlay');
    }

    const isActive = overlay.classList.contains('active');

    if (!isActive) {
        overlay.style.display = 'flex';
        overlay.offsetHeight; // force reflow
        overlay.classList.add('active');
        populateSettings();
    } else {
        overlay.classList.remove('active');
        setTimeout(() => {
            overlay.style.display = 'none';
        }, 400);
    }
}

function closeSettingsIfOutside(e) {
    if (e.target.id === 'settingsOverlay') toggleSettingsOverlay();
}

/**
 * Unified Sidebar Navigation
 * Handles internal settings view switching and external page redirects
 */
function handleSidebarClick(el) {
    const view = el.getAttribute('data-view');
    const href = el.getAttribute('href');

    // If it's a settings view
    if (view) {
        openSettings(view);
        return false;
    }

    // Otherwise, let the default href redirect happen
    if (href && href !== '#') {
        window.location.href = href;
    }
}

function openSettings(sectionId) {
    let overlay = document.getElementById('settingsOverlay');
    if (!overlay) {
        injectSettingsOverlay();
        overlay = document.getElementById('settingsOverlay');
    }

    if (!overlay.classList.contains('active')) {
        toggleSettingsOverlay();
    }

    if (sectionId) {
        // Map sidebar data-view to settings data-section if different
        const sectionMap = {
            'data': 'danger',
            'identity': 'identity',
            'security': 'security',
            'preferences': 'preferences',
            'danger': 'danger'
        };
        const targetId = sectionMap[sectionId] || sectionId;

        setTimeout(() => {
            const section = document.querySelector(`.settings-section[data-section="${targetId}"]`) ||
                document.getElementById(targetId);
            if (section) {
                section.scrollIntoView({ behavior: 'smooth', block: 'start' });
                section.classList.add('highlight-flash');
                setTimeout(() => section.classList.remove('highlight-flash'), 2500);
            }
        }, 500);
    }
}

function populateSettings() {
    const user = firebase.auth().currentUser;
    const p = getProgress();

    // Identity
    const nameInput = document.getElementById('settingsName');
    const bioText = document.getElementById('settingsBio');
    if (nameInput) nameInput.value = user?.displayName || p.name || '';
    if (bioText) bioText.value = p.bio || '';

    // Location
    const provinceSelect = document.getElementById('settingsProvince');
    const schoolInput = document.getElementById('settingsSchool');
    if (provinceSelect) provinceSelect.value = p.province || '';
    if (schoolInput) schoolInput.value = p.school || '';

    // Preferences
    const darkToggle = document.getElementById('darkModeToggle');
    const goalSlider = document.getElementById('goalSlider');
    const goalVal = document.getElementById('goalValue');

    if (darkToggle) darkToggle.checked = document.body.getAttribute('data-theme') === 'dark';
    if (goalSlider) goalSlider.value = p.settings?.dailyGoal || 10;
    if (goalVal) goalVal.textContent = (p.settings?.dailyGoal || 10) + ' Questions';

    const targetMarkSlider = document.getElementById('targetMarkSlider');
    const targetMarkVal = document.getElementById('targetMarkValue');
    if (targetMarkSlider) targetMarkSlider.value = p.settings?.targetMark || 80;
    if (targetMarkVal) targetMarkVal.textContent = (p.settings?.targetMark || 80) + '%';

    const weeklyHoursVal = document.getElementById('weeklyHoursValue');
    if (weeklyHoursVal) weeklyHoursVal.textContent = p.settings?.weeklyHours || 5;

    const examDateInput = document.getElementById('examDateInput');
    if (examDateInput && p.settings?.examDate) {
        examDateInput.value = p.settings.examDate;
        updateExamCountdown(p.settings.examDate);
    }

    const remindersToggle = document.getElementById('remindersToggle');
    if (remindersToggle) remindersToggle.checked = p.settings?.reminders || false;

    if (typeof renderWeakAreaPills === 'function') {
        renderWeakAreaPills(p.settings?.weakAreas || []);
    }
    calculateSecurityScore();
}

async function saveNameChange() {
    const name = document.getElementById('settingsName').value.trim();
    const user = firebase.auth().currentUser;
    if (user && name) {
        try {
            await user.updateProfile({ displayName: name });
            showToast('Display name updated!', 'success');
            populateProfileModal();
        } catch (error) {
            showToast('Failed to update name.', 'error');
        }
    }
}

function saveBio(val) {
    const p = getProgress();
    p.bio = val;
    saveProgress(p);
}

function saveLocationInfo() {
    const p = getProgress();
    const prov = document.getElementById('settingsProvince').value;
    const school = document.getElementById('settingsSchool').value.trim();
    p.province = prov;
    p.school = school;
    saveProgress(p);
}

function toggleDarkTheme(isDark) {
    const theme = isDark ? 'dark' : 'light';
    setTheme(theme); // this sets DOM attribute, local storage, and the toggle icon

    const p = getProgress();
    if (!p.settings) p.settings = {};
    p.settings.theme = theme;
    saveProgress(p);
}


function updateGoalPreview(val) {
    document.getElementById('goalValue').textContent = val + ' Questions';
}

function saveGoal(val) {
    const p = getProgress();
    if (!p.settings) p.settings = {};
    p.settings.dailyGoal = parseInt(val);
    saveProgress(p);
    showToast('Daily goal updated!', 'info');
}

function updateTargetMarkPreview(val) {
    document.getElementById('targetMarkValue').textContent = val + '%';
}

function saveTargetMark(val) {
    const p = getProgress();
    if (!p.settings) p.settings = {};
    p.settings.targetMark = parseInt(val);
    saveProgress(p);
    showToast('Target mark updated!', 'info');
}

function adjustWeeklyHours(change) {
    const p = getProgress();
    if (!p.settings) p.settings = {};
    let current = p.settings.weeklyHours || 5;
    current += change;
    if (current < 1) current = 1;
    if (current > 40) current = 40;
    p.settings.weeklyHours = current;
    document.getElementById('weeklyHoursValue').textContent = current;
    saveProgress(p);
}

function renderWeakAreaPills(selectedAreas) {
    const container = document.getElementById('weakAreaPills');
    if (!container) return;
    const availableTopics = [
        { id: 'algebra', title: 'Algebra' }, { id: 'patterns', title: 'Patterns' },
        { id: 'functions', title: 'Functions' }, { id: 'finance', title: 'Finance' },
        { id: 'trigonometry', title: 'Trigonometry' }, { id: 'analytical_geometry', title: 'Analytical Geom' },
        { id: 'euclidean_geometry', title: 'Euclidean Geom' }, { id: 'calculus', title: 'Calculus' },
        { id: 'probability', title: 'Probability' }, { id: 'statistics', title: 'Statistics' }
    ];
    container.innerHTML = availableTopics.map(t => {
        const isActive = selectedAreas.includes(t.id);
        return `<div class="topic-pill ${isActive ? 'active' : ''}" onclick="toggleWeakArea('${t.id}')">${t.title}</div>`;
    }).join('');
}

function toggleWeakArea(topicId) {
    const p = getProgress();
    if (!p.settings) p.settings = {};
    if (!p.settings.weakAreas) p.settings.weakAreas = [];
    const index = p.settings.weakAreas.indexOf(topicId);
    if (index > -1) {
        p.settings.weakAreas.splice(index, 1);
    } else {
        if (p.settings.weakAreas.length >= 3) {
            showToast('You can only select up to 3 weak areas for now.', 'info');
            return;
        }
        p.settings.weakAreas.push(topicId);
    }
    saveProgress(p);
    renderWeakAreaPills(p.settings.weakAreas);
}

function saveExamDate(val) {
    const p = getProgress();
    if (!p.settings) p.settings = {};
    p.settings.examDate = val;
    saveProgress(p);
    updateExamCountdown(val);
    showToast('Exam date saved!', 'success');
}

function updateExamCountdown(dateString) {
    const box = document.getElementById('examCountdownBox');
    const label = document.getElementById('examDaysLeft');
    if (!box || !label) return;
    if (!dateString) { box.style.display = 'none'; return; }
    const examDate = new Date(dateString);
    const today = new Date();
    examDate.setHours(0, 0, 0, 0);
    today.setHours(0, 0, 0, 0);
    const diffTime = Math.max(0, examDate - today);
    const diffDays = Math.ceil(diffTime / (1000 * 60 * 60 * 24));
    label.textContent = diffDays;
    box.style.display = 'flex';
}

function saveReminders(checked) {
    const p = getProgress();
    if (!p.settings) p.settings = {};
    p.settings.reminders = checked;
    saveProgress(p);
    showToast(checked ? 'Study reminders enabled!' : 'Reminders disabled', 'info');
}

function calculateSecurityScore() {
    const user = firebase.auth().currentUser;
    let score = 50; // Base score for having an account
    if (user?.emailVerified) score += 25;
    if (user?.phoneNumber) score += 25;

    const ring = document.getElementById('securityScoreRing');
    if (ring) {
        ring.textContent = score + '%';
        const color = score === 100 ? 'var(--accent-green)' : (score >= 75 ? 'var(--primary)' : 'var(--accent-amber)');
        ring.style.borderColor = color;
    }
}

function exportProgressData() {
    const data = JSON.stringify(getProgress(), null, 2);
    const blob = new Blob([data], { type: 'application/json' });
    const url = URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `TotalSkillz_Progress_${new Date().toISOString().split('T')[0]}.json`;
    a.click();
    showToast('Progress exported!', 'success');
}

function confirmResetProgress() {
    const conf = confirm("Are you sure you want to reset all your learning progress and settings? This will also take you back to the setup screen.");
    if (conf) {
        const check = prompt("Type 'RESET' to confirm:");
        if (check === 'RESET') {
            const fresh = getInitialProgress();
            const user = firebase.auth().currentUser;

            // 1. Reset locally
            saveProgress(fresh);
            localStorage.removeItem('totalskillz_onboarded');

            if (user) {
                const db = firebase.firestore();
                // 2. Comprehensive Firestore Wipe
                const resetUser = db.collection('users').doc(user.uid).set({
                    onboarded: false,
                    progress: fresh,
                    lastUpdated: firebase.firestore.FieldValue.serverTimestamp()
                }, { merge: false });

                const resetLeaderboard = db.collection('leaderboard').doc(user.uid).delete();

                Promise.all([resetUser, resetLeaderboard]).then(() => {
                    showToast('All data reset successfully.', 'success');
                    setTimeout(() => window.location.href = 'index.html', 1500);
                }).catch(err => {
                    console.error("Firestore reset error:", err);
                    window.location.href = 'index.html';
                });
            } else {
                showToast('Progress reset locally.', 'info');
                setTimeout(() => window.location.href = 'index.html', 1500);
            }
        }
    }
}

async function confirmDeleteAccount() {
    const conf = confirm("CRITICAL: This will permanently delete your account and ALL your progress, scores, and data. This cannot be undone. Are you absolutely sure?");
    if (!conf) return;

    const user = firebase.auth().currentUser;
    if (!user) { showToast('No user signed in.', 'error'); return; }

    const check = prompt(`Type your email (${user.email}) to confirm permanent deletion:`);
    if (check !== user.email) {
        showToast('Email did not match. Deletion cancelled.', 'error');
        return;
    }

    showToast('Deleting your account...', 'info');

    try {
        const db = firebase.firestore();
        const uid = user.uid;

        // 1. Delete Firestore documents
        await Promise.all([
            db.collection('users').doc(uid).delete(),
            db.collection('leaderboard').doc(uid).delete()
        ]);

        // 2. Delete Firebase Auth account
        await user.delete();

        // 3. Clear all local data
        localStorage.clear();
        sessionStorage.clear();

        showToast('Account deleted. Goodbye!', 'success');
        setTimeout(() => window.location.href = 'index.html', 1500);
    } catch (error) {
        if (error.code === 'auth/requires-recent-login') {
            showToast('For security, please sign out and sign back in, then try again.', 'error');
        } else {
            showToast('Deletion failed: ' + error.message, 'error');
            console.error('Delete account error:', error);
        }
    }
}

// --- Formulas Modal Logic removed, now using dedicated formula.html ---

// --- Profile Modal Logic ---
function injectProfileModal() {
    if (document.getElementById('profileModalOverlay')) return;

    const overlay = document.createElement('div');
    overlay.className = 'profile-modal-overlay';
    overlay.id = 'profileModalOverlay';
    overlay.onclick = (e) => closeProfileModal(e);

    overlay.innerHTML = `
        <div class="profile-modal" id="profileModal" onclick="event.stopPropagation()">
            <button class="profile-modal__close" onclick="toggleProfileModal()" aria-label="Close modal">
                <i class="fa-solid fa-xmark"></i>
            </button>
            <div class="profile-modal__header">
                <span class="profile-modal__email" id="modalUserEmail">user@email.com</span>
                <div class="profile-modal__avatar-container">
                    <div class="profile-modal__avatar" id="modalUserAvatar">US</div>
                    <div class="profile-modal__avatar-edit"
                        onclick="document.getElementById('profilePicInput').click()">
                        <i class="fa-solid fa-camera"></i>
                    </div>
                    <input type="file" id="profilePicInput" accept="image/*" style="display:none;"
                        onchange="handleProfilePic(this)">
                </div>
                <h2 class="profile-modal__greeting" id="modalUserGreeting">Hi, User!</h2>
                <div style="display: flex; gap: 0.75rem; justify-content: center; margin-top: 0.5rem;">
                    <button type="button" class="theme-toggle-btn modal-theme-toggle" onclick="toggleTheme()" style="width: 40px; height: 40px; border-radius: 50%; background: var(--bg-card); display: flex; align-items: center; justify-content: center; border: 1px solid var(--border);">
                        <i class="fa-solid fa-moon"></i>
                    </button>
                </div>
            </div>

            <div class="profile-modal__alert" style="display:none;">
                <div class="profile-modal__alert-icon">
                    <i class="fa-solid fa-circle-exclamation"></i>
                </div>
                <div class="profile-modal__alert-content">
                    <div class="profile-modal__alert-title">Keep your progress safe</div>
                    <div class="profile-modal__alert-desc">Make sure your email is verified to never lose your learning streaks.</div>
                    <div class="profile-modal__alert-actions">
                        <button class="profile-modal__alert-btn" onclick="dismissVerificationAlert()">Dismiss</button>
                        <button class="profile-modal__alert-btn" style="color:var(--text-muted);" onclick="checkVerificationStatus()">Check status</button>
                        <button class="profile-modal__alert-btn" style="color:var(--secondary);" onclick="sendVerificationEmail()">Verify now</button>
                    </div>
                </div>
            </div>

            <div class="profile-modal__accounts" id="modalAccountsList">
                <!-- Accounts rendered by main.js -->
            </div>

            <div class="profile-modal__footer">
                <button class="profile-modal__logout-btn" onclick="logout()">
                    <i class="fa-solid fa-right-from-bracket"></i> Sign out
                </button>
            </div>
        </div>
    `;

    document.body.appendChild(overlay);

    // Initialize the toggle icon correctly based on the current theme
    updateThemeToggleIcon(getTheme());
}

async function handleProfilePic(input) {
    if (!input.files || !input.files[0]) return;

    const file = input.files[0];
    const user = firebase.auth().currentUser;
    if (!user) return;

    // Show uploading state immediately
    document.querySelectorAll('.user-avatar').forEach(av => {
        av.style.opacity = '0.6';
    });
    showToast('Uploading photo...', 'info');

    const reader = new FileReader();
    reader.onload = (e) => {
        const img = new Image();
        img.onload = async () => {
            // Compress & crop to square at 300x300 for quality
            const SIZE = 300;
            const canvas = document.createElement('canvas');
            canvas.width = SIZE;
            canvas.height = SIZE;
            const ctx = canvas.getContext('2d');

            // Crop center square
            const side = Math.min(img.width, img.height);
            const sx = (img.width - side) / 2;
            const sy = (img.height - side) / 2;
            ctx.drawImage(img, sx, sy, side, side, 0, 0, SIZE, SIZE);

            // Convert to Blob (JPEG, 85% quality)
            canvas.toBlob(async (blob) => {
                try {
                    const CLOUD_NAME = 'dijbs5ulp';
                    const UPLOAD_PRESET = 'TotalSkillz';

                    const formData = new FormData();
                    formData.append('file', blob);
                    formData.append('upload_preset', UPLOAD_PRESET);

                    const uploadRes = await fetch(`https://api.cloudinary.com/v1_1/${CLOUD_NAME}/image/upload`, {
                        method: 'POST',
                        body: formData
                    });

                    if (!uploadRes.ok) {
                        const errorData = await uploadRes.json();
                        throw new Error(errorData.error?.message || 'Failed to upload image to Cloudinary');
                    }

                    const uploadData = await uploadRes.json();
                    const downloadURL = uploadData.secure_url;

                    // Update Firebase Auth profile with real URL
                    await user.updateProfile({ photoURL: downloadURL });

                    // Also persist URL to Firestore user doc so other devices pick it up
                    await firebase.firestore().collection('users').doc(user.uid).set(
                        { photoURL: downloadURL },
                        { merge: true }
                    );

                    // Refresh all avatars on page immediately
                    document.querySelectorAll('.user-avatar').forEach(av => {
                        av.innerHTML = `<img src="${downloadURL}" style="width:100%; height:100%; object-fit:cover; border-radius:50%;">`;
                        av.style.background = 'transparent';
                        av.style.opacity = '1';
                    });

                    // Refresh profile modal
                    populateProfileModal();
                    showToast('Profile picture updated!', 'success');
                } catch (err) {
                    console.error('Profile picture upload failed:', err);
                    document.querySelectorAll('.user-avatar').forEach(av => av.style.opacity = '1');
                    showToast('Upload failed: ' + err.message, 'error');
                }
            }, 'image/jpeg', 0.85);
        };
        img.src = e.target.result;
    };
    reader.readAsDataURL(file);
}


function toggleProfileModal() {
    let overlay = document.getElementById('profileModalOverlay');
    if (!overlay) {
        injectProfileModal();
        overlay = document.getElementById('profileModalOverlay');
    }
    const isActive = overlay.classList.contains('active');

    if (!isActive) {
        overlay.style.display = 'flex';
        // Force reflow
        overlay.offsetHeight;
        overlay.classList.add('active');
        populateProfileModal();
        renderAccountList();
    } else {
        overlay.classList.remove('active');
        setTimeout(() => {
            overlay.style.display = 'none';
        }, 300);
    }
}

function dismissVerificationAlert() {
    sessionStorage.setItem('totalskillz_verify_dismissed', 'true');
    const alert = document.querySelector('.profile-modal__alert');
    if (alert) alert.style.display = 'none';
}

async function sendVerificationEmail() {
    const user = firebase.auth().currentUser;
    if (user) {
        try {
            await user.sendEmailVerification();
            showToast('Verification email sent! Check your inbox.', 'success');
            // Change button text to "Sent!"
            const btn = document.querySelector('button[onclick="sendVerificationEmail()"]');
            if (btn) {
                btn.textContent = 'Sent! Check Inbox';
                btn.disabled = true;
                btn.style.opacity = '0.5';
            }
        } catch (error) {
            console.error("Verification error:", error);
            showToast('Failed to send verification email.', 'error');
        }
    }
}

async function checkVerificationStatus() {
    const user = firebase.auth().currentUser;
    if (user) {
        try {
            await user.reload();
            const reloadedUser = firebase.auth().currentUser;
            if (reloadedUser.emailVerified) {
                showToast('Email verified successfully!', 'success');
                populateProfileModal(); // This will hide the alert
            } else {
                showToast('Email not verified yet. Please click the link in your email.', 'info');
            }
        } catch (error) {
            console.error("Reload error:", error);
        }
    }
}

function closeProfileModal(e) {
    if (e.target.id === 'profileModalOverlay') {
        toggleProfileModal();
    }
}

function populateProfileModal() {
    const user = firebase.auth().currentUser;
    if (!user) return;

    const emailEl = document.getElementById('modalUserEmail');
    const avatarEl = document.getElementById('modalUserAvatar');
    const greetingEl = document.getElementById('modalUserGreeting');
    const alertEl = document.querySelector('.profile-modal__alert');

    const name = user.displayName || user.email?.split('@')[0] || user.phoneNumber || 'User';
    const identifier = user.email || user.phoneNumber || 'User';
    const initials = getInitials(name);

    if (emailEl) emailEl.textContent = identifier;

    if (avatarEl) {
        if (user.photoURL) {
            avatarEl.innerHTML = `<img src="${user.photoURL}" style="width:100%; height:100%; object-fit:cover; border-radius:50%;">`;
            avatarEl.style.background = 'transparent';
        } else {
            avatarEl.textContent = initials;
            avatarEl.style.background = 'var(--primary)';
        }
    }

    if (greetingEl) greetingEl.textContent = `Hi, ${name.split(' ')[0]}!`;

    // Show verification alert if email not verified
    if (alertEl) {
        const isDismissed = sessionStorage.getItem('totalskillz_verify_dismissed');
        if (user.email && !user.emailVerified && !isDismissed) {
            alertEl.style.display = 'flex';
        } else {
            alertEl.style.display = 'none';
        }
    }
}


function updateAccountList(user) {
    if (!user) return;
    let accounts = JSON.parse(localStorage.getItem('totalskillz_accounts') || '[]');
    const newAccount = {
        uid: user.uid,
        name: user.displayName || user.email?.split('@')[0] || 'User',
        email: user.email || user.phoneNumber,
        photoURL: user.photoURL
    };

    // Remove existing if any
    accounts = accounts.filter(a => a.uid !== user.uid);
    accounts.unshift(newAccount);
    // Keep last 5
    localStorage.setItem('totalskillz_accounts', JSON.stringify(accounts.slice(0, 5)));
}

function renderAccountList() {
    const container = document.getElementById('modalAccountsList');
    if (!container) return;

    const accounts = JSON.parse(localStorage.getItem('totalskillz_accounts') || '[]');
    const currentUser = firebase.auth().currentUser;

    // Filter out current user from the list (they are shown in header)
    const otherAccounts = accounts.filter(a => a.uid !== (currentUser ? currentUser.uid : null));

    let html = otherAccounts.map(a => `
        <div class="profile-modal__account-item" onclick="switchAccount('${a.uid}')">
            <div class="profile-modal__account-avatar" style="background:var(--primary-pale); color:var(--primary);">
                ${a.photoURL ? `<img src="${sanitizeHTML(a.photoURL)}" style="width:100%; height:100%; object-fit:cover; border-radius:50%;">` : getInitials(sanitizeText(a.name))}
            </div>
            <div class="profile-modal__account-info">
                <div class="profile-modal__account-name">${sanitizeText(a.name)}</div>
                <div class="profile-modal__account-email">${sanitizeText(a.email)}</div>
            </div>
        </div>
    `).join('');

    // Add account button
    html += `
        <div class="profile-modal__account-item" style="border-bottom:none;" onclick="addAccount()">
            <i class="fa-solid fa-user-plus" style="width:32px; text-align:center; color:var(--text-secondary);"></i>
            <div class="profile-modal__account-info">
                <div class="profile-modal__account-name">Add another account</div>
            </div>
        </div>
    `;

    container.innerHTML = html;
}

function addAccount() {
    // To add an account, we sign out and go to login
    firebase.auth().signOut().then(() => {
        window.location.href = 'index.html?action=add_account';
    });
}

function switchAccount(uid) {
    // Firebase doesn't support easy multi-auth in standard web SDK easily without multiple apps
    // So "switching" means signing out and signing in again.
    // We'll just go to login page where the switcher will be shown
    firebase.auth().signOut().then(() => {
        window.location.href = 'index.html';
    });
}

// ---- Progress Handling ----
let progressSyncTimeout = null;

async function saveProgress(data) {
    const user = firebase.auth().currentUser;
    const uid = user ? user.uid : null;

    // 1. Immediate Local Save
    if (uid) {
        localStorage.setItem(`totalskillz_progress_${uid}`, JSON.stringify(data));
    } else {
        localStorage.setItem('totalskillz_progress', JSON.stringify(data));
    }

    // 2. Debounced Cloud Save (Every 5 seconds of inactivity)
    if (progressSyncTimeout) clearTimeout(progressSyncTimeout);

    progressSyncTimeout = setTimeout(async () => {
        const user = firebase.auth().currentUser;
        if (!user) return;

        try {
            await firebase.firestore().collection('users').doc(user.uid).set({
                displayName: user.displayName,
                email: user.email,
                progress: data,
                lastUpdated: firebase.firestore.FieldValue.serverTimestamp()
            }, { merge: true });

            // Leaderboard entry (only if public profile is on)
            if (data.settings?.publicProfile !== false) {
                const name = user.displayName || user.email?.split('@')[0] || 'Student';
                const firstName = name.split(' ')[0]; // first name only for anonymity
                await firebase.firestore().collection('leaderboard').doc(user.uid).set({
                    displayName: firstName,
                    photoURL: user.photoURL || null,
                    totalCorrect: data.totalCorrect || 0,
                    totalAttempted: data.totalAttempted || 0,
                    streak: data.streak || 0,
                    badges: (data.badges || []).length,
                    province: data.province || '',
                    school: data.school || '',
                    lastActive: firebase.firestore.FieldValue.serverTimestamp()
                }, { merge: true });
            }
        } catch (error) {
            console.warn("Error saving progress to Firestore:", error);
            if (typeof showToast === 'function') {
                showToast("Cloud sync unavailable. Progress saved locally.", "info");
            }
        }
    }, 5000);
}

async function syncFromFirestore(uid) {
    // ---- Smart Cache Guard ----
    // Only fetch from Firestore if local data is older than 5 minutes.
    // This dramatically reduces Firestore reads for users navigating between pages.
    const CACHE_TTL_MS = 5 * 60 * 1000; // 5 minutes
    const tsKey = `totalskillz_sync_ts_${uid}`;
    const lastSync = parseInt(localStorage.getItem(tsKey) || '0', 10);
    const localData = localStorage.getItem(`totalskillz_progress_${uid}`);

    if (localData && Date.now() - lastSync < CACHE_TTL_MS) {
        // Data is fresh — skip Firestore read entirely
        console.log('[Sync] Using cached progress (< 5 min old). Skipping Firestore read.');
        return JSON.parse(localData);
    }

    try {
        const doc = await firebase.firestore().collection('users').doc(uid).get();
        if (doc.exists && doc.data().progress) {
            const data = doc.data().progress;
            localStorage.setItem(`totalskillz_progress_${uid}`, JSON.stringify(data));
            localStorage.setItem(tsKey, Date.now().toString()); // Record sync timestamp
            return data;
        }
    } catch (error) {
        console.error("Error syncing from Firestore:", error);
        // Return local data as fallback so the app still works offline
        if (localData) return JSON.parse(localData);
    }
    return null;
}

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
    // p.dailyDone removed - we use lastDailyDate now
    saveProgress(p);
    return p;
}

function recordAnswer(topic, correct, questionObj = null) {
    const p = getProgress();
    if (!p.topics[topic]) p.topics[topic] = { correct: 0, total: 0, level: 0 };
    p.topics[topic].total++;
    p.totalAttempted++;
    if (correct) {
        p.topics[topic].correct++;
        p.totalCorrect++;
    }

    // Mistake Vault Logic (Spaced Repetition)
    if (questionObj) {
        const qId = getQuestionHash(questionObj.q);
        const vaultIndex = p.mistakeVault.findIndex(v => v.id === qId);

        if (!correct) {
            // New mistake or reset streak
            if (vaultIndex === -1) {
                p.mistakeVault.push({
                    id: qId,
                    topic: topic,
                    qText: questionObj.q,
                    streak: 0,
                    lastSeen: Date.now()
                });
            } else {
                p.mistakeVault[vaultIndex].streak = 0;
                p.mistakeVault[vaultIndex].lastSeen = Date.now();
            }
        } else {
            // Correct answer - check if in vault
            if (vaultIndex !== -1) {
                p.mistakeVault[vaultIndex].streak++;
                p.mistakeVault[vaultIndex].lastSeen = Date.now();

                // Mastery achieved: Remove after 3 correct in a row
                if (p.mistakeVault[vaultIndex].streak >= 3) {
                    p.mistakeVault.splice(vaultIndex, 1);
                    showToast('Mastery Unlocked! Question removed from Vault.', 'success');
                }
            }
        }
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

// ---- Topic Toggle (Mobile) ----
function initTopicToggle() {
    const btn = document.getElementById('topicToggleBtn');
    const wrapper = document.getElementById('topicPills');
    const icon = document.getElementById('topicToggleIcon');

    if (!btn || !wrapper || !icon) return;

    btn.addEventListener('click', () => {
        wrapper.classList.toggle('expanded');
        if (wrapper.classList.contains('expanded')) {
            icon.classList.remove('fa-chevron-down');
            icon.classList.add('fa-chevron-up');
        } else {
            icon.classList.remove('fa-chevron-up');
            icon.classList.add('fa-chevron-down');
        }
    });
}

// ---- Init ----
document.addEventListener('DOMContentLoaded', () => {
    setTheme(getTheme());

    // Migration: Move mg12_ prefixed keys to totalskillz_
    const legacyKeys = ['progress', 'user', 'theme', 'accounts', 'verify_dismissed', 'quote_reveal'];
    legacyKeys.forEach(k => {
        const oldKey = `mg12_${k}`;
        const newKey = `totalskillz_${k}`;
        const val = localStorage.getItem(oldKey) || (k === 'verify_dismissed' ? sessionStorage.getItem(oldKey) : null);

        if (val && !localStorage.getItem(newKey) && !(k === 'verify_dismissed' && sessionStorage.getItem(newKey))) {
            if (k === 'verify_dismissed') {
                sessionStorage.setItem(newKey, val);
                sessionStorage.removeItem(oldKey);
            } else {
                localStorage.setItem(newKey, val);
                localStorage.removeItem(oldKey);
            }
            console.log(`Migrated legacy key: ${oldKey} -> ${newKey}`);
        }
    });

    // Migration: Move legacy 'userProgress' to 'totalskillz_progress'
    const legacyProgress = localStorage.getItem('userProgress');
    if (legacyProgress && !localStorage.getItem('totalskillz_progress')) {
        localStorage.setItem('totalskillz_progress', legacyProgress);
        localStorage.removeItem('userProgress');
    }

    initHeader();
    initMobileNav();
    initReveal();
    initTabs();
    initTopicToggle();
    renderMath();

    // Firebase Auth State Observer
    firebase.auth().onAuthStateChanged(async (user) => {
        const isIndex = window.location.pathname.endsWith('index.html') || window.location.pathname === '/' || window.location.pathname.includes('index.html');
        const protectedPages = ['dashboard.html', 'practice.html', 'interactive.html', 'topics.html'];
        const isProtected = protectedPages.some(p => window.location.pathname.endsWith(p));

        if (user) {
            if (location.hostname === 'localhost' || location.hostname === '127.0.0.1') {
                console.debug("Authenticated user session active.");
            }

            // Populate avatars on the page
            const avatars = document.querySelectorAll('.user-avatar');
            const name = user.displayName || user.email?.split('@')[0] || user.phoneNumber || 'User';
            const initials = getInitials(name);

            avatars.forEach(av => {
                if (user.photoURL) {
                    av.innerHTML = `<img src="${user.photoURL}" style="width:100%; height:100%; object-fit:cover; border-radius:50%;">`;
                    av.style.background = 'transparent';
                } else {
                    av.textContent = initials;
                    av.style.background = 'var(--primary)';
                }
                av.style.display = 'flex';
                av.style.alignItems = 'center';
                av.style.justifyContent = 'center';
                av.style.color = 'white';
                av.style.fontWeight = '700';
                av.style.fontSize = '0.8rem';
            });

            // Admin Shortcut (Firestore Role)
            firebase.firestore().collection('users').doc(user.uid).get().then(doc => {
                const isAdmin = doc.exists && doc.data() && doc.data().role === 'admin';
                const adminLink = document.getElementById('adminSidebarLink');
                if (adminLink) adminLink.style.display = isAdmin ? 'flex' : 'none';
            }).catch(err => {
                console.error("Error fetching user role for admin check:", err);
            });

            // Sync progress
            const syncedData = await syncFromFirestore(user.uid);
            // Removed: setTheme(syncedData.settings.theme); 
            // Theme remains purely device-local to prevent race condition overwrites
            updateAccountList(user);

            if (isIndex && !window.location.search.includes('action=add_account')) {
                // Check if user has completed onboarding
                const localOnboarded = localStorage.getItem('totalskillz_onboarded');
                if (localOnboarded === 'true') {
                    window.location.href = 'dashboard.html';
                } else {
                    // Check Firestore for onboarded flag
                    firebase.firestore().collection('users').doc(user.uid).get().then(doc => {
                        if (doc.exists && doc.data().onboarded) {
                            localStorage.setItem('totalskillz_onboarded', 'true');
                            window.location.href = 'dashboard.html';
                        } else {
                            window.location.href = 'onboarding.html';
                        }
                    }).catch(() => {
                        // On error, go to dashboard to avoid blocking users
                        window.location.href = 'dashboard.html';
                    });
                }
            }
        } else {
            // User is signed out
            if (isProtected) {
                window.location.href = 'index.html';
            }
        }
    });

    initReveal();
    renderMath();

    // Sidebar View Change Listener
    document.addEventListener('skillz-view-change', (e) => {
        if (e.detail && e.detail.view) {
            openSettings(e.detail.view);
        }
    });
});

// ---- Bug & Error Reporting ----
async function reportMistake(module, contextInfo) {
    const user = firebase.auth().currentUser;
    if (!user) {
        showToast('Please sign in to report mistakes.', 'error');
        return;
    }

    const comment = prompt("What's the issue? (e.g., 'Typo in option B', 'Solution math doesn't load'):");
    if (!comment || comment.trim() === '') return;

    try {
        await firebase.firestore().collection('reports').add({
            uid: user.uid,
            email: user.email || 'Anonymous',
            module: module,
            context: contextInfo,
            comment: comment.trim(),
            status: 'open',
            timestamp: firebase.firestore.FieldValue.serverTimestamp()
        });
        showToast('Report submitted! Thank you for helping improve TotalSkillz.', 'success');
    } catch (e) {
        console.error('Error submitting report:', e);
        showToast('Failed to submit report. Please try again.', 'error');
    }
}

// ---- Broadcast System ----
async function loadBroadcasts() {
    const container = document.getElementById('broadcastContainer');
    if (!container) return;

    try {
        // Query active broadcasts
        // Note: Firestore requires an index for compound queries. 
        // If index is missing, we'll fetch all active and filter by date client-side.
        const snap = await firebase.firestore().collection('broadcasts')
            .where('active', '==', true)
            .get();

        if (snap.empty) {
            container.style.display = 'none';
            return;
        }

        const dismissed = JSON.parse(localStorage.getItem('dismissed_broadcasts') || '[]');

        const now = new Date();
        const validBroadcasts = snap.docs
            .map(doc => ({ id: doc.id, ...doc.data() }))
            .filter(b => (!b.expiresAt || b.expiresAt.toDate() > now) && !dismissed.includes(b.id))
            .sort((a, b) => (b.createdAt?.toMillis() || 0) - (a.createdAt?.toMillis() || 0));

        if (validBroadcasts.length === 0) {
            container.style.display = 'none';
            return;
        }

        // Render Broadcasts
        container.style.display = 'flex';
        container.innerHTML = validBroadcasts.map(b => {
            // Determine styles based on type
            let bg, border, icon, color;
            switch (b.type) {
                case 'success':
                    bg = 'rgba(34, 197, 94, 0.1)'; border = '#22c55e'; icon = 'fa-circle-check'; color = '#22c55e';
                    break;
                case 'warning':
                    bg = 'rgba(245, 158, 11, 0.1)'; border = '#f59e0b'; icon = 'fa-triangle-exclamation'; color = '#f59e0b';
                    break;
                case 'alert':
                    bg = 'rgba(239, 68, 68, 0.1)'; border = '#ef4444'; icon = 'fa-circle-exclamation'; color = '#ef4444';
                    break;
                case 'info':
                default:
                    bg = 'rgba(56, 189, 248, 0.1)'; border = '#38bdf8'; icon = 'fa-circle-info'; color = '#38bdf8';
                    break;
            }

            return `
            <div class="broadcast-card" id="broadcast-${b.id}" style="
                background: ${bg}; 
                border-left: 4px solid ${border}; 
                padding: 1rem; 
                border-radius: 8px; 
                display: flex; 
                gap: 1rem; 
                align-items: flex-start; 
                position: relative;
                animation: slideDown 0.3s ease-out;
            ">
                <i class="fa-solid ${icon}" style="color: ${color}; font-size: 1.2rem; margin-top: 0.1rem;"></i>
                <div style="flex: 1;">
                    <h4 style="margin: 0 0 0.3rem 0; color: var(--text); font-size: 0.95rem;">${b.title}</h4>
                    <p style="margin: 0; color: var(--text-secondary); font-size: 0.85rem; line-height: 1.4;">${b.message}</p>
                </div>
                <div style="display: flex; flex-direction: column; gap: 0.5rem; justify-content: center;">
                    <button onclick="dismissBroadcast('${b.id}')" style="
                        background: none; 
                        border: none; 
                        color: var(--text-muted); 
                        cursor: pointer; 
                        padding: 0.2rem;
                        opacity: 0.6;
                        transition: opacity 0.2s;
                    " onmouseover="this.style.opacity=1" onmouseout="this.style.opacity=0.6" title="Dismiss">
                        <i class="fa-solid fa-xmark"></i>
                    </button>
                    <button class="broadcast-reply-btn" data-broadcast-id="${b.id}" data-broadcast-title="${b.title.replace(/"/g, '&quot;')}" style="
                        background: none; 
                        border: none; 
                        color: var(--primary); 
                        cursor: pointer; 
                        padding: 0.2rem;
                        opacity: 0.8;
                        transition: opacity 0.2s;
                    " onmouseover="this.style.opacity=1" onmouseout="this.style.opacity=0.8" title="Respond">
                        <i class="fa-solid fa-reply"></i>
                    </button>
                </div>
            </div>`;
        }).join('');

        // Attach reply button events safely using data attributes
        container.querySelectorAll('.broadcast-reply-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                openBroadcastReply(btn.dataset.broadcastId, btn.dataset.broadcastTitle);
            });
        });

    } catch (e) {
        console.error('Error loading broadcasts:', e);
        // Fail silently - don't disrupt user experience
    }
}

function dismissBroadcast(id) {
    const el = document.getElementById('broadcast-' + id);
    if (el) {
        el.style.opacity = '0';
        el.style.transform = 'translateY(-10px)';
        setTimeout(() => el.remove(), 300);

        // Check if container is empty and hide it
        const container = document.getElementById('broadcastContainer');
        if (container && container.children.length <= 1) {
            setTimeout(() => container.style.display = 'none', 300);
        }
    }
    // Ideally save dismissed ID to localStorage to prevent reappearing
    const dismissed = JSON.parse(localStorage.getItem('dismissed_broadcasts') || '[]');
    if (!dismissed.includes(id)) {
        dismissed.push(id);
        localStorage.setItem('dismissed_broadcasts', JSON.stringify(dismissed));
    }
}

// ---- Broadcast Response System ----
window.openBroadcastReply = function (id, title) {
    // Create Modal if it doesn't exist
    let modal = document.getElementById('broadcastReplyModal');
    if (!modal) {
        modal = document.createElement('div');
        modal.id = 'broadcastReplyModal';
        modal.className = 'video-modal-overlay'; // Reusing modal styles
        modal.style.display = 'flex';
        modal.innerHTML = `
            <div class="video-modal-content" style="max-width: 500px; padding: 2rem; background: var(--bg-card); border: 1px solid var(--border); border-radius: var(--radius-lg);">
                <button class="video-modal-close" onclick="closeBroadcastReply()">×</button>
                <h3 id="replyModalTitle" style="margin-bottom: 0.5rem; color: var(--text);">Respond to Announcement</h3>
                <p id="replyModalBroadcastTitle" style="font-size: 0.85rem; color: var(--primary); margin-bottom: 1.5rem; font-weight: 600;"></p>
                <textarea id="replyMessage" placeholder="Type your message here..." style="
                    width: 100%; 
                    min-height: 120px; 
                    background: var(--bg-elevated); 
                    border: 1px solid var(--border); 
                    border-radius: var(--radius-md); 
                    color: var(--text); 
                    padding: 0.75rem; 
                    font-family: inherit;
                    margin-bottom: 1.5rem;
                    outline: none;
                " onfocus="this.style.borderColor='var(--primary)'" onblur="this.style.borderColor='var(--border)'"></textarea>
                <div style="display: flex; gap: 1rem; justify-content: flex-end;">
                    <button class="btn btn-secondary" onclick="closeBroadcastReply()">Cancel</button>
                    <button class="btn btn-primary" id="submitReplyBtn" onclick="submitBroadcastReply()">
                        <i class="fa-solid fa-paper-plane" style="margin-right:0.5rem;"></i> Send Response
                    </button>
                </div>
            </div>
        `;
        document.body.appendChild(modal);
    }

    // Set details
    modal.style.display = 'flex';
    // Add .open class so the video-modal-overlay CSS makes it visible (opacity: 1, pointer-events: all)
    requestAnimationFrame(() => modal.classList.add('open'));
    document.getElementById('replyModalBroadcastTitle').textContent = title;
    document.getElementById('replyMessage').value = '';
    window.currentReplyBroadcastId = id;
    window.currentReplyBroadcastTitle = title;
    document.getElementById('replyMessage').focus();
};

window.closeBroadcastReply = function () {
    const modal = document.getElementById('broadcastReplyModal');
    if (modal) {
        modal.classList.remove('open');
        // Wait for fade-out transition before hiding
        setTimeout(() => { modal.style.display = 'none'; }, 300);
    }
};

window.submitBroadcastReply = async function () {
    const msg = document.getElementById('replyMessage').value.trim();
    if (!msg) {
        showToast('Please type a message first.', 'error');
        return;
    }

    const btn = document.getElementById('submitReplyBtn');
    const originalText = btn.innerHTML;
    btn.disabled = true;
    btn.innerHTML = '<i class="fa-solid fa-spinner fa-spin"></i> Sending...';

    try {
        const user = firebase.auth().currentUser;
        if (!user) throw new Error('You must be logged in to respond.');

        await firebase.firestore().collection('broadcast_responses').add({
            broadcastId: window.currentReplyBroadcastId,
            broadcastTitle: window.currentReplyBroadcastTitle,
            studentId: user.uid,
            name: user.displayName || 'Anonymous Learner',
            email: user.email,
            message: msg,
            createdAt: firebase.firestore.FieldValue.serverTimestamp()
        });

        showToast('Your response has been sent to the instructor.', 'success');
        closeBroadcastReply();
        // Automatically dismiss the broadcast once replied
        dismissBroadcast(window.currentReplyBroadcastId);
    } catch (e) {
        console.error("Reply Error:", e);
        showToast("Failed to send: " + e.message, 'error');
    } finally {
        btn.disabled = false;
        btn.innerHTML = originalText;
    }
};

window.showFullLeaderboard = false;
window.toggleLeaderboardView = function () {
    window.showFullLeaderboard = !window.showFullLeaderboard;
    fetchLeaderboard();
};

async function fetchLeaderboard() {
    const listElement = document.getElementById('leaderboardList');
    if (!listElement) return;

    try {
        const currentUser = firebase.auth().currentUser;
        if (!currentUser) return; // Wait for auth

        // 1. Get current user's score to set the benchmark
        const userDoc = await firebase.firestore().collection('leaderboard').doc(currentUser.uid).get();
        let myStreak = 0;
        if (userDoc.exists) myStreak = userDoc.data().streak || 0;

        // 2. Fetch people immediately above and below to create "The Chase"
        // We do a broader query and filter locally to ensure we get neighbors.
        let query = firebase.firestore().collection('leaderboard').orderBy('streak', 'desc');

        // Apply filters if needed (e.g. Province)
        const filter = localStorage.getItem('totalskillz_leaderboard_filter') || 'global';
        const p = getProgress();

        if (filter === 'province') {
            if (!p.province) {
                listElement.innerHTML = `<div style="text-align:center; padding: 2rem; color: var(--text-muted); font-size: 0.85rem;">Set your province in <b>Identity</b> settings to see regional rankings.</div>`;
                return;
            }
            query = query.where('province', '==', p.province);
        } else if (filter === 'school') {
            if (!p.school) {
                listElement.innerHTML = `<div style="text-align:center; padding: 2rem; color: var(--text-muted); font-size: 0.85rem;">Set your school in <b>Identity</b> settings to see school rankings.</div>`;
                return;
            }
            query = query.where('school', '==', p.school);
        }

        // Add secondary sort by lastActive to handle ties in streak gracefully
        query = query.orderBy('lastActive', 'desc');

        const querySnapshot = await query.limit(20).get(); // Broaden slightly to ensure we find current user

        if (querySnapshot.empty) {
            listElement.innerHTML = `
                <div style="text-align:center; padding: 2rem; color: var(--text-muted); font-size: 0.9rem;">
                    No ranking data available yet. Start practicing to be the first!
                </div>
            `;
            return;
        }

        let allUsers = [];
        let myRank = -1;
        let rankCounter = 1;

        querySnapshot.forEach(doc => {
            const data = doc.data();
            allUsers.push({ id: doc.id, ...data, rank: rankCounter });
            if (doc.id === currentUser.uid) {
                myRank = rankCounter;
            }
            rankCounter++;
        });

        // 3. Determine which users to show (Localized competition)
        let displayUsers = [];
        if (myRank === -1) {
            // User not in top 50, show top 5 as fallback
            displayUsers = allUsers.slice(0, 5);
        } else {
            // Show up to 2 above, self, and up to 2 below (total 5)
            const startIndex = Math.max(0, myRank - 3); // -1 for 0-index, -2 for neighbors = -3
            displayUsers = allUsers.slice(startIndex, startIndex + 5);
        }

        let visibleUsers = [];
        if (window.showFullLeaderboard) {
            visibleUsers = displayUsers;
        } else {
            if (myRank !== -1) {
                // Show user and up to 2 people directly above them
                const startIdx = Math.max(0, myRank - 3); 
                visibleUsers = allUsers.slice(startIdx, myRank);
            } else {
                // Not in top 20, just show top 3
                visibleUsers = displayUsers.slice(0, 3);
            }
        }

        let html = '';
        let displayDelay = 1;

        visibleUsers.forEach(user => {
            const name = user.displayName || 'Anonymous Learner';
            // Generate initials
            const initials = name.split(' ').map(n => n[0]).join('').substring(0, 2).toUpperCase();

            // Highlight the current user
            const isMe = user.id === currentUser.uid;
            const bgStyle = isMe ? 'background: var(--bg-hover); border: 1px solid var(--primary-light);' : '';
            const indicator = isMe ? '<span style="font-size: 0.7rem; color: var(--primary); font-weight: bold; margin-left: 0.4rem;">(You)</span>' : '';

            const avatarContent = user.photoURL 
                ? `<img src="${user.photoURL}" style="width:100%; height:100%; object-fit:cover; border-radius:50%;" alt="${name}'s avatar">`
                : initials;

            // Professional Rank Display with Icons
            let rankDisplay = user.rank;
            if (user.rank === 1) rankDisplay = '<i class="fa-solid fa-medal" style="color: #f59e0b; font-size: 1.2rem;"></i>';
            else if (user.rank === 2) rankDisplay = '<i class="fa-solid fa-medal" style="color: #94a3b8; font-size: 1.2rem;"></i>';
            else if (user.rank === 3) rankDisplay = '<i class="fa-solid fa-medal" style="color: #d97706; font-size: 1.2rem;"></i>';
            else rankDisplay = `<span style="font-family: inherit; opacity: 0.7;">#${user.rank}</span>`;

            html += `
                <div class="leaderboard-item" style="animation-delay: ${displayDelay * 0.1}s; ${bgStyle}">
                    <div class="leaderboard-item__rank">${rankDisplay}</div>
                    <div class="leaderboard-item__user">
                        <div class="leaderboard-item__avatar" style="${isMe && !user.photoURL ? 'background: var(--primary); color: white;' : ''}">${avatarContent}</div>
                        <div class="leaderboard-item__details">
                            <div class="leaderboard-item__name" style="${isMe ? 'color: var(--primary);' : ''}">${name}${indicator}</div>
                        </div>
                    </div>
                    <div class="leaderboard-item__stats">
                        <div class="leaderboard-item__score" style="${isMe ? 'color: var(--primary);' : ''}">${user.streak || 0}</div>
                        <div class="leaderboard-item__label">Streak</div>
                    </div>
                </div>
            `;
            displayDelay++;
        });

        if (displayUsers.length > 2) {
            html += `
                <button class="btn btn-secondary btn-sm" style="width:100%; margin-top:0.5rem;" onclick="toggleLeaderboardView()">
                    ${window.showFullLeaderboard ? 'View Less' : 'View All'}
                </button>
            `;
        }

        listElement.innerHTML = html;

    } catch (error) {
        console.error("Error fetching leaderboard: ", error);
        listElement.innerHTML = `
            <div style="text-align:center; padding: 2rem; color: var(--accent-red); font-size: 0.9rem;">
                <i class="fa-solid fa-triangle-exclamation"></i><br>
                Failed to load leaderboard data.
            </div>
        `;
    }
}

function setLeaderboardFilter(filter, el) {
    localStorage.setItem('totalskillz_leaderboard_filter', filter);

    // Update pills UI
    const container = el.parentElement;
    container.querySelectorAll('.filter-pill').forEach(btn => btn.classList.remove('active'));
    el.classList.add('active');

    // Refresh list
    const listElement = document.getElementById('leaderboardList');
    if (listElement) {
        listElement.innerHTML = `<div style="text-align:center; padding: 2.5rem; color: var(--text-muted);"><i class="fa-solid fa-spinner fa-spin"></i> Filtering...</div>`;
    }
    fetchLeaderboard();
}

// Ensure leaderboard fetches when dashboard loads is now handled by init() in dashboard.html
document.addEventListener('DOMContentLoaded', () => {
    // If we're on the dashboard, we now rely on onAuthStateChanged -> init() -> fetchLeaderboard()
    // This removes the brittle 1.5s timeout.
});

// ---- Video Player Modal ----

// Curated grade 12 maths video IDs per topic (avoids broken listType=search embeds)
window.TOPIC_VIDEO_MAP = {
    'algebra': 'grnP3mduZkM',  // Grade 12 Algebra
    'patterns': 'XZJdyPkCxuE',  // Arithmetic & Geometric sequences
    'sequence': 'XZJdyPkCxuE',
    'functions': '2IWIywXcpvg',  // Grade 12 Functions
    'inverse': 'ALmlMfeE9FA',
    'finance': '-kZTsNnRlac',  // Financial Maths
    'annuities': '5n_JBf-9ohA',
    'trigonometry': 'g8VCHoSk5_o',  // Grade 12 Trig
    'compound angle': 'yq76CaYxPWc',
    'analytical_geometry': 'x_i2ksL0REI',  // Analytical Geometry
    'analytical': '4rDnk9o9_wg',
    'circle geometry': 'REbGfxDc_2A',
    'euclidean_geometry': 'nWn-HjCP9wY',  // Euclidean Geometry / Circle Theorems
    'euclidean': 'u2OYPDu_mhk',
    'theorems': 'j-DOGwvCWjk',
    'calculus': 'alUkVWVEP10',  // Calculus Differentiation
    'derivative': 'WsQQvHm4lSw',
    'probability': '94AmzeR9n2w',  // Probability
    'counting': 'loYKqFQcksY',
    'statistics': 'XZo4xyJXCak',  // Statistics regression
    'regression': 'yXbx5EHE1ag',
    'quadratic': 'Ws_tyxB-Xyo',
    'revision': 'kJd8o0r1Cz8',  // General grade 12 maths revision
};

function openVideoModal(queryOrUrl, title = 'Video Lesson') {
    let overlay = document.getElementById('globalVideoModal');

    // Create modal if it doesn't exist
    if (!overlay) {
        overlay = document.createElement('div');
        overlay.id = 'globalVideoModal';
        overlay.className = 'video-modal-overlay';
        overlay.innerHTML = `
            <div class="video-modal-content">
                <div class="video-modal-header">
                    <h3 class="video-modal-title" id="videoModalTitle"><i class="fa-brands fa-youtube" style="color:#ef4444;"></i> <span>Video Lesson</span></h3>
                    <div style="display:flex; gap:0.5rem; align-items:center;">
                        <button class="video-modal-close" onclick="closeVideoModal()"><i class="fa-solid fa-xmark"></i></button>
                    </div>
                </div>
                <div class="video-modal-body" id="videoModalBody">
                    <!-- Content goes here -->
                </div>
            </div>
        `;
        document.body.appendChild(overlay);

        // Close on click outside
        overlay.addEventListener('click', (e) => {
            if (e.target === overlay) closeVideoModal();
        });
    }

    // Set title
    if (document.querySelector('#videoModalTitle span')) {
        document.querySelector('#videoModalTitle span').textContent = title;
    }

    // Add Escape key listener
    // 3. Event listener memory leak - Remove any existing handler before adding a new one
    if (overlay._handleEscape) {
        window.removeEventListener('keydown', overlay._handleEscape);
    }
    const handleEscape = (e) => {
        if (e.key === 'Escape') closeVideoModal();
    };
    window.addEventListener('keydown', handleEscape);
    overlay._handleEscape = handleEscape;

    // Determine YouTube URL
    let embedUrl = '';
    let isSearch = false;
    let fallbackSearchQuery = '';
    let parsedVideoId = null;

    function isValidUrl(string) {
        try {
            new URL(string);
            return true;
        } catch (_) {
            return false;
        }
    }

    let isPlaylist = false;
    let playlistId = '';

    if (isValidUrl(queryOrUrl)) {
        if (queryOrUrl.includes('youtube.com/watch?v=')) {
            const urlParams = new URL(queryOrUrl).searchParams;
            parsedVideoId = urlParams.get('v');
            const listId = urlParams.get('list');

            if (listId && !parsedVideoId) {
                isPlaylist = true;
                playlistId = listId;
            } else if (parsedVideoId) {
                embedUrl = `https://www.youtube.com/embed/${parsedVideoId}`;
            }
        } else if (queryOrUrl.includes('youtube.com/playlist?list=')) {
            const urlParams = new URL(queryOrUrl).searchParams;
            isPlaylist = true;
            playlistId = urlParams.get('list');
        } else if (queryOrUrl.includes('youtu.be/')) {
            parsedVideoId = queryOrUrl.split('.be/')[1].split('?')[0];
            embedUrl = `https://www.youtube.com/embed/${parsedVideoId}`;
        }
    }

    if (!embedUrl && !isPlaylist) {
        // Search query — find curated video ID or fallback
        const lower = queryOrUrl.toLowerCase();
        let topicVideoId = null;

        // Try to match against known topic keys
        const topicKeys = Object.keys(TOPIC_VIDEO_MAP).sort((a, b) => b.length - a.length);
        for (const key of topicKeys) {
            if (lower.includes(key.replace(/_/g, ' '))) {
                topicVideoId = TOPIC_VIDEO_MAP[key];
                break;
            }
        }

        if (topicVideoId) {
            parsedVideoId = topicVideoId;
            embedUrl = `https://www.youtube.com/embed/${topicVideoId}`;
        } else {
            isSearch = true;
            fallbackSearchQuery = `${queryOrUrl} Kevinmathscience OR Mlungisi Nkosi OR The Organic Chemistry Tutor`;
        }
    }

    if (isSearch) {
        // Handle Search Fallback inside the modal
        document.getElementById('videoModalBody').innerHTML = `
            <div style="padding: 2rem; text-align: center;">
                <i class="fa-brands fa-youtube" style="font-size: 3rem; color: #ef4444; margin-bottom: 1rem;"></i>
                <h4>Search for Video</h4>
                <p style="color: var(--text-muted); margin-bottom: 1.5rem; font-size: 0.9rem;">
                    We couldn't find a direct link for this topic. Click below to search YouTube for the best tutorials.
                </p>
                <a href="https://www.youtube.com/results?search_query=${encodeURIComponent(fallbackSearchQuery)}" 
                   target="_blank" class="btn btn-primary">
                    <i class="fa-solid fa-magnifying-glass"></i> Search YouTube
                </a>
            </div>
        `;
    } else {
        // Show Facade for lazy loading
        const displayId = isPlaylist ? playlistId : parsedVideoId;
        const thumbnailUrl = isPlaylist
            ? 'https://images.unsplash.com/photo-1498050108023-c5249f4df085?auto=format&fit=crop&w=800&q=80' // Placeholder for playlist
            : `https://i.ytimg.com/vi/${parsedVideoId}/maxresdefault.jpg`;

        document.getElementById('videoModalBody').innerHTML = `
            <div class="video-facade" style="background-image: url('${thumbnailUrl}')" id="videoFacade">
                <div class="play-button-overlay">
                    <i class="fa-solid fa-${isPlaylist ? 'list' : 'play'}"></i>
                </div>
                ${isPlaylist ? '<div style="position:absolute; bottom:10px; right:10px; background:rgba(0,0,0,0.8); color:white; padding:4px 8px; border-radius:4px; font-size:0.8rem;"><i class="fa-solid fa-list"></i> PLAYLIST</div>' : ''}
                <div class="video-progress-container">
                    <div class="video-progress-bar" id="videoProgressBar"></div>
                </div>
            </div>
            <div id="playerContainer"></div>
        `;

        // Load video/playlist on facade click
        document.getElementById('videoFacade').addEventListener('click', () => {
            document.getElementById('videoFacade').style.display = 'none';
            // 3. Event listener memory leak - Ensure window.videoPlayerManager?.loadVideo() uses optional chaining
            window.videoPlayerManager?.loadVideo('playerContainer', displayId, {
                isPlaylist: isPlaylist,
                onProgress: (time, duration) => {
                    if (isPlaylist) return; // Don't track progress for the whole playlist as easily
                    const pct = (time / duration) * 100;
                    const bar = document.getElementById('videoProgressBar');
                    if (bar) bar.style.width = `${pct}%`;
                }
            });
        });
    }

    // Open with small delay
    setTimeout(() => overlay.classList.add('open'), 10);

    // Fetch additional info from our FastAPI backend
    if (!isSearch && !isPlaylist) {
        let videoUrl = '';
        if (queryOrUrl.includes('youtube.com/watch?v=')) {
            videoUrl = queryOrUrl;
        } else if (queryOrUrl.includes('youtu.be/')) {
            videoUrl = queryOrUrl;
        } else if (parsedVideoId) {
            videoUrl = `https://www.youtube.com/watch?v=${parsedVideoId}`;
        }

        if (videoUrl) {
            fetchVideoInfo(videoUrl);
        }
    }
}

async function fetchVideoInfo(url) {
    try {
        // 2. Hardcoded localhost + mixed content - Replace the base URL with a configurable constant
        const response = await fetch(`${API_BASE}/api/video/info`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ url })
        });

        if (response.ok) {
            const data = await response.json();
            updateVideoModalWithInfo(data);
        }
    } catch (e) {
        console.warn('FastAPI backend not reachable for video info:', e);
    }
}

function updateVideoModalWithInfo(info) {
    const modalContent = document.querySelector('.video-modal-content');
    if (!modalContent) return;

    // Add info sub-panel if not already there
    let infoPanel = document.getElementById('videoInfoPanel');
    if (!infoPanel) {
        infoPanel = document.createElement('div');
        infoPanel.id = 'videoInfoPanel';
        infoPanel.className = 'video-info-panel';
        modalContent.appendChild(infoPanel);
    }

    const durationMin = Math.floor(info.duration / 60);
    const durationSec = info.duration % 60;

    // Update progress bar on facade if it exists
    // 3. Event listener memory leak - Ensure window.videoPlayerManager?.getSavedProgress() uses optional chaining
    const vId = window.videoPlayerManager?.currentVideoId;
    const savedTime = window.videoPlayerManager?.getSavedProgress(vId);
    if (savedTime > 0 && info.duration > 0) {
        const pct = (savedTime / info.duration) * 100;
        const bar = document.getElementById('videoProgressBar');
        if (bar) bar.style.width = `${pct}%`;
    }

    // 1. XSS vulnerability - safe DOM construction using textContent
    infoPanel.innerHTML = '';

    const titleEl = document.createElement('h2');
    titleEl.className = 'video-info-title';
    titleEl.textContent = info.title;
    infoPanel.appendChild(titleEl);

    const metaEl = document.createElement('div');
    metaEl.className = 'video-info-meta';

    const uploaderSpan = document.createElement('span');
    uploaderSpan.innerHTML = '<i class="fa-solid fa-user"></i> ';
    uploaderSpan.appendChild(document.createTextNode(info.uploader));
    metaEl.appendChild(uploaderSpan);

    const viewsSpan = document.createElement('span');
    viewsSpan.innerHTML = '<i class="fa-solid fa-eye"></i> ';
    viewsSpan.appendChild(document.createTextNode(`${info.view_count.toLocaleString()} views`));
    metaEl.appendChild(viewsSpan);

    const clockSpan = document.createElement('span');
    clockSpan.innerHTML = '<i class="fa-solid fa-clock"></i> ';
    clockSpan.appendChild(document.createTextNode(`${durationMin}:${durationSec.toString().padStart(2, '0')}`));
    metaEl.appendChild(clockSpan);

    infoPanel.appendChild(metaEl);

    const descEl = document.createElement('div');
    descEl.className = 'video-info-description';
    const descParts = (info.description || '').split('\\n');
    descParts.forEach((part, index) => {
        descEl.appendChild(document.createTextNode(part));
        if (index < descParts.length - 1) {
            descEl.appendChild(document.createElement('br'));
        }
    });
    infoPanel.appendChild(descEl);
}

function closeVideoModal() {
    const overlay = document.getElementById('globalVideoModal');
    if (overlay) {
        overlay.classList.remove('open');

        // Remove Escape key listener
        if (overlay._handleEscape) {
            window.removeEventListener('keydown', overlay._handleEscape);
            delete overlay._handleEscape;
        }

        // Destroy player
        // 3. Event listener memory leak - Ensure window.videoPlayerManager?.destroy() uses optional chaining
        window.videoPlayerManager?.destroy();

        // Clear info panel if exists
        const infoPanel = document.getElementById('videoInfoPanel');
        if (infoPanel) infoPanel.remove();
    }
}

// ---- Graph Rendering ----
function renderMathGraph(elementId, graphData) {
    const target = document.getElementById(elementId);
    if (!target || !window.functionPlot) return;

    try {
        const width = target.offsetWidth || 500;
        const height = width * 0.6; // Responsive aspect ratio

        window.functionPlot({
            target: `#${elementId}`,
            width: width,
            height: height,
            grid: true,
            xAxis: { domain: graphData.domain || [-10, 10] },
            yAxis: { domain: graphData.yDomain || [-10, 10] },
            data: [{
                fn: graphData.fn,
                color: 'var(--primary)',
                graphType: 'polyline'
            }]
        });
    } catch (e) {
        console.error("Graph rendering failed:", e);
        target.innerHTML = `<div style="padding:1rem;color:var(--accent-red);border:1px solid var(--accent-red);border-radius:var(--radius-md);">Failed to render graph: ${e.message}</div>`;
    }
}
