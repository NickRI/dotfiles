{config, ...}:

{
  config = {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "image/svg+xml" = [ "com.boxy_svg.BoxySVG.desktop" ];
        "application/pdf" = [ "com.github.xournalpp.xournalpp.desktop" ];
        "application/vnd.sqlite3" = "org.nickvision.money.desktop";
        "text/html" = "chromium-browser.desktop";
        "x-scheme-handler/http" = "chromium-browser.desktop";
        "x-scheme-handler/https" = "chromium-browser.desktop";
        "x-scheme-handler/about" = "chromium-browser.desktop";
        "x-scheme-handler/unknown" = "chromium-browser.desktop";
      };
    };
  };
}