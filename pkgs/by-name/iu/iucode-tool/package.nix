{
  lib,
  stdenv,
  fetchFromGitLab,
  autoreconfHook,
  fetchpatch,
  argp-standalone,
}:

stdenv.mkDerivation rec {
  pname = "iucode-tool";
  version = "2.3.1";

  src = fetchFromGitLab {
    owner = "iucode-tool";
    repo = "iucode-tool";
    tag = "v${version}";
    hash = "sha256-ajDpywgyerbvgern0b8T4jJUWisMzwrhwKO1g7iOtBE=";
  };

  patches = [
    # build fix for musl libc, pending upstream review
    # https://gitlab.com/iucode-tool/iucode-tool/-/merge_requests/4
    (fetchpatch {
      url = "https://gitlab.com/iucode-tool/iucode-tool/-/commit/fda4aaa4727601dbe817fac001f234c19420351a.patch";
      hash = "sha256-BxYrXALpZFyJtFrgU5jFmzd1dIMPmpNgvYArgkwGt/w=";
    })
  ];

  nativeBuildInputs = [ autoreconfHook ];
  buildInputs = lib.optional stdenv.hostPlatform.isMusl argp-standalone;

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Intel® 64 and IA-32 processor microcode tool";
    mainProgram = "iucode_tool";
    homepage = "https://gitlab.com/iucode-tool/iucode-tool";
    license = licenses.gpl2Plus;
    maintainers = with maintainers; [ peterhoeg ];
    platforms = [
      "x86_64-linux"
      "i686-linux"
    ];
  };
}
