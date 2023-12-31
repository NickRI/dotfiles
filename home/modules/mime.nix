{config, ...}:

{
  config = {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "image/jpeg" = "org.gnome.Loupe.desktop";
        "image/gif" = "org.gnome.Loupe.desktop";
        "image/png" = "org.gnome.Loupe.desktop";
        "image/tiff" = "org.gnome.Loupe.desktop";
        "image/webp" = "org.gnome.Loupe.desktop";
        "image/svg+xml" = [ "com.boxy_svg.BoxySVG.desktop" ];
        "application/pdf" = [ "org.gnome.Evince.desktop" "com.github.xournalpp.xournalpp.desktop" ];
        "text/plain" = "org.gnome.TextEditor.desktop";
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