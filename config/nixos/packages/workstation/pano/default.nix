{
  stdenv,
  fetchzip,
  lib,
  gnome,
  glib,
  libgda,
  gsound,
  substituteAll,
  wrapGAppsHook,
}:

stdenv.mkDerivation rec {
  pname = "gnome-shell-extension-pano";
  version = "v23-alpha3";

  src = fetchzip {
    url = "https://github.com/oae/gnome-shell-pano/releases/download/${version}/pano@elhan.io.zip";
    sha256 = "LYpxsl/PC8hwz0ZdH5cDdSZPRmkniBPUCqHQxB4KNhc=";
    stripRoot = false;
  };

  patches = [
    (substituteAll {
      src = ./gnome-shell-extension-pano.patch;
      gsound_path = "${gsound}/lib/girepository-1.0";
      gda_path = "${libgda}/lib/girepository-1.0";
    })
  ];

  buildInputs = [
    gnome.gnome-shell
    libgda
    gsound
  ];

  nativeBuildInputs = [ wrapGAppsHook ];

  installPhase = ''
    runHook preInstall
    local_ext_dir=$out/share/gnome-shell/extensions/pano@elhan.io
    install -d $local_ext_dir
    cp -r * $local_ext_dir

    # Ensure typelibs are directly accessible
    mkdir -p $out/lib/girepository-1.0
    ln -s ${gsound}/lib/girepository-1.0/* $out/lib/girepository-1.0/
    ln -s ${libgda}/lib/girepository-1.0/* $out/lib/girepository-1.0/

    runHook postInstall
  '';

  meta = with lib; {
    description = "Pano GNOME Shell Clipboard Management Extension (${version} pre-release)";
    homepage = "https://github.com/oae/gnome-shell-pano";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
    maintainers = [ maintainers.zvictor ];
  };
}
