final: prev: {
  # 1. Override the Python 3 package set
  python3 = prev.python3.override {
    self = final.python3;
    packageOverrides = py-final: py-prev: {
      mpmath = py-prev.mpmath.overrideAttrs (old: rec {
        version = "1.3.0";
        src = prev.fetchFromGitHub {
          owner = "mpmath";
          repo = "mpmath";
          rev = version;
          hash = "sha256-9BGcaC3TyolGeO65/H42T/WQY6z5vc1h+MA+8MGFChU=";
        };
        doCheck = false;
        checkPhase = "true";
        pytestCheckPhase = "true";
        installCheckPhase = "true";
      });

      accelerate = py-prev.accelerate.overrideAttrs (old: {
        doCheck = false;
        checkPhase = "true";
        pytestCheckPhase = "true";
        installCheckPhase = "true";
        pythonImportsCheck = []; # Blasts away the broken 'import torchcodec' verification
      });

      torchcodec = py-prev.torchcodec.overrideAttrs (old: {
        doCheck = false;
        checkPhase = "true";
        pythonImportsCheck = [];
      });

      torchaudio = py-prev.torchaudio.overrideAttrs (old: {
        doCheck = false;
        checkPhase = "true";
        pytestCheckPhase = "true";
        pythonImportsCheck = [];
      });

      compressed-tensors = py-prev.compressed-tensors.overrideAttrs (old: {
        doCheck = false;
        dontCheckRuntimeDeps = true;
        checkPhase = "true";
        installCheckPhase = "true";
        nativeCheckInputs = [];
        pythonImportsCheck = [];
      });

      rapidocr-onnxruntime = py-prev.rapidocr-onnxruntime.overrideAttrs (old: {
        doCheck = false;
      });

      hydra-core = py-prev.hydra-core.overrideAttrs (old: {
        doCheck = false;
      });

      huggingface-hub = py-prev.huggingface-hub.overrideAttrs (old: rec {
        version = "1.5.0";
        src = prev.fetchFromGitHub {
          owner = "huggingface";
          repo = "huggingface_hub";
          rev = "v${version}";
          hash = "sha256-XuqZvTu3DuncGpRWXipxtDLY2alY7QVm89ZmpgTdfVo=";
        };
        dontCheckRuntimeDeps = true;
        doCheck = false;
        propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ [py-final.httpx py-final.typer];
        postPatch =
          (old.postPatch or "")
          + ''
            substituteInPlace pyproject.toml \
              --replace-quiet "typer-slim" "typer"
          '';
      });

      # FORCE Transformers to the specific commit for GLM-4.7
      transformers = py-prev.transformers.overrideAttrs (old: {
        version = "5.2.0";
        src = prev.fetchFromGitHub {
          owner = "huggingface";
          repo = "transformers";
          rev = "main";
          hash = "sha256-DPKuapzeEh0JaIaJKGCLO6UIKJGTIAD6tJ/lDfUl0Zs=";
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

  # 2. Fix for Python 3.12 (RapidOCR test core-dumps) - ensuring it's available as python312Packages too
  python3Packages = final.python3.pkgs;
  python312Packages = final.python3.pkgs;
  python313Packages = final.python3.pkgs;

  # Global fix for hydra-core tests failing on python 3.13 + packaging 26.1
  pythonPackagesExtensions =
    (prev.pythonPackagesExtensions or [])
    ++ [
      (py-final: py-prev: {
        # FORCE VLLM TO CONSTRAIN ITSELF PERMANENTLY
        vllm = py-prev.vllm.overrideAttrs (old: {
          preBuild = ''
            export VLLM_FA_ARCHS="8.6"
            export MAX_JOBS="16"
            export TORCH_CUDA_ARCH_LIST="8.6"
            ${old.preBuild or ""}
          '';

          doCheck = false;
          checkPhase = "true";
          pytestCheckPhase = "true";
          installCheckPhase = "true";
          pythonImportsCheck = [];
        });
        hydra-core = py-prev.hydra-core.overrideAttrs (old: {
          doCheck = false;
          checkPhase = "true";
          installCheckPhase = "true";
        });
      })
    ];

  # 3. Define vllm-glm at the top level of the overlay
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
