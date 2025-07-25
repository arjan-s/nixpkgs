{
  stdenv,
  lib,
  fetchurl,
  gnome,
  pkg-config,
  meson,
  ninja,
  adwaita-icon-theme,
  exiv2,
  libheif,
  libjpeg,
  libtiff,
  gst_all_1,
  libraw,
  libsoup_2_4,
  libsecret,
  glib,
  gtk3,
  gsettings-desktop-schemas,
  libchamplain,
  libjxl,
  librsvg,
  libwebp,
  libX11,
  json-glib,
  lcms2,
  bison,
  flex,
  clutter-gtk,
  wrapGAppsHook3,
  shared-mime-info,
  python3,
  desktop-file-utils,
  itstool,
  withWebservices ? true,
  webkitgtk_4_0,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "gthumb";
  version = "3.12.7";

  src = fetchurl {
    url = "mirror://gnome/sources/gthumb/${lib.versions.majorMinor finalAttrs.version}/gthumb-${finalAttrs.version}.tar.xz";
    sha256 = "sha256-7hLSTPIxAQJB91jWyVudU6c4Enj6dralGLPQmzce+uw=";
  };

  nativeBuildInputs = [
    bison
    desktop-file-utils
    flex
    itstool
    meson
    ninja
    pkg-config
    python3
    wrapGAppsHook3
  ];

  buildInputs = [
    clutter-gtk
    exiv2
    glib
    adwaita-icon-theme
    gsettings-desktop-schemas
    gst_all_1.gst-plugins-base
    (gst_all_1.gst-plugins-good.override { gtkSupport = true; })
    gst_all_1.gst-libav
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gtk3
    json-glib
    lcms2
    libchamplain
    libheif
    libjpeg
    libjxl
    libraw
    librsvg
    libsecret
    libsoup_2_4
    libtiff
    libwebp
    libX11
  ]
  ++ lib.optional withWebservices webkitgtk_4_0;

  mesonFlags = [
    "-Dlibchamplain=true"
    "-Dlibjxl=true"
    (lib.mesonBool "webservices" withWebservices)
  ];

  postPatch = ''
    chmod +x gthumb/make-gthumb-h.py

    patchShebangs data/gschemas/make-enums.py \
      gthumb/make-gthumb-h.py \
      po/make-potfiles-in.py \
      postinstall.py \
      gthumb/make-authors-tab.py
  '';

  preFixup = ''
    gappsWrapperArgs+=(--prefix XDG_DATA_DIRS : "${shared-mime-info}/share")
  '';

  passthru = {
    updateScript = gnome.updateScript {
      packageName = "gthumb";
      versionPolicy = "odd-unstable";
    };
  };

  meta = with lib; {
    homepage = "https://gitlab.gnome.org/GNOME/gthumb";
    description = "Image browser and viewer for GNOME";
    mainProgram = "gthumb";
    platforms = platforms.linux;
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.mimame ];
  };
})
