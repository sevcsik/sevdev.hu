-----------------------------------------------------------
title: CD statikus webalkalmazásoknak, NixOS-szel - 1. rész
-----------------------------------------------------------

Egy korábbi [bejegyzésemben][prev-post] arról írtam, hogy lehet egy egyszerű
nginx webszervert feltelepíteni a NixOS/NixOps segítségével.

Ennek folytatásaként, most a következő célt valósítjuk meg: vannak webes
projektjeink, akár statikus weboldalak, akár egy önálló front-end webalkalmazás,
és szeretnénk, hogy fejlesztés közben minden branch egyszerre legyen elérhető a
saját aldomainjén.

Például a `website` projekt `develop` branche legyen elérhető a
`develop.website.example.com` domainen, az `awesome-app` projekt
`feat/fancy-buttons` branche pedig a
`feat-fancy-buttons.awesome-app.example.com`-on.

Ebben a bejegzésben utánajárunk, hogy lehet NixOS-sel létrehozni egy
webszervert, ami a fent leírt módon, dinamikusan ki tudja szolgálni az egyes
branchekhez tartozó műtárgyakat.

<!-- TEASER -->

A bejegyzésben szereplő példaprojektet eléred a blog [Github repójában][repo].

# NixOps hálózat

Az egyszerűség kedvéért először VirtualBoxban hozzuk létre az roppant összetett,
egy gépet tartalmazó infrastruktúránkat. Később az egész hóbelevancot telepítjük
AWS-re.

Első lépésként deklarálunk egy hálózatot, egy `master` nevű géppel. Ez a
kifejezés lesz a rendszer belépési pontja: ezt tudjuk telepíteni majd a
`nixops deploy` paranccsal.


```nix
# network-vbox.nix @ d0b8375
{
    network.description = "Example TestNet - Virtualbox";
    master = {
        deployment.targetEnv = "virtualbox";
    };
}
```

Ez a kifejezés nem csinál sokat - létrehoz egy Virtualbox gépet, amin csak egy
alap NixOS példány fog futni. A hálózatunk VirtualBox-specifikus része ennyi -
van lehetőség tovább paraméterezni, pl. hogy mekkora virtuális meghajtót vagy
hány virtuális processzort kapjon a gép. Erre most nem térnék ki, a [NixOps
kézikönyv megfelelő fejezetében][nixops-manual-vbox] bővebben olvashatunk róla.

Hozzunk létre egy másik Nix kifejezést, ami azokat a beállításokat tartalmazza,
amik nem VirtualBox-specifikusak. A `nixops create` parancsnak több nix
kifejezést tartalmazó fájlt is megadhatunk, ezeket ő okosan egyesíteni fogja egy
kifejezéssé. Ennek akkor lesz jelentősége, ha később AWS-re is akarjuk
telepíteni ugyanezt a konfigurációt anélkül, hogy duplikálnunk kéne a
beállításokat.

```nix
# network.nix

{
    master = {
        openssh.enable = true;
    };
}

Jelenleg itt semmi érdekeset nem csinálunk, csupán bekapcsoljuk az OpenSSH
szolgáltatást a `master` gépen, hogy be tudjunk rá jelentkezni.

Ki is próbálhatjuk a rendszert az alábbi parancsokkal:

 - Először létrehozzuk a hálózatot az `example-vbox` hálózatazonosítóvalÉ

```sh
$ nixops create -dexample-vbox network-vbox.nix network.nix
```

 - Majd "telepítjük" - VirtualBox eseténn ez létrehozza és elindítja a virtuális
   gépet.

```sh
$ nixops deploy -dexample-vbox
```

 - Kipróbálhatjuk, milyen érzés bejelentkezni a `master` gépbe SSH-n:

```sh
$ nixops ssh -dexample-vbox master
```


[prev-post]: ./2017-12-26-discovering-nix-deploying-a-simple-nginx-with-nixops.html
[repo]: https://github.com/sevcsik/sevdev.hu/tree/master/blog/sample-projects-nixos-cd
[nixops-manual-vbox]: https://nixos.org/nixops/manual/#idm140737322662048
