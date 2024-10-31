{ ... }:
{
  networking.extraHosts = ''
    127.0.0.1 subsites.local
    127.0.0.1 discountoffice.nl.local
    127.0.0.1 discountoffice.be.local
    127.0.0.1 fr.discountoffice.be.local
    127.0.0.1 api.local
    127.0.0.1 mailpit.local
  '';
}