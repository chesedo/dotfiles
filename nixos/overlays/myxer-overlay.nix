self: super: {
  # Patch until the following PR is merged
  # https://github.com/VixenUtils/Myxer/pull/20
  myxer = super.myxer.overrideAttrs (oldAttrs: rec {
    src = super.fetchFromGitHub {
      owner = "ErinvanderVeen";
      repo = "Myxer";
      rev = "gio-version";
      sha256 = "w1MX8igx/ptrG9eW+EfZreB+6Cj8EpZgED199FrGg+c=";
    };
    version = "1.2.1-gio-version-patch";
    cargoDeps = oldAttrs.cargoDeps.overrideAttrs (super.lib.const {
      src = super.fetchFromGitHub {
        owner = "ErinvanderVeen";
        repo = "Myxer";
        rev = "gio-version";
        sha256 = "w1MX8igx/ptrG9eW+EfZreB+6Cj8EpZgED199FrGg+c=";
      };
      outputHash = "jftu5aiZzxjhrsSrhWDaqF1CwHyeZxXhFbGnTv9qTy4=";
    });
  });
}
