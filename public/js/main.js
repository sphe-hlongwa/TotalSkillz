/* ============================================
   Total Skill - Core JavaScript
   ============================================ */

// ---- Theme ----
function getTheme() {
    return localStorage.getItem('mg12_theme') || 'light';
}
function setTheme(theme) {
    const isAuthPage = window.location.pathname.endsWith('index.html') || window.location.pathname === '/' || window.location.pathname.includes('index.html');
    if (isAuthPage) {
        document.body.setAttribute('data-theme', 'dark');
    } else {
        document.body.setAttribute('data-theme', theme);
    }
    localStorage.setItem('mg12_theme', theme);
    updateThemeToggleIcon(theme);
}

function updateThemeToggleIcon(theme) {
    const btn = document.getElementById('headerThemeToggle');
    if (btn) {
        const icon = btn.querySelector('i');
        icon.className = theme === 'dark' ? 'fa-solid fa-sun' : 'fa-solid fa-moon';
    }
}
function toggleTheme() {
    const current = getTheme();
    const next = current === 'dark' ? 'light' : 'dark';
    setTheme(next);
}

// ---- Auth helpers ----
function getUser() {
    // Firebase manages user state globally via auth.currentUser
    const user = window.mg12_auth ? window.mg12_auth.currentUser : null;
    if (user) {
        return { name: user.displayName || 'User', email: user.email, uid: user.uid };
    }
    // Fallback to legacy check during migration
    const u = localStorage.getItem('mg12_user');
    return u ? JSON.parse(u) : null;
}
function setUser(user) {
    // This is now handled by Firebase Auth state changes
    if (user) localStorage.setItem('mg12_user', JSON.stringify(user));
    else localStorage.removeItem('mg12_user');
}
function logout() {
    if (window.mg12_auth) {
        window.mg12_auth.signOut().then(() => {
            localStorage.removeItem('mg12_user');
            window.location.href = 'index.html';
        });
    } else {
        localStorage.removeItem('mg12_user');
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
        dailyDone: false,
        bio: '',
        settings: {
            theme: 'light',
            dailyGoal: 10,
            publicProfile: true
        }
    };
}

function getProgress() {
    const p = localStorage.getItem('mg12_progress');
    if (!p) return getInitialProgress();
    const data = JSON.parse(p);
    // Ensure new fields exist
    if (!data.settings) data.settings = getInitialProgress().settings;
    if (data.bio === undefined) data.bio = '';
    return data;
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
                <p style="font-size:0.75rem; color:var(--text-muted);">MathGrade12 v2.4.0 • Built with <i class="fa-solid fa-heart" style="color:var(--accent-red);"></i></p>
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

function toggleDarkTheme(isDark) {
    const theme = isDark ? 'dark' : 'light';
    setTheme(theme); // this sets DOM attribute, local storage, and the toggle icon

    const p = getProgress();
    if (!p.settings) p.settings = {};
    p.settings.theme = theme;
    saveProgress(p);
}

function toggleThemeManually() {
    const current = document.body.getAttribute('data-theme') || 'light';
    const next = current === 'dark' ? 'light' : 'dark';
    toggleDarkTheme(next === 'dark');
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
    a.download = `MathGrade12_Progress_${new Date().toISOString().split('T')[0]}.json`;
    a.click();
    showToast('Progress exported!', 'success');
}

function confirmResetProgress() {
    const conf = confirm("Are you sure you want to reset all your learning progress? This cannot be undone.");
    if (conf) {
        const check = prompt("Type 'RESET' to confirm:");
        if (check === 'RESET') {
            const fresh = getInitialProgress();
            saveProgress(fresh);
            showToast('Progress reset successfully.', 'success');
            setTimeout(() => location.reload(), 1500);
        }
    }
}

async function confirmDeleteAccount() {
    const conf = confirm("CRITICAL: This will permanently delete your account and all progress. Are you absolutely sure?");
    if (conf) {
        const check = prompt("Type your email to confirm deletion:");
        const user = firebase.auth().currentUser;
        if (check === user?.email) {
            try {
                await user.delete();
                localStorage.clear();
                window.location.href = 'index.html';
            } catch (error) {
                showToast('Please re-login to complete sensitive action.', 'error');
                console.error(error);
            }
        }
    }
}

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
                <button type="button" class="profile-modal__manage-btn" onclick="toggleSettingsOverlay()">Manage your
                    Skillz Account</button>
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
}

async function handleProfilePic(input) {
    if (input.files && input.files[0]) {
        const file = input.files[0];
        // Compress image on the client side so Base64 is tiny enough for Firebase Auth
        const reader = new FileReader();
        reader.onload = (e) => {
            const img = new Image();
            img.onload = async () => {
                const canvas = document.createElement('canvas');
                const MAX_WIDTH = 150;
                const MAX_HEIGHT = 150;
                let width = img.width;
                let height = img.height;

                if (width > height) {
                    if (width > MAX_WIDTH) {
                        height *= MAX_WIDTH / width;
                        width = MAX_WIDTH;
                    }
                } else {
                    if (height > MAX_HEIGHT) {
                        width *= MAX_HEIGHT / height;
                        height = MAX_HEIGHT;
                    }
                }
                canvas.width = width;
                canvas.height = height;
                const ctx = canvas.getContext('2d');
                ctx.drawImage(img, 0, 0, width, height);
                const compressedBase64 = canvas.toDataURL('image/jpeg', 0.8);

                const user = firebase.auth().currentUser;
                if (user) {
                    try {
                        await user.updateProfile({ photoURL: compressedBase64 });
                        showToast('Profile picture updated!', 'success');
                        populateProfileModal();
                        document.querySelectorAll('.user-avatar').forEach(av => {
                            av.innerHTML = `<img src="${compressedBase64}" style="width:100%; height:100%; object-fit:cover; border-radius:50%;">`;
                            av.style.background = 'transparent';
                        });

                        const p = getProgress();
                        saveProgress(p);
                    } catch (error) {
                        console.error("Profile update error:", error);
                        showToast('Failed to update profile picture.', 'error');
                    }
                }
            };
            img.src = e.target.result;
        };
        reader.readAsDataURL(file);
    }
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
    sessionStorage.setItem('mg12_verify_dismissed', 'true');
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
            avatarEl.style.background = 'linear-gradient(135deg, var(--primary), var(--accent-purple))';
        }
    }

    if (greetingEl) greetingEl.textContent = `Hi, ${name.split(' ')[0]}!`;

    // Show verification alert if email not verified
    if (alertEl) {
        const isDismissed = sessionStorage.getItem('mg12_verify_dismissed');
        if (user.email && !user.emailVerified && !isDismissed) {
            alertEl.style.display = 'flex';
        } else {
            alertEl.style.display = 'none';
        }
    }
}


function updateAccountList(user) {
    if (!user) return;
    let accounts = JSON.parse(localStorage.getItem('mg12_accounts') || '[]');
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
    localStorage.setItem('mg12_accounts', JSON.stringify(accounts.slice(0, 5)));
}

function renderAccountList() {
    const container = document.getElementById('modalAccountsList');
    if (!container) return;

    const accounts = JSON.parse(localStorage.getItem('mg12_accounts') || '[]');
    const currentUser = firebase.auth().currentUser;

    // Filter out current user from the list (they are shown in header)
    const otherAccounts = accounts.filter(a => a.uid !== (currentUser ? currentUser.uid : null));

    let html = otherAccounts.map(a => `
        <div class="profile-modal__account-item" onclick="switchAccount('${a.uid}')">
            <div class="profile-modal__account-avatar" style="background:var(--primary-pale); color:var(--primary);">
                ${a.photoURL ? `<img src="${a.photoURL}" style="width:100%; height:100%; object-fit:cover; border-radius:50%;">` : getInitials(a.name)}
            </div>
            <div class="profile-modal__account-info">
                <div class="profile-modal__account-name">${a.name}</div>
                <div class="profile-modal__account-email">${a.email}</div>
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
async function saveProgress(data) {
    const user = firebase.auth().currentUser;
    localStorage.setItem('mg12_progress', JSON.stringify(data));

    if (user) {
        try {
            await firebase.firestore().collection('users').doc(user.uid).set({
                progress: data,
                lastUpdated: firebase.firestore.FieldValue.serverTimestamp()
            }, { merge: true });
        } catch (error) {
            console.error("Error saving progress to Firestore:", error);
        }
    }
}

async function syncFromFirestore(uid) {
    try {
        const doc = await firebase.firestore().collection('users').doc(uid).get();
        if (doc.exists && doc.data().progress) {
            const data = doc.data().progress;
            localStorage.setItem('mg12_progress', JSON.stringify(data));
            return data;
        }
    } catch (error) {
        console.error("Error syncing from Firestore:", error);
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
    p.dailyDone = false;
    saveProgress(p);
    return p;
}

function recordAnswer(topic, correct) {
    const p = getProgress();
    if (!p.topics[topic]) p.topics[topic] = { correct: 0, total: 0, level: 0 };
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

    // Migration: Move legacy 'userProgress' to 'mg12_progress'
    const legacyProgress = localStorage.getItem('userProgress');
    if (legacyProgress && !localStorage.getItem('mg12_progress')) {
        localStorage.setItem('mg12_progress', legacyProgress);
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
            console.log("Authenticated as:", user.email || user.phoneNumber);

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
                    av.style.background = 'linear-gradient(135deg, var(--primary), var(--accent-purple))';
                }
                av.style.display = 'flex';
                av.style.alignItems = 'center';
                av.style.justifyContent = 'center';
                av.style.color = 'white';
                av.style.fontWeight = '700';
                av.style.fontSize = '0.8rem';
            });

            // Sync progress
            const syncedData = await syncFromFirestore(user.uid);
            if (syncedData && syncedData.settings?.theme) {
                setTheme(syncedData.settings.theme);
            }
            updateAccountList(user);

            if (isIndex && !window.location.search.includes('action=add_account')) {
                window.location.href = 'dashboard.html';
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
