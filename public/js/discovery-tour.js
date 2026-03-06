/**
 * discovery-tour.js
 * An interactive, vanilla JS "Spotlight" tour for TotalSkillz new users.
 */

class DiscoveryTour {
    constructor() {
        this.currentStep = 0;
        this.steps = [
            {
                title: "Welcome to TotalSkillz!",
                icon: "fa-solid fa-graduation-cap",
                body: "This is your path to a Math Distinction. This quick tour will show you the tools to master Grade 12 Math.",
                target: null // Centered
            },
            {
                title: "Your Navigation Hub",
                icon: "fa-solid fa-bars",
                body: "Use the sidebar to jump between Lessons, Practice, and Exams. The live classes and examiner mode are here too!",
                target: "#sidebarToggle"
            },
            {
                title: "Track Your Progress",
                icon: "fa-solid fa-chart-line",
                body: "Monitor your accuracy and badges in real-time. We keep track of every question you attempt so you can focus on weak areas.",
                target: ".stats-panel"
            },
            {
                title: "The Question Bank",
                icon: "fa-solid fa-dumbbell",
                body: "Select a topic to start practicing. Each topic in our grid has 300+ questions and a dedicated Mastery Workshop.",
                target: "#topicsGrid"
            },
            {
                title: "Daily Challenges",
                icon: "fa-solid fa-bolt",
                body: "Consistency wins. Tackle the 1-minute daily challenge to keep your streak alive and earn exclusive badges.",
                target: "#dailyCard"
            },
            {
                title: "Your Personal Cloud",
                icon: "fa-solid fa-cloud-arrow-up",
                body: "Click your avatar to sync your stats. Study on your phone or laptop, your progress follows you everywhere.",
                target: "#userAvatar"
            }
        ];

        this.overlay = null;
        this.svg = null;
        this.tooltip = null;
    }

    init() {
        // Only run if not completed
        if (localStorage.getItem('discovery_tour_completed')) return;

        // Create overlay components
        this.createOverlay();
        this.createTooltip();

        window.addEventListener('resize', () => this.updateSpotlight());
        this.start();
    }

    createOverlay() {
        // SVG Mask Overlay
        this.overlay = document.createElement('div');
        this.overlay.className = 'tour-overlay-wrapper';
        this.overlay.innerHTML = `
            <svg class="tour-mask" width="100%" height="100%">
                <defs>
                    <mask id="tour-spotlight-mask">
                        <rect width="100%" height="100%" fill="white" />
                        <rect id="tour-spotlight-hole" x="0" y="0" width="0" height="0" rx="10" fill="black" />
                    </mask>
                </defs>
                <rect width="100%" height="100%" fill="rgba(0,0,0,0.8)" mask="url(#tour-spotlight-mask)" />
            </svg>
        `;
        document.body.appendChild(this.overlay);
        this.svgHole = document.getElementById('tour-spotlight-hole');
    }

    createTooltip() {
        this.tooltip = document.createElement('div');
        this.tooltip.className = 'tour-tooltip';
        document.body.appendChild(this.tooltip);
    }

    start() {
        this.showStep(0);
    }

    showStep(index) {
        this.currentStep = index;
        const step = this.steps[index];
        const isLast = index === this.steps.length - 1;

        this.tooltip.innerHTML = `
            <div class="tour-tooltip__header">
                <div class="tour-tooltip__icon"><i class="${step.icon}"></i></div>
                <div class="tour-tooltip__title">${step.title}</div>
            </div>
            <div class="tour-tooltip__body">${step.body}</div>
            <div class="tour-tooltip__footer">
                <div class="tour-tooltip__step">Step ${index + 1} of ${this.steps.length}</div>
                <div class="tour-btns">
                    <button class="btn btn-secondary btn-sm" onclick="discoveryTour.skip()">Skip</button>
                    <button class="btn btn-primary btn-sm" onclick="discoveryTour.next()">${isLast ? 'Finish' : 'Next'}</button>
                </div>
            </div>
        `;

        this.updateSpotlight();
        this.tooltip.classList.add('visible');
    }

    updateSpotlight() {
        const step = this.steps[this.currentStep];
        const padding = 10;

        // Clear previous highlight
        document.querySelectorAll('.tour-highlight').forEach(el => el.classList.remove('tour-highlight'));

        if (!step.target) {
            // Centered (Introduction)
            this.svgHole.setAttribute('width', '0');
            this.svgHole.setAttribute('height', '0');
            this.tooltip.style.top = '50%';
            this.tooltip.style.left = '50%';
            this.tooltip.style.transform = 'translate(-50%, -50%)';
        } else {
            const targetEl = document.querySelector(step.target);
            if (targetEl) {
                // Force visibility if it has the 'reveal' class
                if (targetEl.classList.contains('reveal')) {
                    targetEl.classList.add('visible');
                }
                targetEl.scrollIntoView({ behavior: 'smooth', block: 'center' });

                // Add a slightly longer delay (500ms) for smooth scroll to finalize
                setTimeout(() => {
                    const rect = targetEl.getBoundingClientRect();
                    targetEl.classList.add('tour-highlight');

                    this.svgHole.setAttribute('x', rect.left - padding);
                    this.svgHole.setAttribute('y', rect.top - padding);
                    this.svgHole.setAttribute('width', rect.width + (padding * 2));
                    this.svgHole.setAttribute('height', rect.height + (padding * 2));

                    // Position tooltip
                    const tooltipRect = this.tooltip.getBoundingClientRect();
                    let top = rect.bottom + 20;
                    let left = rect.left + (rect.width / 2) - (tooltipRect.width / 2);

                    // Bounds check
                    if (top + tooltipRect.height > window.innerHeight) {
                        top = rect.top - tooltipRect.height - 20;
                    }
                    if (top < 10) top = 10;
                    if (left < 10) left = 10;
                    if (left + tooltipRect.width > window.innerWidth) {
                        left = window.innerWidth - tooltipRect.width - 10;
                    }

                    this.tooltip.style.top = top + 'px';
                    this.tooltip.style.left = left + 'px';
                    this.tooltip.style.transform = 'none';
                }, 500);
            }
        }
    }

    next() {
        if (this.currentStep < this.steps.length - 1) {
            this.showStep(this.currentStep + 1);
        } else {
            this.finish();
        }
    }

    skip() {
        this.finish();
    }

    finish() {
        this.overlay.remove();
        this.tooltip.remove();
        localStorage.setItem('discovery_tour_completed', 'true');
        document.querySelectorAll('.tour-highlight').forEach(el => el.classList.remove('tour-highlight'));
    }
}

// Global instance
const discoveryTour = new DiscoveryTour();

// Auto-init helper
function triggerDiscoveryTour() {
    discoveryTour.init();
}
