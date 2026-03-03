(function () {
    "use strict";

    /**
     * Skillz Sidebar Module
     * Handles collapsing, active states, and sections.
     */
    const SkillzSidebar = {
        init() {
            this.sidebar = document.getElementById('skillzSidebar');
            this.toggleBtn = document.getElementById('sidebarToggle');
            this.navItems = document.querySelectorAll('.nav-item');
            this.collapsibleTriggers = document.querySelectorAll('.collapsible-trigger');

            if (!this.sidebar) return;

            this.bindEvents();
            this.checkActiveState();
        },

        bindEvents() {
            // Sidebar Expand/Collapse
            if (this.toggleBtn) {
                this.toggleBtn.addEventListener('click', () => {
                    if (window.innerWidth <= 768) {
                        this.sidebar.classList.toggle('mobile-open');
                    } else {
                        this.sidebar.classList.toggle('collapsed');
                        localStorage.setItem('sidebar_collapsed', this.sidebar.classList.contains('collapsed'));
                    }
                });
            }

            // Restore state
            if (localStorage.getItem('sidebar_collapsed') === 'true') {
                this.sidebar.classList.add('collapsed');
            }

            // Nav Item Click
            this.navItems.forEach(item => {
                item.addEventListener('click', (e) => {
                    if (item.getAttribute('href') === '#') {
                        e.preventDefault();
                        this.setActive(item);

                        // Emit event for view switching if needed
                        const view = item.dataset.view;
                        if (view) {
                            document.dispatchEvent(new CustomEvent('skillz-view-change', { detail: { view } }));
                        }
                    }
                });
            });

            // Collapsible Sections
            this.collapsibleTriggers.forEach(trigger => {
                trigger.addEventListener('click', () => {
                    const section = trigger.closest('.nav-section');
                    section.classList.toggle('open');
                });
            });
        },

        setActive(clickedItem) {
            this.navItems.forEach(item => item.classList.remove('active'));
            clickedItem.classList.add('active');
        },

        checkActiveState() {
            const currentPath = window.location.pathname.split('/').pop();
            this.navItems.forEach(item => {
                if (item.getAttribute('href') === currentPath) {
                    item.classList.add('active');
                }
            });
        }
    };

    // Initialize on DOM load
    document.addEventListener('DOMContentLoaded', () => {
        SkillzSidebar.init();
    });

    // Make it available globally if needed
    window.SkillzSidebar = SkillzSidebar;

})();
