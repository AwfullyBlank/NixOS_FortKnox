{
  description = "Nixos FortKnox";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
  };

  outputs = { self, nixpkgs }: {
nixosConfigurations.null = nixpkgs.lib.nixosSystem {
	system = "x86_64-linux";
	modules = [ ./configuration.nix];
    };
  };
}
