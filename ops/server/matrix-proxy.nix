{ nodes, pkgs, resources, ... }:
let matrixVHost = { enableACME = true
                  ; forceSSL = true
                  ; locations."/_matrix" = { proxyPass = "http://127.0.0.1:8448$request_uri"
                                           ; extraConfig = ''
                                               proxy_set_header X-Forwarded-For $remote_addr;
                                             ''
                                           ; }
                  ; }
; sshTunnelPreStart =  ''
    ${pkgs.openssh}/bin/ssh-keyscan ${matrixHostname} >> /root/.ssh/known_hosts
  ''
; matrixHostname = nodes.matrix.config.networking.hostName
; sshTunnelCmd = "${pkgs.openssh}/bin/ssh -i /etc/matrix-tunnel-key -L 8448:localhost:8448 " +
                 "-N matrix-tunnel@${matrixHostname}"
; in
{ environment.etc."matrix-tunnel-key" = { mode = "600" # FIXME: this stores the key insecurely in /nix/store.
                                        ; text = resources.sshKeyPairs.matrixTunnel.privateKey
                                        ; user = "root"
                                        ; }
; services.nginx = { enable = true
                   ; virtualHosts."sevdev.hu" = matrixVHost
                   ; }
; systemd.services.matrix-tunnel = { description = "SSH tunnel to Matrix homeserver"
                                   ; preStart = sshTunnelPreStart
                                   ; serviceConfig = { Restart = "always"; }
                                   ; script = sshTunnelCmd
                                   ; wantedBy = [ "multi-user.target" ]
                                   ; }
; }
