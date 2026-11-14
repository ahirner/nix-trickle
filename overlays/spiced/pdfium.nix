{
  lib,
  stdenv,
  fetchurl,
  autoPatchelfHook,
}: let
  assets = {
    aarch64-darwin = {
      name = "pdfium-mac-arm64";
      sha256 = "954cd315ff7d7ec51824cc6289ad1b00a0981533cb9762a56fd122bcaa12cd27";
    };
    aarch64-linux = {
      name = "pdfium-linux-arm64";
      sha256 = "e81ec447dd00097eb2fc26cff88be53ea321495711a43af9ea7b50bebdea9226";
    };
    x86_64-linux = {
      name = "pdfium-linux-x64";
      sha256 = "af96f21fd8e9d53955013dad1d17b003d0120025e787b7ce611a685d57287594";
    };
  };
  asset = assets.${stdenv.hostPlatform.system};
in
  stdenv.mkDerivation {
    pname = "spiced-pdfium";
    version = "7897";
    src = fetchurl {
      url = "https://github.com/run-llama/pdfium-binaries/releases/download/chromium/7897/${asset.name}.tgz";
      inherit (asset) sha256;
    };

    sourceRoot = ".";
    nativeBuildInputs = lib.optionals stdenv.hostPlatform.isLinux [autoPatchelfHook];
    buildInputs = lib.optionals stdenv.hostPlatform.isLinux [stdenv.cc.cc.lib];
    dontConfigure = true;
    dontBuild = true;
    dontStrip = true;
    installPhase = ''
      runHook preInstall
      mkdir -p "$out"
      cp -R lib include LICENSE licenses "$out/"
      runHook postInstall
    '';

    meta = {
      description = "PDFium runtime matching Spice's liteparse bindings";
      homepage = "https://github.com/run-llama/pdfium-binaries";
      license = lib.licenses.bsd3;
      sourceProvenance = [lib.sourceTypes.binaryNativeCode];
      platforms = builtins.attrNames assets;
    };
  }
