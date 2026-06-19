{
  lib,
  stdenv,
  autoPatchelfHook,
  wrapGAppsHook3,
  fetchurl,
  dpkg,
  # Patch libraries
  openssl,
  systemdLibs,
  gtk3,
  gdk-pixbuf,
  cairo,
  glib,
  dbus,
  webkitgtk_4_1,
  libsoup_3,
  gcc,
  glibc,
  alsa-lib,
  libayatana-appindicator,
}:

let
  appName = "prismterminal-tauri";
  version = "1.1.15";
  release = "https://github.com/Kagami-Studio/PrismTerminal-Release/releases/download/v${version}/PrismTerminal-v${version}-linux64.deb";
  hash = "sha256-q6j9UxDodpADK42rzlDeKthtesg7GuI24yAjcU/xuuI=";
in

stdenv.mkDerivation {
  pname = "prismterminal";
  inherit version;
  
  src = fetchurl {
    url = release;
    hash = hash;
  };

  nativeBuildInputs = [
    dpkg    # This packages will unpack the .deb we just download
    autoPatchelfHook
    # See: https://nixos.org/manual/nixpkgs/stable/#ssec-gnome-hooks
    # otherwise prismterminal will crash on opening file selector
    wrapGAppsHook3
  ];

  buildInputs = [
    openssl
    systemdLibs
    gtk3
    gdk-pixbuf
    cairo
    glib
    dbus
    webkitgtk_4_1
    libsoup_3
    gcc
    glibc
    alsa-lib
  ];

  # https://github.com/NixOS/nixpkgs/blob/nixos-26.05/pkgs/build-support/setup-hooks/auto-patchelf.sh
  runtimeDependencies = [ libayatana-appindicator ];

  installPhase = ''
    runHook preInstall

    cd usr/
    install -Dm755 ./bin/${appName} $out/bin/${appName}
    find ./share -type f -exec sh -c 'FILE="$1"; install -Dm755 "$FILE" $out/"$FILE"' sh {} \;

    runHook postInstall
  '';

  meta = with lib; {
    mainProgram = appName;
    homepage = "https://kagamistudio.com/";
    description = "The next generation of meowpad configurator";
    platforms = [ "x86_64-linux" ];
    license = licenses.unfreeRedistributable;
  };
}