/* ============================================
   Total Skill - Core JavaScript
   ============================================ */

// ---- Theme ----
function getTheme() {
    return localStorage.getItem('mg12_theme') || 'light';
}
function setTheme(theme) {
    document.body.setAttribute('data-theme', theme);
    localStorage.setItem('mg12_theme', theme);
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
async function handleForgotPassword(e) {
    e.preventDefault();
    const email = document.getElementById('forgotEmail').value;
    const emailErr = document.getElementById('forgotEmailErr');

    if (!validateEmail(email)) {
        emailErr.style.display = 'block';
        return;
    }
    emailErr.style.display = 'none';

    try {
        await firebase.auth().sendPasswordResetEmail(email);
        showToast('Password reset link sent to your email!', 'success');
        showPanel('loginPanel');
    } catch (error) {
        console.error("Reset error:", error);
        showToast('Failed to send reset link. ' + error.message, 'error');
    }
}

// --- Settings Logic ---
function toggleSettingsOverlay() {
    const overlay = document.getElementById('settingsOverlay');
    if (!overlay) return;
    const isActive = overlay.classList.contains('active');

    if (!isActive) {
        overlay.style.display = 'flex';
        overlay.offsetHeight;
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
    document.body.setAttribute('data-theme', theme);
    localStorage.setItem('mg12_theme', theme);

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
            location.reload();
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
function toggleProfileModal() {
    const overlay = document.getElementById('profileModalOverlay');
    if (!overlay) return;
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
    const initials = name.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2);

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

async function handleProfilePic(input) {
    if (input.files && input.files[0]) {
        const file = input.files[0];
        if (file.size > 1024 * 1024) { // 1MB limit for Base64
            showToast('Image too large. Please select an image under 1MB.', 'error');
            return;
        }

        const reader = new FileReader();
        reader.onload = async (e) => {
            const base64 = e.target.result;
            const user = firebase.auth().currentUser;
            if (user) {
                try {
                    await user.updateProfile({ photoURL: base64 });
                    showToast('Profile picture updated!', 'success');
                    populateProfileModal();
                    // Update all avatars on page
                    document.querySelectorAll('.user-avatar').forEach(av => {
                        av.innerHTML = `<img src="${base64}" style="width:100%; height:100%; object-fit:cover; border-radius:50%;">`;
                        av.style.background = 'transparent';
                    });
                } catch (error) {
                    console.error("Error updating profile pic:", error);
                    showToast('Failed to update profile picture.', 'error');
                }
            }
        };
        reader.readAsDataURL(file);
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
            const initials = name.split(' ').map(n => n[0]).join('').toUpperCase().substring(0, 2);

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
});
