{ pkgs, resources, ... }:
{ services.matrix-synapse = { database_type = "sqlite3"
                            ; enable = true
                            ; enable_registration = true
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
; users.users.matrix-tunnel = { openssh.authorizedKeys.keys = [ resources.sshKeyPairs.matrixTunnel.publicKey ]
                              ; useDefaultShell = true
                              ; }
; }
