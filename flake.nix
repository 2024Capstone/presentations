{
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    devShells.${system}.default = pkgs.mkShell {
      packages = [pkgs.pandoc];
    };

    apps.${system}.runPandoc = {
      type = "app";
      program = "${pkgs.writeShellScriptBin "runPandoc" ''
        #!/usr/bin/env bash
        echo "Preparing Slides ..."

        find . -mindepth 2 -type f -name '*.org' | while read -r file; do
          outfile="''${file%.org}.html"
          dir=$(dirname "$file")

          pandoc -t revealjs -s -o "$outfile" "$file" --embed-resources \
            -V theme=dracula --toc=false --css="$dir/custom.css"
        done

        echo "Preparing index ..."
        pandoc -s index.org -o index.html
        echo "Done"
      ''}/bin/runPandoc";
    };
  };
}
