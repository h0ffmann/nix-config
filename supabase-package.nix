{ lib, stdenv, fetchurl, autoPatchelfHook }:

stdenv.mkDerivation rec {
  pname = "supabase-cli";
  version = "2.15.8";

  src = fetchurl {
    url = "https://github.com/supabase/cli/releases/download/v${version}/supabase_${version}_linux_amd64.tar.gz";
    sha256 = "sha256-MGsZi3wY3t3mbw6/eYVDhaxE2xJuWk8y4QcH8EcO8ik="; # You might need to update this hash
  };

  nativeBuildInputs = [ autoPatchelfHook ];

  unpackPhase = ''
    mkdir -p $out/bin
    tar -xzf $src -C $out/bin
    chmod +x $out/bin/supabase
  '';

  # Skip other phases which we don't need
  dontConfigure = true;
  dontBuild = true;
  dontInstall = true;

  meta = with lib; {
    description = "Supabase CLI";
    homepage = "https://github.com/supabase/cli";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = with maintainers; [ ];
  };
}
