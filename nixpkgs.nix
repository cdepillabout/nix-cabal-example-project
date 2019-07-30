
let
  nixpkgsSrc = builtins.fetchTarball {
    # nixpkgs-19.03 as of 2019/04/15.
    url = "https://github.com/NixOS/nixpkgs/archive/88498c0a9ffd5bdc6460e8667fb7626c4b604ed9.tar.gz";
    sha256 = "0rqnn8psk9kclizqigrvwiwkllyqa5bjzpvd7h4fdd6hb4psjfb1";
  };

  overlay = self: super: {
    our-haskell-pkg-set = self.haskell.packages.ghc864.override {
      overrides = hself: hsuper: {

        package1 = hself.callCabal2nix "package1" ./package1 {};

        package2 = hself.callCabal2nix "package2" ./package2 {};

        our-local-pkgs = [
          hself.package1
          hself.package2
        ];

        conduit = hself.callHackage "conduit" "1.3.1" {};
      };
    };

    our-shell = self.our-haskell-pkg-set.shellFor {
      packages = pkgs: pkgs.our-local-pkgs;
      nativeBuildInputs = [
        self.cabal-install
        self.haskellPackages.ghcid
      ];
    };

    our-project-exes = self.buildEnv {
      name = "nix-cabal-example-project";
      paths = self.our-haskell-pkg-set.our-local-pkgs;
      extraOutputsToInstall = [ "dev" "out" ];
    };
  };

in

import nixpkgsSrc {
  overlays = [ overlay ];
}
