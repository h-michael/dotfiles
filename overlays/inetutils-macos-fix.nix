# inetutils 2.7 gnulib fails with clang -Wformat-security on macOS
# TODO: Remove when upstream nixpkgs fixes this
final: prev: {
  inetutils = prev.inetutils.overrideAttrs (old: {
    env = (old.env or { }) // {
      NIX_CFLAGS_COMPILE = "-Wno-error=format-security";
    };
  });
}
