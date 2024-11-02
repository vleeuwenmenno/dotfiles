{ config, pkgs, ... }:
{
  # Default applications
  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Zen Browser
      "application/xhtml+xml" = [ "io.github.zen_browser.zen.desktop" ];
      "text/html" = [ "io.github.zen_browser.zen.desktop" ];
      "x-scheme-handler/http" = [ "io.github.zen_browser.zen.desktop" ];
      "x-scheme-handler/https" = [ "io.github.zen_browser.zen.desktop" ];

      # Geary
      "x-scheme-handler/mailto" = [ "org.gnome.Geary.desktop" ];

      # Loupe (Image Viewer)
      "image/jpeg" = [ "org.gnome.Loupe.desktop" ];
      "image/png" = [ "org.gnome.Loupe.desktop" ];
      "image/gif" = [ "org.gnome.Loupe.desktop" ];
      "image/webp" = [ "org.gnome.Loupe.desktop" ];
      "image/tiff" = [ "org.gnome.Loupe.desktop" ];
      "image/x-tga" = [ "org.gnome.Loupe.desktop" ];
      "image/vnd-ms.dds" = [ "org.gnome.Loupe.desktop" ];
      "image/x-dds" = [ "org.gnome.Loupe.desktop" ];
      "image/bmp" = [ "org.gnome.Loupe.desktop" ];
      "image/vnd.microsoft.icon" = [ "org.gnome.Loupe.desktop" ];
      "image/vnd.radiance" = [ "org.gnome.Loupe.desktop" ];
      "image/x-exr" = [ "org.gnome.Loupe.desktop" ];
      "image/x-portable-bitmap" = [ "org.gnome.Loupe.desktop" ];
      "image/x-portable-graymap" = [ "org.gnome.Loupe.desktop" ];
      "image/x-portable-pixmap" = [ "org.gnome.Loupe.desktop" ];
      "image/x-portable-anymap" = [ "org.gnome.Loupe.desktop" ];
      "image/x-qoi" = [ "org.gnome.Loupe.desktop" ];
      "image/svg+xml" = [ "org.gnome.Loupe.desktop" ];
      "image/svg+xml-compressed" = [ "org.gnome.Loupe.desktop" ];
      "image/avif" = [ "org.gnome.Loupe.desktop" ];
      "image/heic" = [ "org.gnome.Loupe.desktop" ];
      "image/jxl" = [ "org.gnome.Loupe.desktop" ];

      # VLC (Video Player)
      "video/x-ogm+ogg" = [ "vlc.desktop" ];
      "video/3gp" = [ "vlc.desktop" ];
      "video/3gpp" = [ "vlc.desktop" ];
      "video/3gpp2" = [ "vlc.desktop" ];
      "video/dv" = [ "vlc.desktop" ];
      "video/divx" = [ "vlc.desktop" ];
      "video/fli" = [ "vlc.desktop" ];
      "video/flv" = [ "vlc.desktop" ];
      "video/mp2t" = [ "vlc.desktop" ];
      "video/mp4" = [ "vlc.desktop" ];
      "video/mp4v-es" = [ "vlc.desktop" ];
      "video/mpeg" = [ "vlc.desktop" ];
      "video/mpeg-system" = [ "vlc.desktop" ];
      "video/msvideo" = [ "vlc.desktop" ];
      "video/ogg" = [ "vlc.desktop" ];
      "video/quicktime" = [ "vlc.desktop" ];
      "video/vnd.divx" = [ "vlc.desktop" ];
      "video/vnd.mpegurl" = [ "vlc.desktop" ];
      "video/vnd.rn-realvideo" = [ "vlc.desktop" ];
      "video/webm" = [ "vlc.desktop" ];
      "video/x-anim" = [ "vlc.desktop" ];
      "video/x-avi" = [ "vlc.desktop" ];
      "video/x-flc" = [ "vlc.desktop" ];
      "video/x-fli" = [ "vlc.desktop" ];
      "video/x-flv" = [ "vlc.desktop" ];
      "video/x-m4v" = [ "vlc.desktop" ];
      "video/x-matroska" = [ "vlc.desktop" ];
      "video/x-mpeg" = [ "vlc.desktop" ];
      "video/x-mpeg2" = [ "vlc.desktop" ];
      "video/x-ms-asf" = [ "vlc.desktop" ];
      "video/x-ms-asf-plugin" = [ "vlc.desktop" ];
      "video/x-ms-asx" = [ "vlc.desktop" ];
      "video/x-msvideo" = [ "vlc.desktop" ];
      "video/x-ms-wm" = [ "vlc.desktop" ];
      "video/x-ms-wmv" = [ "vlc.desktop" ];
      "video/x-ms-wmx" = [ "vlc.desktop" ];
      "video/x-ms-wvx" = [ "vlc.desktop" ];
      "video/x-nsv" = [ "vlc.desktop" ];
      "video/x-theora" = [ "vlc.desktop" ];
      "video/x-theora+ogg" = [ "vlc.desktop" ];
      "video/x-ogm" = [ "vlc.desktop" ];
      "video/avi" = [ "vlc.desktop" ];
      "video/x-mpeg-system" = [ "vlc.desktop" ];

      # Totem (for those few formats that default to it)
      "video/vivo" = [ "org.gnome.Totem.desktop" ];
      "video/vnd.vivo" = [ "org.gnome.Totem.desktop" ];
      "video/x-flic" = [ "org.gnome.Totem.desktop" ];
      "video/x-mjpeg" = [ "org.gnome.Totem.desktop" ];
      "video/x-totem-stream" = [ "org.gnome.Totem.desktop" ];
    };
  };
}
