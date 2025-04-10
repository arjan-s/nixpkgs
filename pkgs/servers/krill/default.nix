{
  lib,
  rustPlatform,
  fetchFromGitHub,
  openssl,
  pkg-config,
  stdenv,
  Security,
}:

rustPlatform.buildRustPackage rec {
  pname = "krill";
  version = "0.14.5";

  src = fetchFromGitHub {
    owner = "NLnetLabs";
    repo = pname;
    tag = "v${version}";
    hash = "sha256-3pkDu20vgzslJcK5KQH+GY+jnimEZgm+bQxy8QMUeCk=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-8K4Jn2A9OREwLRyFddHREcylapoFr+/AMT7Wq4o2Ue4=";

  buildInputs = [ openssl ] ++ lib.optional stdenv.hostPlatform.isDarwin Security;
  nativeBuildInputs = [ pkg-config ];

  # Needed to get openssl-sys to use pkgconfig.
  OPENSSL_NO_VENDOR = 1;

  # disable failing tests on darwin
  doCheck = !stdenv.hostPlatform.isDarwin;

  meta = with lib; {
    description = "RPKI Certificate Authority and Publication Server written in Rust";
    longDescription = ''
      Krill is a free, open source RPKI Certificate Authority that lets you run
      delegated RPKI under one or multiple Regional Internet Registries (RIRs).
      Through its built-in publication server, Krill can publish Route Origin
      Authorisations (ROAs) on your own servers or with a third party.
    '';
    homepage = "https://github.com/NLnetLabs/krill";
    changelog = "https://github.com/NLnetLabs/krill/releases/tag/v${version}";
    license = licenses.mpl20;
    maintainers = with maintainers; [ steamwalker ];
  };
}
