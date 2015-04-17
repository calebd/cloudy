var Cloudy = {
    isEpisodePage: function() {
        return $("#audioplayer").length == 1;
    },

    sendEpisodeToCloudy: function() {
        var episodeTitle = $(".titlestack .title").text();
        var showTitle = $(".titlestack .caption2").text();

        var details = {
            "show_title": showTitle,
            "episode_title": episodeTitle
        };

        webkit.messageHandlers.episodeHandler.postMessage(details);
    },

    installPlaybackHandlers: function() {
        var player = $("#audioplayer")[0];
        player.addEventListener("play", Cloudy.playerDidPlay);
        player.addEventListener("pause", Cloudy.playerDidPause);
    },

    playerDidPlay: function() {
        webkit.messageHandlers.playbackHandler.postMessage({
            "playing": true
        });
    },

    playerDidPause: function() {
        webkit.messageHandlers.playbackHandler.postMessage({
            "playing": false
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
        Cloudy.sendEpisodeToCloudy();
    }
    else {
        webkit.messageHandlers.episodeHandler.postMessage(null);
    }
});
