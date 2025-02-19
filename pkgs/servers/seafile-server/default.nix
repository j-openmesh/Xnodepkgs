{ stdenv
, lib
, fetchFromGitHub
, pkg-config
, python3
, autoreconfHook
, libuuid
, sqlite
, glib
, libevent
, libsearpc
, openssl
, fuse
, libarchive
, libjwt
, curl
, which
, vala
, cmake
, oniguruma
, libargon2
, nixosTests
}:

let
  # seafile-server relies on a specific version of libevhtp.
  # It contains non upstreamed patches and is forked off an outdated version.
  libevhtp = import ./libevhtp.nix {
    inherit stdenv lib fetchFromGitHub cmake libevent;
  };
in
stdenv.mkDerivation rec {
  pname = "seafile-server";
  version = "10.0.1";

  src = fetchFromGitHub {
    owner = "haiwen";
    repo = "seafile-server";
    rev = "99301122499d68fdffd2dd5af8e11a0bae03cbb3"; # using a fixed revision because upstream may re-tag releases :/
    sha256 = "0yqmf8z0zzs3blx9b93f13szxp8jhxchfj985mfxsvlw0wj55ks1";
  };

  nativeBuildInputs = [ autoreconfHook pkg-config ];

  buildInputs = [
    libuuid
    sqlite
    openssl
    glib
    libsearpc
    libevent
    python3
    fuse
    libarchive
    libjwt
    curl
    which
    vala
    libevhtp
    oniguruma
    libargon2
  ];

  postInstall = ''
    mkdir -p $out/share/seafile/sql
    cp -r scripts/sql $out/share/seafile
  '';

  passthru.tests = {
    inherit (nixosTests) seafile;
  };

  meta = with lib; {
    description = "File syncing and sharing software with file encryption and group sharing, emphasis on reliability and high performance";
    homepage = "https://github.com/haiwen/seafile-server";
    license = licenses.agpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [ greizgh schmittlauch ];
  };
}
