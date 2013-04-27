# Class: ipa::client
#
# This class configures an IPA client
#
# Parameters:
#
# Actions:
#
# Requires: Exported resources, puppetlabs/puppetlabs-firewall
#
# Sample Usage:
#
class ipa::client (
  $clntpkg = {},
  $ldaputils = {},
  $sssdtools = {},
  $client = {},
  $domain = {},
  $realm = {},
  $otp = {},
  $mkhomedir = false,
  $ntp = false,
  $desc = {},
  $locality = {},
  $location = {}
) {

  $mkhomediropt = $ipa::client::mkhomedir ? {
    true    => '--mkhomedir',
    default => '',
  }

  $ntpopt = $ipa::client::ntp ? {
    true    => '',
    default => '--no-ntp',
  }

  Ipa::Clientinstall <<| |>> {
    name       => $::fqdn,
    otp        => $ipa::client::otp,
    mkhomedir  => $ipa::client::mkhomediropt,
    ntp        => $ipa::client::ntpopt,
    require    => Package[$ipa::client::clntpkg]
  }

  realize(Package["$ipa::client::clntpkg"], Package["$ipa::client::ldaputils"], Package["$ipa::client::sssdtools"])

  if $::osfamily == 'Debian' {
    file {
      "/etc/pki":
        ensure  => directory,
        mode    => 755,
        owner   => root,
        group   => root,
        require => Package[$ipa::client::clntpkg];

      "/etc/pki/nssdb":
        ensure  => directory,
        mode    => 755,
        owner   => root,
        group   => root,
        require => File["/etc/pki"];
    }

    File["/etc/pki/nssdb"] -> Ipa::Clientinstall <<| |>>
  }

  @@ipa::hostadd {
    "$::fqdn":
      otp      => $ipa::client::otp,
      desc     => $ipa::client::desc,
      locality => $ipa::client::locality,
      location => $ipa::client::location;
  }
}
