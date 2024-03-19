let
  pkgs = import <nixpkgs> { };
in
pkgs.mkShell {
  name = "window";
  nativeBuildInputs = with pkgs; [
    pkg-config
  ];
  buildInputs = with pkgs; [
    cmake
    pkg-config-unwrapped
    pkg-config
    glib
    gdk-pixbuf
    cairo
    pango
    gobject-introspection
    atkmm
    cargo
    gtk3
    gtk4
    vala
    clang
    dart
    dbus.dev
    flutter
    libdatrie
    libepoxy.dev
    libselinux
    libsepol
    libthai
    libxkbcommon
    ninja
    pcre
    util-linux.dev
    xorg.libXdmcp
    xorg.libXtst
    json-glib
    vala_0_54
  ];
}
