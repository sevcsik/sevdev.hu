{ pkgs, resources, ... }:
let matrixVHost = { enableACME = true
                  ; forceSSL = true
                  ; locations."/_matrix" = { proxyPass = "http://localhost:8448/"
                                           ; extraConfig = ''
                                               proxy_set_header X-Forwarded-For $remote_addr;
                                             ''
                                           ; }
                  ; }
; keyFile = builtins.toFile "matrix-tunnel-key" resources.sshKeyPairs.matrixTunnel.privateKey
; matrixHostname = resources.machines.matrix.networking.hostName
; sshTunnelCmd = "${pkgs.openssh}/bin/ssh -i ${keyFile} -L 8448:localhost:8448 matrix-tunnel@${matrixHostname}"
; in
{ services.nginx = { enable = true
                   ; virtualHosts."sevdev.hu" = matrixVHost
                   ; }
; systemd.services.matrix-tunnel = { description = "SSH tunnel to Matrix homeserver"
                                   ; serviceConfig = { Restart = "always"; }
                                   ; script = sshTunnelCmd
                                   ; wantedBy = [ "multi-user.target" ]
                                   ; }
; }
