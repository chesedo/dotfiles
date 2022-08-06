self: super: {
  # Patch until the following PR is released
  # https://github.com/leftwm/leftwm/pull/623
  # This is only needed for the pi400 build
  leftwm = super.leftwm.overrideAttrs (oldAttrs: rec {
    version = "0.3.0";

    src = super.fetchFromGitHub {
      owner = "leftwm";
      repo = "leftwm";
      rev = "0.3.0";
      sha256 = "sha256-AfE36u5xSfivkg+hmJ6ASh6zXmTnLOv5RFigkGzySng=";
    };
    cargoDeps = oldAttrs.cargoDeps.overrideAttrs (super.lib.const {
      inherit src;
      outputHash = "sha256-atfMMAnPcsbi8FgztGchUXMpPfGzsfRemlA2CZynDg8=";
    });
  });
}
