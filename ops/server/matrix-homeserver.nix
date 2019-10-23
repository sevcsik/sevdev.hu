{ pkgs, resources, ... }:
let matrixVHost = { enableACME = true
                  ; forceSSL = true
                  ; locations."/_matrix" = { proxyPass = "http://localhost:8448/"
                                           ; extraConfig = ''
                                               proxy_set_header X-Forwarded-For $remote_addr;
                                             ''
                                           ; }
                  ; }
; in
{ services.matrix-synapse = { database_type = "sqlite3"
                            ; enable = true
                            ; listeners = [ { bind_address = "127.0.0.1"
                                            ; port = 8448
                                            ; resources = [ { compress = false
                                                            ; names = [ "client" "federation" ]
                                                            ; }
                                                          ]
                                            ; tls = false
                                            ; x_forwarded = true
                                            ; }
                                          ]
                            ; public_baseurl = "https://sevdev.hu"
                            ; server_name = "sevdev.hu"
                            ; }
; users.users.matrix-tunnel = { openssh.authorizedKeys.keys = [ resources.sshKeyPairs.matrixTunnel.publicKey ]; }
; }
