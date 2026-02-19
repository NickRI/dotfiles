{ config, lib, ... }:

{
  programs.kodi.addonSettings = lib.mkIf (config.programs.kodi.enable) {
    "pvr.iptvsimple"."kodi_addon_instance_name" = "Main IPTV Config";
    "pvr.iptvsimple"."kodi_addon_instance_enabled" = "true";
    "pvr.iptvsimple"."m3uPathType" = "1";
    "pvr.iptvsimple"."m3uPath" = "";
    "pvr.iptvsimple"."m3uUrl" = "https://iptv-org.github.io/iptv/index.m3u";
    "pvr.iptvsimple"."m3uCache" = "true";
    "pvr.iptvsimple"."startNum" = "1";
    "pvr.iptvsimple"."numberByOrder" = "false";
    "pvr.iptvsimple"."m3uRefreshMode" = "2";
    "pvr.iptvsimple"."m3uRefreshIntervalMins" = "60";
    "pvr.iptvsimple"."m3uRefreshHour" = "4";
    "pvr.iptvsimple"."connectioncheckinterval" = "10";
    "pvr.iptvsimple"."connectionchecktimeout" = "20";
    "pvr.iptvsimple"."defaultProviderName" = "";
    "pvr.iptvsimple"."enableProviderMappings" = "false";
    "pvr.iptvsimple"."providerMappingFile" =
      "special://userdata/addon_data/pvr.iptvsimple/providers/providerMappings.xml";
    "pvr.iptvsimple"."tvGroupMode" = "0";
    "pvr.iptvsimple"."numTvGroups" = "1";
    "pvr.iptvsimple"."oneTvGroup" = "";
    "pvr.iptvsimple"."twoTvGroup" = "";
    "pvr.iptvsimple"."threeTvGroup" = "";
    "pvr.iptvsimple"."fourTvGroup" = "";
    "pvr.iptvsimple"."fiveTvGroup" = "";
    "pvr.iptvsimple"."customTvGroupsFile" =
      "special://userdata/addon_data/pvr.iptvsimple/channelGroups/customTVGroups-example.xml";
    "pvr.iptvsimple"."tvChannelGroupsOnly" = "false";
    "pvr.iptvsimple"."radioGroupMode" = "0";
    "pvr.iptvsimple"."numRadioGroups" = "1";
    "pvr.iptvsimple"."oneRadioGroup" = "";
    "pvr.iptvsimple"."twoRadioGroup" = "";
    "pvr.iptvsimple"."threeRadioGroup" = "";
    "pvr.iptvsimple"."fourRadioGroup" = "";
    "pvr.iptvsimple"."fiveRadioGroup" = "";
    "pvr.iptvsimple"."customRadioGroupsFile" =
      "special://userdata/addon_data/pvr.iptvsimple/channelGroups/customRadioGroups-example.xml";
    "pvr.iptvsimple"."radioChannelGroupsOnly" = "false";
    "pvr.iptvsimple"."epgPathType" = "1";
    "pvr.iptvsimple"."epgPath" = "";
    "pvr.iptvsimple"."epgUrl" = "";
    "pvr.iptvsimple"."epgCache" = "true";
    "pvr.iptvsimple"."epgTimeShift" = "0";
    "pvr.iptvsimple"."epgTSOverride" = "false";
    "pvr.iptvsimple"."epgIgnoreCaseForChannelIds" = "true";
    "pvr.iptvsimple"."useEpgGenreText" = "false";
    "pvr.iptvsimple"."genresPathType" = "0";
    "pvr.iptvsimple"."genresPath" =
      "special://userdata/addon_data/pvr.iptvsimple/genres/genreTextMappings/genres.xml";
    "pvr.iptvsimple"."genresUrl" = "";
    "pvr.iptvsimple"."logoPathType" = "1";
    "pvr.iptvsimple"."logoPath" = "";
    "pvr.iptvsimple"."logoBaseUrl" = "";
    "pvr.iptvsimple"."useLogosLocalPathOnly" = "false";
    "pvr.iptvsimple"."logoFromEpg" = "1";
    "pvr.iptvsimple"."mediaEnabled" = "true";
    "pvr.iptvsimple"."mediaGroupByTitle" = "true";
    "pvr.iptvsimple"."mediaGroupBySeason" = "true";
    "pvr.iptvsimple"."mediaTitleSeasonEpisode" = "false";
    "pvr.iptvsimple"."mediaM3UGroupPath" = "2";
    "pvr.iptvsimple"."mediaForcePlaylist" = "false";
    "pvr.iptvsimple"."mediaVODAsRecordings" = "true";
    "pvr.iptvsimple"."timeshiftEnabled" = "false";
    "pvr.iptvsimple"."timeshiftEnabledAll" = "true";
    "pvr.iptvsimple"."timeshiftEnabledHttp" = "true";
    "pvr.iptvsimple"."timeshiftEnabledUdp" = "true";
    "pvr.iptvsimple"."timeshiftEnabledCustom" = "false";
    "pvr.iptvsimple"."catchupEnabled" = "false";
    "pvr.iptvsimple"."catchupQueryFormat" = "";
    "pvr.iptvsimple"."catchupDays" = "5";
    "pvr.iptvsimple"."allChannelsCatchupMode" = "0";
    "pvr.iptvsimple"."catchupOverrideMode" = "0";
    "pvr.iptvsimple"."catchupCorrection" = "0";
    "pvr.iptvsimple"."catchupPlayEpgAsLive" = "false";
    "pvr.iptvsimple"."catchupWatchEpgBeginBufferMins" = "5";
    "pvr.iptvsimple"."catchupWatchEpgEndBufferMins" = "15";
    "pvr.iptvsimple"."catchupOnlyOnFinishedProgrammes" = "false";
    "pvr.iptvsimple"."transformMulticastStreamUrls" = "false";
    "pvr.iptvsimple"."udpxyHost" = "127.0.0.1";
    "pvr.iptvsimple"."udpxyPort" = "4022";
    "pvr.iptvsimple"."useFFmpegReconnect" = "true";
    "pvr.iptvsimple"."useInputstreamAdaptiveforHls" = "false";
    "pvr.iptvsimple"."defaultUserAgent" = "";
    "pvr.iptvsimple"."defaultInputstream" = "";
    "pvr.iptvsimple"."defaultMimeType" = "";
  };
}
