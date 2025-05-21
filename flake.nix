{
  description = "Nixos FortKnox";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, sops-nix }: {
nixosConfigurations.null = nixpkgs.lib.nixosSystem {
	system = "x86_64-linux";
	modules = [
	./configuration.nix
	sops-nix.nixosModules.sops
	];
    };
  };
}
