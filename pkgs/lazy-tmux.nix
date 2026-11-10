{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "lazy-tmux";
  version = "0.3.6";

  src = fetchFromGitHub {
    owner = "alchemmist";
    repo = "lazy-tmux";
    rev = "v${version}";
    hash = "sha256-hMKo43Z514GcO0zTIK6CSZyrhLs0fT5GEO82WJfDEoQ=";
  };

  vendorHash = "sha256-WkDE34ZkjRjYGxVbcpUbrc7t138rugt3sDgCdHMcWDY=";

  subPackages = [ "cmd/lazy-tmux" ];

  env.CGO_ENABLED = 0;

  # Same flags as upstream's .goreleaser.yaml release builds
  ldflags = [
    "-s"
    "-w"
    "-X main.version=${version}"
  ];

  # The cmd/lazy-tmux tests fail in the build sandbox: they shell out to
  # `ps` and to the repo's CI quality-graph scripts (checked with v0.3.6).
  doCheck = false;

  meta = {
    description = "Save tmux sessions and restore them lazily";
    homepage = "https://github.com/alchemmist/lazy-tmux";
    license = lib.licenses.mit;
    mainProgram = "lazy-tmux";
    platforms = lib.platforms.unix;
  };
}
