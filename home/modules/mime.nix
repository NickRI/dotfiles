{config, ...}:
let apps = {
  "image/jpeg" = "eog.desktop";
  "image/gif" = "eog.desktop";
  "image/png" = "eog.desktop";
  "image/tiff" = "eog.desktop";
  "image/webp" = "eog.desktop";
  "image/svg+xml" = [ "com.boxy_svg.BoxySVG.desktop" ];
  "application/pdf" = [ "org.gnome.Evince.desktop" "xournalpp.desktop" ];
  "text/plain" = "org.gnome.TextEditor.desktop";
}; in {
  config = {
    xdg.mimeApps = {
      enable = true;
      associations.added = apps;
      defaultApplications = apps;
      associations.removed = {
          "image/png" = [ "chromium-browser.desktop" "com.boxy_svg.BoxySVG.desktop" ];
          "application/pdf" = [ "chromium-browser.desktop" "com.boxy_svg.BoxySVG.desktop" ];
      };
    };
  };
}