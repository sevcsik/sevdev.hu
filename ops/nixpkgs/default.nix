import <nixpkgs> { overlays = [ (self: super: { mautrix-facebook = super.callPackage (import ./mautrix-facebook.nix)
                                              ; })
                              ]
                 ; }
