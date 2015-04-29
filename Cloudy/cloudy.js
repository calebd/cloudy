var Cloudy = {
    isEpisodePage: function() {
        return $("#audioplayer").length == 1;
    },

    isIndexPage: function() {
        return location.href == "https://overcast.fm/podcasts";
    },

    getEpisodeDetails: function() {
        if (!Cloudy.isEpisodePage()) {
            return null;
        }
        var episodeTitle = $(".titlestack .title").text();
        var showTitle = $(".titlestack .caption2").text();
        return {
            show_title: showTitle,
            episode_title: episodeTitle
        };
    },

    installPlaybackHandlers: function() {
        var player = $("#audioplayer")[0];
        player.addEventListener("play", Cloudy.playerDidPlay);
        player.addEventListener("pause", Cloudy.playerDidPause);
    },

    playerDidPlay: function() {
        webkit.messageHandlers.playbackHandler.postMessage(true);
    },

    playerDidPause: function() {
        webkit.messageHandlers.playbackHandler.postMessage(false);
    },

    togglePlaybackState: function() {
        if (!Cloudy.isEpisodePage()) {
            return;
        }
        var player = $("#audioplayer")[0];
        player.paused ? player.play() : player.pause();
    },

    installSpaceBarHandler: function() {
        $(window).keypress(function(event) {
            if (event.keyCode == 32) {
                event.preventDefault();
                Cloudy.togglePlaybackState();
            }
        });
    },

    getNumberOfUnplayedEpisodes: function() {
        if (Cloudy.isIndexPage()) {
            return $("a[href^=\\/\\+]").length;
        }
        return null;
    },

    setup: function() {
        if (Cloudy.isEpisodePage()) {
            Cloudy.installPlaybackHandlers();
            Cloudy.installSpaceBarHandler();
        }

        $(".nav").css({ display: "none" });

        webkit.messageHandlers.episodeHandler.postMessage(Cloudy.getEpisodeDetails());
        webkit.messageHandlers.unplayedEpisodeCountHandler.postMessage(Cloudy.getNumberOfUnplayedEpisodes());
    }
};

$(Cloudy.setup());
$(window).unload(function() {});
