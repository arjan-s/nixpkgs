{ stdenv
, lib
, fetchurl
, autoPatchelfHook
, gtk3
, webkitgtk
}:

stdenv.mkDerivation rec {
  pname = "fig";
  version = "2.14.1";

  src = fetchurl {
    url = "https://repo.fig.io/generic/stable/asset/${version}/x86_64/fig.tar.xz";
    sha256 = "f840e62ab8f49d3676685c79c036c72373b0a7e46b65c98365f740456c626b1c";
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  buildInputs = [
    gtk3
    webkitgtk
  ];

  postFixup = ''
    substituteInPlace $out/share/systemd/user/fig.service --replace 'ExecStart=/usr/bin/fig_desktop' "ExecStart=$out/bin/fig_desktop"
  '';

  installPhase = ''
    mkdir -p $out
    cp -r . $out/
  '';

  meta = with lib; {
    description = "Adds IDE-style autocomplete to your existing terminal";
    homepage = "https://fig.io";
    license = licenses.unfree;
    maintainers = with maintainers; [ arjan-s ];
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
  };
}
