{
    fileserver = {
        deployment.targetHost = "rn2.sevdev.hu";
        networking.hostName = "rn2.sevdev.hu";
        imports = [ ./ramnode-kvm.nix
                    ./ssh.nix
                    ./webserver.nix
                  ];
    };
    network.description = "example network";
}
