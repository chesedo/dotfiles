self: super: {
  # Patch until the following PR is released
  # https://github.com/leftwm/leftwm/pull/623
  # This is only needed for the pi400 build
  leftwm = super.leftwm.overrideAttrs (oldAttrs: rec {
    version = "0.3rc";

    src = super.fetchFromGitHub {
      owner = "leftwm";
      repo = "leftwm";
      rev = "master";
      sha256 = "0b13057vy3d5v3rmp0ym9x8r02f903k57nwii2w0rqi8j699l7mv";
    };
    cargoDeps = oldAttrs.cargoDeps.overrideAttrs (super.lib.const {
      src = super.fetchFromGitHub {
        owner = "leftwm";
        repo = "leftwm";
        rev = "master";
        sha256 = "0b13057vy3d5v3rmp0ym9x8r02f903k57nwii2w0rqi8j699l7mv";
      };
      outputHash = "1kka0kd0jwsl2ld7g3cykjy8z2l5a1866zhma0295sj7jsh21lph";
    });
  });
}
