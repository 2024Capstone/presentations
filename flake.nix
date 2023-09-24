{
    inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.05";

  outputs = {
    self,
    nixpkgs,
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {inherit system;};
  in {
    apps.${system}.runPandoc = {
      type = "app";
      program = "${pkgs.stdenv.mkDerivation {
        name = "runPandoc";
        buildInputs = [pkgs.pandoc];
        buildCommand = ''
          mkdir -p $out/bin
          cat > $out/bin/runPandoc <<'EOF'
          #!${pkgs.bash}/bin/bash
          echo "Preparing Slides ..."
          find . -mindepth 2 -type f -name '*.org' | while read -r file; do
            outfile="''${file%.org}.html"
            dir=$(dirname "$file")
            pandoc -t revealjs -o "$outfile" "$file" --embed-resources \
              -V theme=dracula --toc=false --css="$dir/custom.css"
          done
          pandoc -s index.org -o index.html
          echo "Done"
          EOF
          chmod +x $out/bin/runPandoc
        '';
      }}/bin/runPandoc";
    };
  };
}
