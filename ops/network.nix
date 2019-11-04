let pkgs = import ./nixpkgs
  ; in
{ network.description = "sevdev.hu live network"

; web = { imports = [ hardware/ramnode-kvm.nix
                      server/static-nginx.nix
                      server/matrix-proxy.nix
                    ]

        ; deployment.targetHost = "rn1.sevdev.hu"
        ; networking.hostName = "rn1.sevdev.hu"
        ; nixpkgs.pkgs = pkgs
        ; services.openssh.enable = true
        ; }
; matrix = { imports = [ hardware/ramnode-kvm.nix
                         server/matrix-homeserver.nix
                       ]
           ; deployment.targetHost = "rn2.sevdev.hu"
           ; networking.hostName = "rn2.sevdev.hu"
           ; nixpkgs.pkgs = pkgs
           ; services.openssh.enable = true
           ; }
; resources.sshKeyPairs.matrixTunnel = {}
; }
