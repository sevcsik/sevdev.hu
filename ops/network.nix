{ network.description = "sevdev network"

; web = { imports = [ hardware/ramnode-kvm.nix
                      server/static-nginx.nix
                    ]

        ; deployment.targetHost = "rn1.sevdev.hu"
        ; networking.hostName = "rn1.sevdev.hu"

        ; }
; }
