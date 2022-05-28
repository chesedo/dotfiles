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
      sha256 = "0nalji8xdf74vlgzdjqh23qdg0lxhxvkb541zb7whcp61lsix7br";
    };
    cargoDeps = oldAttrs.cargoDeps.overrideAttrs (super.lib.const {
      src = super.fetchFromGitHub {
        owner = "leftwm";
        repo = "leftwm";
        rev = "master";
        sha256 = "0nalji8xdf74vlgzdjqh23qdg0lxhxvkb541zb7whcp61lsix7br";
      };
      outputHash = "1kka0kd0jwsl2ld7g3cykjy8z2l5a1866zhma0295sj7jsh21lph";
    });
  });
}
