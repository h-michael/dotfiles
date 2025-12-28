{
  lib,
  stdenvNoCC,
  fetchzip,
}:

stdenvNoCC.mkDerivation rec {
  pname = "cica";
  version = "5.0.3";

  src = fetchzip {
    url = "https://github.com/miiton/Cica/releases/download/v${version}/Cica_v${version}.zip";
    hash = "sha256-BtDnfWCfD9NE8tcWSmk8ciiInsspNPTPmAdGzpg62SM=";
    stripRoot = false;
  };

  installPhase = ''
    runHook preInstall

    install -Dm644 *.ttf -t $out/share/fonts/truetype/cica

    runHook postInstall
  '';

  meta = with lib; {
    description = "Cica font - Japanese programming font with Nerd Fonts";
    homepage = "https://github.com/miiton/Cica";
    license = licenses.ofl;
    platforms = platforms.all;
  };
}
