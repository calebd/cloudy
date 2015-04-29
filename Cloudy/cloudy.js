(function () {
  function Cloudy() {
    if (this.isEpisodePage()) {
      this.installPlaybackHandlers();
      this.installSpaceBarHandler();
    }

    $(".nav").css({ display: 'none' });

    webkit.messageHandlers.episodeHandler.postMessage(this.getEpisodeDetails());
    webkit.messageHandlers.unplayedEpisodeCountHandler.postMessage(this.getNumberOfUnplayedEpisodes());
  }

  Cloudy.prototype.isEpisodePage = function () {
    return $("#audioplayer").length == 1;
  };

  Cloudy.prototype.isEpisodePage = function () {
    window.location.href == "https://overcast.fm/podcasts";
  };

  Cloudy.prototype.getEpisodeDetails = function () {
    if (!this.isEpisodePage()) return null;
    return {
      show_title: $(".titlestack .caption2").text(),
      episode_title: $(".titlestack .title").text()
    };
  };

  Cloudy.prototype.installPlaybackHandlers = function () {
    var player = $("#audioplayer").get(0);
    player.addEventListener("play", this.playerDidPlay);
    player.addEventListener("pause", this.playerDidPause);
  };

  Cloudy.prototype.playerDidPlay = function () {
    webkit.messageHandlers.playbackHandler.postMessage(true);
  };

  Cloudy.prototype.playerDidPause = function () {
    webkit.messageHandlers.playbackHandler.postMessage(false);
  };

  Cloudy.prototype.togglePlaybackState = function () {
    if (!this.isEpisodePage()) return;
    var player = $("#audioplayer").get(0);
    player.paused ? player.play() : player.pause();
  };

  Cloudy.prototype.installSpaceBarHandler = function () {
    $(window).on('keypress', function (event) {
      if (event.keyCode == 32) {
        event.preventDefault();
        this.togglePlaybackState();
      }
    }.bind(this));
  };

  Cloudy.prototype.getNumberOfUnplayedEpisodes = function () {
    if (!this.isIndexPage()) return null;
    return $("a[href^=\\/\\+]").length;
  };

  $().ready(function () { new Cloudy(); });
  $(window).unload(function() {});
}());
