{ config, lib, ... }:

{

  sops = lib.mkIf (config.programs.kodi.enable) {
    secrets = {
      "youtube/api-key" = { };
      "youtube/api-id" = { };
      "youtube/secret" = { };
    };

    templates = {
      "youtube-settings.xml" = {
        path = "${config.home.homeDirectory}/.kodi/userdata/addon_data/plugin.video.youtube/settings.xml";
        content = ''
          <settings version="2">
              <setting id="kodion.setup_wizard">false</setting>
              <setting id="kodion.setup_wizard.forced_runs">1767970800</setting>
              <setting id="kodion.mpd.videos" default="true">true</setting>
              <setting id="kodion.mpd.stream.select" default="true">3</setting>
              <setting id="kodion.mpd.quality.selection" default="true">4</setting>
              <setting id="kodion.video.stream.select" default="true">2</setting>
              <setting id="kodion.video.quality.ask" default="true">false</setting>
              <setting id="kodion.video.quality" default="true">3</setting>
              <setting id="kodion.mpd.stream.features">avc1,3d,vr,prefer_dub,prefer_auto_dub,mp4a,vtt,filter,alt_sort</setting>
              <setting id="kodion.audio_only" default="true">false</setting>
              <setting id="kodion.subtitle.languages.num">1</setting>
              <setting id="kodion.subtitle.download" default="true">false</setting>
              <setting id="kodion.content.max_per_page">10</setting>
              <setting id="youtube.view.hide_videos" default="true" />
              <setting id="kodion.safe.search" default="true">0</setting>
              <setting id="kodion.age.gate" default="true">true</setting>
              <setting id="youtube.api.id">${config.sops.placeholder."youtube/api-id"}</setting>
              <setting id="youtube.api.key">${config.sops.placeholder."youtube/api-key"}</setting>
              <setting id="youtube.api.secret">${config.sops.placeholder."youtube/secret"}</setting>
              <setting id="youtube.allow.dev.keys" default="true">true</setting>
              <setting id="youtube.api.config.page" default="true">false</setting>
              <setting id="youtube.folder.sign.in.show">false</setting>
              <setting id="youtube.folder.my_subscriptions.show">false</setting>
              <setting id="youtube.folder.my_subscriptions.sources">subscriptions,saved_playlists,bookmark_channels,bookmark_playlists</setting>
              <setting id="youtube.folder.my_subscriptions_filtered.show" default="true">false</setting>
              <setting id="youtube.filter.my_subscriptions_filtered.blacklist" default="true">false</setting>
              <setting id="youtube.filter.my_subscriptions_filtered.list" default="true" />
              <setting id="youtube.folder.recommendations.show" default="true">true</setting>
              <setting id="youtube.folder.related.show">false</setting>
              <setting id="youtube.folder.popular_right_now.show">false</setting>
              <setting id="youtube.folder.search.show" default="true">true</setting>
              <setting id="youtube.folder.quick_search.show" default="true">false</setting>
              <setting id="youtube.folder.quick_search_incognito.show" default="true">false</setting>
              <setting id="youtube.folder.my_location.show">false</setting>
              <setting id="youtube.folder.my_channel.show">false</setting>
              <setting id="youtube.folder.purchases.show" default="true">false</setting>
              <setting id="youtube.folder.watch_later.show">false</setting>
              <setting id="youtube.folder.watch_later.playlist" default="true" />
              <setting id="youtube.folder.liked_videos.show" default="true">true</setting>
              <setting id="youtube.folder.disliked_videos.show">false</setting>
              <setting id="youtube.folder.history.show" default="true">true</setting>
              <setting id="youtube.folder.history.playlist" default="true" />
              <setting id="youtube.folder.playlists.show">false</setting>
              <setting id="youtube.folder.saved.playlists.show" default="true">false</setting>
              <setting id="youtube.folder.subscriptions.show">false</setting>
              <setting id="youtube.folder.bookmarks.show">false</setting>
              <setting id="youtube.folder.browse_channels.show">false</setting>
              <setting id="youtube.folder.completed.live.show">false</setting>
              <setting id="youtube.folder.upcoming.live.show">false</setting>
              <setting id="youtube.folder.live.show">false</setting>
              <setting id="youtube.folder.switch.user.show">false</setting>
              <setting id="youtube.folder.sign.out.show">false</setting>
              <setting id="youtube.folder.settings.show">false</setting>
              <setting id="youtube.folder.settings.advanced.show" default="true">false</setting>
              <setting id="kodion.support.alternative_player" default="true">false</setting>
              <setting id="kodion.alternative_player.web_urls" default="true">false</setting>
              <setting id="kodion.alternative_player.mpd" default="true">false</setting>
              <setting id="kodion.default_player.web_urls" default="true">false</setting>
              <setting id="kodion.video.quality.isa" default="true">true</setting>
              <setting id="kodion.live_stream.selection.1" default="true">2</setting>
              <setting id="kodion.live_stream.selection.2" default="true">1</setting>
              <setting id="kodion.history.local" default="true">true</setting>
              <setting id="kodion.history.remote" default="true">false</setting>
              <setting id="kodion.cache.size" default="true">50</setting>
              <setting id="kodion.search.size" default="true">10</setting>
              <setting id="youtube.view.description.details">false</setting>
              <setting id="youtube.view.label.details">false</setting>
              <setting id="youtube.view.shorts.duration" default="true">60</setting>
              <setting id="youtube.view.filter.list" default="true" />
              <setting id="youtube.view.channel_name.aliases" default="true">cast</setting>
              <setting id="youtube.view.label.color.viewCount" default="true">ffadd8e6</setting>
              <setting id="youtube.view.label.color.likeCount" default="true">ff00ff00</setting>
              <setting id="youtube.view.label.color.commentCount" default="true">ff00ffff</setting>
              <setting id="kodion.thumbnail.size" default="true">1</setting>
              <setting id="kodion.fanart.selection" default="true">2</setting>
              <setting id="youtube.language">ru</setting>
              <setting id="youtube.region">ES</setting>
              <setting id="youtube.location">37.8184,-1.0788</setting>
              <setting id="youtube.location.radius" default="true">500</setting>
              <setting id="kodion.play_count.percent" default="true">90</setting>
              <setting id="youtube.suggested_videos" default="true">false</setting>
              <setting id="youtube.playlist.watchlater.autoremove" default="true">true</setting>
              <setting id="youtube.post.play.rate" default="true">false</setting>
              <setting id="youtube.post.play.rate.playlists" default="true">false</setting>
              <setting id="youtube.post.play.refresh" default="true">false</setting>
              <setting id="requests.ssl.verify" default="true">true</setting>
              <setting id="requests.timeout.connect" default="true">9</setting>
              <setting id="requests.timeout.read" default="true">27</setting>
              <setting id="requests.cache.size" default="true">20</setting>
              <setting id="requests.proxy.source" default="true">1</setting>
              <setting id="requests.proxy.enabled" default="true">false</setting>
              <setting id="requests.proxy.type" default="true">0</setting>
              <setting id="requests.proxy.server" default="true" />
              <setting id="requests.proxy.port" default="true">8080</setting>
              <setting id="requests.proxy.username" default="true" />
              <setting id="requests.proxy.password" default="true" />
              <setting id="kodion.http.listen">0.0.0.0</setting>
              <setting id="kodion.http.port" default="true">50152</setting>
              <setting id="kodion.http.ip.whitelist" default="true" />
              <setting id="youtube.http.idle_sleep" default="true">true</setting>
              <setting id="youtube.http.stream_redirect" default="true">false</setting>
              <setting id="kodion.debug.log.level" default="true">0</setting>
              <setting id="kodion.debug.exec.limit" default="true">0</setting>
              <setting id="|end_settings_marker|">true</setting>
          </settings>
        '';
      };
    };
  };
}
