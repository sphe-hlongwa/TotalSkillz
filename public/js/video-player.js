/**
 * Professional YouTube Video Player implementation
 * Handles IFrame API, progress tracking, and lazy-loading facades.
 */
class VideoPlayer {
    constructor() {
        this.player = null;
        this.currentVideoId = null;
        this.progressInterval = null;
        this.isApiLoaded = false;
        this.onReadyCallback = null;
        this.onProgressCallback = null;
    }

    /**
     * Initializes the YouTube IFrame API if not already loaded.
     */
    async initApi() {
        if (this.isApiLoaded || window.YT) {
            this.isApiLoaded = true;
            return Promise.resolve();
        }

        return new Promise((resolve) => {
            const tag = document.createElement('script');
            tag.src = "https://www.youtube.com/iframe_api";
            const firstScriptTag = document.getElementsByTagName('script')[0];
            firstScriptTag.parentNode.insertBefore(tag, firstScriptTag);

            window.onYouTubeIframeAPIReady = () => {
                this.isApiLoaded = true;
                console.log("YouTube IFrame API Ready");
                resolve();
            };
        });
    }

    /**
     * Creates or reloads a player for a specific video ID or Playlist ID.
     * @param {string} containerId - The ID of the element to replace.
     * @param {string} id - The YouTube video ID or Playlist ID.
     * @param {Object} options - Additional player options (isPlaylist: boolean).
     */
    async loadVideo(containerId, id, options = {}) {
        await this.initApi();
        
        const isPlaylist = options.isPlaylist || false;
        this.currentVideoId = isPlaylist ? null : id;
        this.currentPlaylistId = isPlaylist ? id : null;
        
        const playerVars = {
            'autoplay': 1,
            'modestbranding': 1,
            'rel': 0,
            'fs': 1,
            'origin': window.location.origin
        };

        if (isPlaylist) {
            playerVars.listType = 'playlist';
            playerVars.list = id;
        } else {
            const savedTime = this.getSavedProgress(id);
            playerVars.start = Math.floor(options.resume !== false ? savedTime : 0);
        }

        if (this.player && typeof this.player.loadVideoById === 'function' && !isPlaylist) {
            this.player.loadVideoById({
                videoId: id,
                startSeconds: playerVars.start
            });
            return;
        }

        // If it's a playlist or player doesn't exist, we must (re)create it
        if (this.player) this.destroy();

        return new Promise((resolve) => {
            this.player = new YT.Player(containerId, {
                height: '100%',
                width: '100%',
                videoId: isPlaylist ? null : id,
                playerVars: playerVars,
                events: {
                    'onReady': (event) => {
                        this.handlePlayerReady(event);
                        if (options.onReady) options.onReady(event);
                        resolve(event);
                    },
                    'onStateChange': (event) => {
                        this.handlePlayerStateChange(event);
                        if (options.onStateChange) options.onStateChange(event);
                    },
                    'onError': (event) => {
                        console.error("YouTube Player Error:", event.data);
                        if (options.onError) options.onError(event);
                    }
                }
            });
            if (options.onProgress) this.onProgressCallback = options.onProgress;
        });
    }

    handlePlayerReady(event) {
        console.log("Player Ready for:", this.currentVideoId);
    }

    handlePlayerStateChange(event) {
        if (event.data === YT.PlayerState.PLAYING) {
            this.startProgressTracking();
        } else {
            this.stopProgressTracking();
        }

        if (event.data === YT.PlayerState.ENDED) {
            this.saveProgress(this.currentVideoId, 0); // Mark as completed
        }
    }

    startProgressTracking() {
        if (this.progressInterval) return;
        
        this.progressInterval = setInterval(() => {
            if (this.player && this.player.getCurrentTime) {
                const currentTime = this.player.getCurrentTime();
                const duration = this.player.getDuration();
                this.saveProgress(this.currentVideoId, currentTime);
                
                if (this.onProgressCallback) {
                    this.onProgressCallback(currentTime, duration);
                }
            }
        }, 2000); // Save every 2 seconds
    }

    stopProgressTracking() {
        if (this.progressInterval) {
            clearInterval(this.progressInterval);
            this.progressInterval = null;
        }
    }

    saveProgress(videoId, time) {
        if (!videoId) return;
        const progress = JSON.parse(localStorage.getItem('yt_watch_progress') || '{}');
        progress[videoId] = {
            time: time,
            updatedAt: Date.now()
        };
        localStorage.setItem('yt_watch_progress', JSON.stringify(progress));
        
        // Optionally sync to Firestore here if user is logged in
        this.syncProgressToFirestore(videoId, time);
    }

    getSavedProgress(videoId) {
        const progress = JSON.parse(localStorage.getItem('yt_watch_progress') || '{}');
        return progress[videoId] ? progress[videoId].time : 0;
    }

    async syncProgressToFirestore(videoId, time) {
        if (typeof window.getUser === 'function' && window.getUser() && window.db) {
            const user = window.getUser();
            try {
                await db.collection('users').doc(user.uid).collection('videoProgress').doc(videoId).set({
                    time: time,
                    updatedAt: firebase.firestore.FieldValue.serverTimestamp()
                }, { merge: true });
            } catch (e) {
                console.warn("Failed to sync progress to Firestore:", e);
            }
        }
    }

    destroy() {
        this.stopProgressTracking();
        if (this.player && typeof this.player.destroy === 'function') {
            this.player.destroy();
            this.player = null;
        }
    }
}

// Global instance
window.videoPlayerManager = new VideoPlayer();
