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
  appInfo = import ./app-info.nix;
  inherit (appInfo) version release hash;
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

  # If a new version of PrismTerminal failed to build/launch then:
  # For each missing dependency that `autoPacthelfHook` reports, or dynamic library that fails to load at runtime,
  # say, `foo.so`, you can run `steam-run realpath /lib/foo.so` to get the corresponding package name.
  # If the library is not bundled in `steam-run`, then search the name of the library in `search.nixos.org`.
  # You may need to remove the postfix number if you can't find one.
  # For missing dependencies for `autoPatchelfHook`, put them in `buildInputs`;
  # For dynamic libraries that fails to load at runtime, put them in `runtimeDependencies`.

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