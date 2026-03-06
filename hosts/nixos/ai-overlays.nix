final: prev: {
  # 1. Override the Python 3 package set
  python3 = prev.python3.override {
    packageOverrides = py-final: py-prev: {
      compressed-tensors = py-prev.compressed-tensors.overrideAttrs (old: {
        doCheck = false;
        dontCheckRuntimeDeps = true;
        checkPhase = "true";
        installCheckPhase = "true";
        nativeCheckInputs = [];
      });

      huggingface-hub = py-prev.huggingface-hub.overrideAttrs (old: rec {
        version = "1.4.1";
        src = prev.fetchFromGitHub {
          owner = "huggingface";
          repo = "huggingface_hub";
          rev = "v${version}";
          hash = "sha256-At3FN+dplQ3L9B4vDZrEvREdwgepUvzWC7yeU6L5XY8=";
        };
        dontCheckRuntimeDeps = true;
        doCheck = false;
        propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [py-final.httpx py-final.typer];
        postPatch =
          (old.postPatch or "")
          + ''
            substituteInPlace pyproject.toml \
              --replace-quiet "typer-slim" "typer" \
          '';
      });

      # FORCE Transformers to the specific commit for GLM-4.7
      transformers = py-prev.transformers.overrideAttrs (old: {
        version = "5.2.0";
        src = prev.fetchFromGitHub {
          owner = "huggingface";
          repo = "transformers";
          rev = "main";
          hash = "sha256-dvj2va9dxLU38QsgM3GGeKJjU8XMK9Sk3t3SeS+opT4=";
        };
        dontCheckRuntimeDeps = true;
        doCheck = false;
        propagatedBuildInputs =
          (old.propagatedBuildInputs or [])
          ++ [
            py-final.httpx
            py-final.typer
            py-final.huggingface-hub
          ];
      });
    };
  };

  # 2. Define vllm-glm at the top level of the overlay
  vllm-glm =
    (final.python3.pkgs.vllm.override {
      # This ensures it uses the patched transformers from the set above
      transformers = final.python3.pkgs.transformers;
    }).overrideAttrs (old: {
      postPatch =
        (old.postPatch or "")
        + ''
          substituteInPlace pyproject.toml \
            --replace "transformers>=4.45.0,<4.50.0" "transformers" \
            --replace "grpcio-tools==1.78.0" "grpcio-tools"
        '';
    });
}
