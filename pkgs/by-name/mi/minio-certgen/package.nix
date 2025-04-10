{
  lib,
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule rec {
  pname = "minio-certgen";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "minio";
    repo = "certgen";
    tag = "v${version}";
    sha256 = "sha256-bYZfQeqPqroMkqJOqHri3l7xscEK9ml/oNLVPBVSDKk=";
  };

  vendorHash = null;

  meta = with lib; {
    description = "Simple Minio tool to generate self-signed certificates, and provides SAN certificates with DNS and IP entries";
    downloadPage = "https://github.com/minio/certgen";
    license = licenses.bsd3;
    maintainers = with maintainers; [ bryanasdev000 ];
    mainProgram = "certgen";
  };
}
