var Cloudy = {
    isEpisodePage: function() {
        return $("#audioplayer").length == 1;
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
        webkit.messageHandlers.playbackHandler.postMessage({
            "is_playing": true
        });
    },

    playerDidPause: function() {
        webkit.messageHandlers.playbackHandler.postMessage({
            "is_playing": false
        });
    },

    togglePlaybackState: function() {
        var player = $("#audioplayer")[0];
        player.paused ? player.play() : player.pause();
    },

    installSpaceHandler: function() {
        $(window).keypress(function(event) {
            if (event.keyCode == 32) {
                event.preventDefault();
                Cloudy.togglePlaybackState();
            }
        });
    }
};

$(function() {
    if (Cloudy.isEpisodePage()) {
        Cloudy.installPlaybackHandlers();
        Cloudy.installSpaceHandler();
    }
    webkit.messageHandlers.episodeHandler.postMessage(Cloudy.getEpisodeDetails());
});
