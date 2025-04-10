{
  lib,
  rustPlatform,
  fetchFromGitHub,
  pkg-config,
  wayland,
  libxkbcommon,
  fontconfig,
  makeWrapper,
  grim,
}:
rustPlatform.buildRustPackage rec {
  pname = "watershot";
  version = "0.2.2";

  src = fetchFromGitHub {
    owner = "Kirottu";
    repo = "watershot";
    tag = "v${version}";
    hash = "sha256-l9CPSB8TCw901ugl5FLVZDkp2rLha0yXMewK7LxXIiE=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-ETyz2fmcDPvrYA08ZrDuIE9ve8T74mBn//lU5ZNQt1A=";

  nativeBuildInputs = [
    pkg-config
    wayland
    makeWrapper
  ];

  buildInputs = [
    wayland
    fontconfig
    libxkbcommon
  ];

  postInstall = ''
    wrapProgram $out/bin/watershot \
      --prefix PATH : ${lib.makeBinPath [ grim ]}
  '';

  meta = with lib; {
    platforms = with platforms; linux;
    description = "Simple wayland native screenshot tool";
    mainProgram = "watershot";
    homepage = "https://github.com/Kirottu/watershot";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ lord-valen ];
  };
}
