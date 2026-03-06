final: prev: {
  tree-sitter-bin = let
    version = "0.26.1";
  in
    prev.stdenv.mkDerivation {
      inherit version;
      pname = "tree-sitter-bin";

      src = final.fetchurl {
        url = "https://github.com/tree-sitter/tree-sitter/releases/download/v${version}/tree-sitter-linux-x64.gz";
        hash = "sha256-10GC//v0QfJHNxrWr3fZmxCsn3iNfgaOS0SZLZ1tfCY=";
      };

      nativeBuildInputs = [final.gzip];
      unpackPhase = "gzip -d < $src > tree-sitter";

      installPhase = ''
        mkdir -p $out/bin
        cp tree-sitter $out/bin/
        chmod +x $out/bin/tree-sitter
      '';
    };

  vimPlugins = prev.vimPlugins // {nvim-treesitter = prev.vimPlugins.nvim-treesitter-legacy;};
}
