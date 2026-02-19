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
            <setting id="kodion.age.gate">true</setting>
            <setting id="kodion.alternative_player.mpd">false</setting>
            <setting id="kodion.alternative_player.web_urls">false</setting>
            <setting id="kodion.audio_only">false</setting>
            <setting id="kodion.cache.size">50</setting>
            <setting id="kodion.content.max_per_page">10</setting>
            <setting id="kodion.debug.exec.limit">0</setting>
            <setting id="kodion.debug.log.level">0</setting>
            <setting id="kodion.default_player.web_urls">false</setting>
            <setting id="kodion.fanart.selection">2</setting>
            <setting id="kodion.history.local">true</setting>
            <setting id="kodion.history.remote">false</setting>
            <setting id="kodion.http.ip.whitelist"/>
            <setting id="kodion.http.listen">127.0.0.1</setting>
            <setting id="kodion.http.port">50152</setting>
            <setting id="kodion.live_stream.selection.1">2</setting>
            <setting id="kodion.live_stream.selection.2">1</setting>
            <setting id="kodion.mpd.quality.selection">3</setting>
            <setting id="kodion.mpd.stream.features">avc1,3d,vr,prefer_dub,prefer_auto_dub,mp4a,vtt,filter,alt_sort</setting>
            <setting id="kodion.mpd.stream.select">3</setting>
            <setting id="kodion.mpd.videos">true</setting>
            <setting id="kodion.play_count.percent">90</setting>
            <setting id="kodion.safe.search">0</setting>
            <setting id="kodion.search.size">10</setting>
            <setting id="kodion.setup_wizard">false</setting>
            <setting id="kodion.setup_wizard.forced_runs">1767970800</setting>
            <setting id="kodion.subtitle.download">false</setting>
            <setting id="kodion.subtitle.languages.num">5</setting>
            <setting id="kodion.support.alternative_player">false</setting>
            <setting id="kodion.thumbnail.size">1</setting>
            <setting id="kodion.video.quality">3</setting>
            <setting id="kodion.video.quality.ask">false</setting>
            <setting id="kodion.video.quality.isa">true</setting>
            <setting id="kodion.video.stream.select">2</setting>
            <setting id="requests.cache.size">20</setting>
            <setting id="requests.proxy.enabled">false</setting>
            <setting id="requests.proxy.password"/>
            <setting id="requests.proxy.port">8080</setting>
            <setting id="requests.proxy.server"/>
            <setting id="requests.proxy.source">1</setting>
            <setting id="requests.proxy.type">0</setting>
            <setting id="requests.proxy.username"/>
            <setting id="requests.ssl.verify">true</setting>
            <setting id="requests.timeout.connect">9</setting>
            <setting id="requests.timeout.read">27</setting>
            <setting id="youtube.allow.dev.keys">false</setting>
            <setting id="youtube.api.config.page">false</setting>
            <setting id="youtube.api.id">${config.sops.placeholder."youtube/api-id"}</setting>
            <setting id="youtube.api.key">${config.sops.placeholder."youtube/api-key"}</setting>
            <setting id="youtube.api.secret">${config.sops.placeholder."youtube/secret"}</setting>
            <setting id="youtube.filter.my_subscriptions_filtered.blacklist">false</setting>
            <setting id="youtube.filter.my_subscriptions_filtered.list"/>
            <setting id="youtube.folder.bookmarks.show">false</setting>
            <setting id="youtube.folder.browse_channels.show">false</setting>
            <setting id="youtube.folder.completed.live.show">false</setting>
            <setting id="youtube.folder.disliked_videos.show">false</setting>
            <setting id="youtube.folder.history.playlist"/>
            <setting id="youtube.folder.history.show">true</setting>
            <setting id="youtube.folder.liked_videos.show">false</setting>
            <setting id="youtube.folder.live.show">false</setting>
            <setting id="youtube.folder.my_channel.show">false</setting>
            <setting id="youtube.folder.my_location.show">false</setting>
            <setting id="youtube.folder.my_subscriptions.show">true</setting>
            <setting id="youtube.folder.my_subscriptions.sources">subscriptions,saved_playlists,bookmark_channels,bookmark_playlists</setting>
            <setting id="youtube.folder.my_subscriptions_filtered.show">false</setting>
            <setting id="youtube.folder.playlists.show">false</setting>
            <setting id="youtube.folder.popular_right_now.show">true</setting>
            <setting id="youtube.folder.purchases.show">false</setting>
            <setting id="youtube.folder.quick_search.show">false</setting>
            <setting id="youtube.folder.quick_search_incognito.show">false</setting>
            <setting id="youtube.folder.recommendations.show">true</setting>
            <setting id="youtube.folder.related.show">true</setting>
            <setting id="youtube.folder.saved.playlists.show">false</setting>
            <setting id="youtube.folder.search.show">true</setting>
            <setting id="youtube.folder.settings.advanced.show">false</setting>
            <setting id="youtube.folder.settings.show">false</setting>
            <setting id="youtube.folder.sign.in.show">false</setting>
            <setting id="youtube.folder.sign.out.show">false</setting>
            <setting id="youtube.folder.subscriptions.show">false</setting>
            <setting id="youtube.folder.switch.user.show">false</setting>
            <setting id="youtube.folder.upcoming.live.show">false</setting>
            <setting id="youtube.folder.watch_later.playlist"/>
            <setting id="youtube.folder.watch_later.show">true</setting>
            <setting id="youtube.http.idle_sleep">true</setting>
            <setting id="youtube.http.stream_redirect">false</setting>
            <setting id="youtube.language">ru</setting>
            <setting id="youtube.location">40.4165,-3.70256</setting>
            <setting id="youtube.location.radius">500</setting>
            <setting id="youtube.playlist.watchlater.autoremove">true</setting>
            <setting id="youtube.post.play.rate">false</setting>
            <setting id="youtube.post.play.rate.playlists">false</setting>
            <setting id="youtube.post.play.refresh">false</setting>
            <setting id="youtube.region">RU</setting>
            <setting id="youtube.suggested_videos">false</setting>
            <setting id="youtube.view.channel_name.aliases">cast</setting>
            <setting id="youtube.view.description.details">false</setting>
            <setting id="youtube.view.filter.list"/>
            <setting id="youtube.view.hide_videos"/>
            <setting id="youtube.view.label.color.commentCount">ff00ffff</setting>
            <setting id="youtube.view.label.color.likeCount">ff00ff00</setting>
            <setting id="youtube.view.label.color.viewCount">ffadd8e6</setting>
            <setting id="youtube.view.label.details">false</setting>
            <setting id="youtube.view.shorts.duration">60</setting>
            <setting id="|end_settings_marker|">true</setting>
          </settings>
        '';
      };
    };
  };
}
