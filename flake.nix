{
    description = "awesometaro's dotfiles";

    inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    outputs = {self, nixpkgs}:

    let
    	system = "aarch64-darwin";
    	pkgs = nixpkgs.legacyPackages.${system};
    in {
        packages.${system}.defalut = pkgs.buildEnv {
            name = "taro-profile";
            paths = with pkgs; [
                jujutsu
                starship
                go
                kakoune
                fzf
                yazi
                
                
            ];
        };
    };

}
