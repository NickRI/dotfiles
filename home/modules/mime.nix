{config, ...}:

{
  config = {
    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "image/jpeg" = "org.gnome.eog.desktop";
        "image/gif" = "org.gnome.eog.desktop";
        "image/png" = "org.gnome.eog.desktop";
        "image/tiff" = "org.gnome.eog.desktop";
        "image/webp" = "org.gnome.eog.desktop";
        "image/svg+xml" = [ "com.boxy_svg.BoxySVG.desktop" ];
        "application/pdf" = [ "org.gnome.Evince.desktop" "com.github.xournalpp.xournalpp.desktop" ];
        "text/plain" = "org.gnome.TextEditor.desktop";
        "application/vnd.sqlite3" = "org.nickvision.money.desktop";
      };
    };
  };
}