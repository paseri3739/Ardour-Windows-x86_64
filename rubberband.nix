{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  libsamplerate,
  libsndfile,
  fftw,
  lv2,
  vamp-plugin-sdk,
  ladspaH,
  meson,
  ninja,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "rubberband";
  version = "4.0.0";

  src = fetchurl {
    url = "https://breakfastquay.com/files/releases/rubberband-${finalAttrs.version}.tar.bz2";
    hash = "sha256-rwUDE+5jvBizWy4GTl3OBbJ2qvbRqiuKgs7R/i+AKOk=";
  };

  nativeBuildInputs = [
    pkg-config
    meson
    ninja
  ];

  buildInputs = [
    libsamplerate
    libsndfile
    fftw
    vamp-plugin-sdk
    ladspaH
    lv2
  ];

  makeFlags = [ "AR:=$(AR)" ];

  # Upstream's Meson build enables JNI probing by default, which pulls in a JDK.
  # nixpkgs' mingw cross JDK is not available, but Ardour only needs the C/C++ library.
  mesonFlags = [
    "-Dtests=disabled"
    "-Djni=disabled"
  ];

  doCheck = false;

  meta = {
    description = "High quality software library for audio time-stretching and pitch-shifting";
    homepage = "https://breakfastquay.com/rubberband/";
    license = lib.licenses.gpl2Plus;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
