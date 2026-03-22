{
  lib,
  stdenv,
  fetchurl,
  pkg-config,
  libsndfile,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libsamplerate";
  version = "0.2.2";

  src = fetchurl {
    url = "https://github.com/libsndfile/libsamplerate/releases/download/${finalAttrs.version}/libsamplerate-${finalAttrs.version}.tar.xz";
    hash = "sha256-MljaKAUR0ktJ1rCGFbvoJNDKzJhCsOTK8RxSzysEOJM=";
  };

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ libsndfile ];

  # nixpkgs marks the MinGW build broken because the shared-library link step
  # generates an invalid .def file for current binutils. Ardour only needs a
  # real library package that pkg-config can resolve, so on MinGW we build the
  # static library variant instead of the broken shared one.
  configureFlags =
    [ "--disable-fftw" ]
    ++ lib.optionals stdenv.hostPlatform.isMinGW [
      "--disable-shared"
      "--enable-static"
    ];

  outputs = [
    "dev"
    "out"
  ];

  meta = {
    description = "Sample Rate Converter for audio";
    homepage = "https://libsndfile.github.io/libsamplerate/";
    license = lib.licenses.bsd2;
    maintainers = [ ];
    platforms = lib.platforms.all;
  };
})
