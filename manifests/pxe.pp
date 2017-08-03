# This class adds configuration to the DHCP server so that network-booted
# machines will be controlled by Razor.  The base setup of DHCP is done in the
# 'dhcp' subclass.
#
# If you want to change the parameters to this class, you should specify them
# when declaring the main pe_razor_complete class, not here.  That way they'll
# be set properly for all the dhcp, pxe, and ipv4_nat subclasses.

class pe_razor_complete::pxe (
  $ipxe_url           = $pe_razor_complete::ipxe_url,
  $bootstrap_ipxe_url = "https://${::facts['fqdn']}:8151/api/microkernel/bootstrap?nic_max=1&http_port=8150",
  $tftp_port_range    = $pe_razor_complete::tftp_port_range,
) inherits pe_razor_complete {

  # Enable the dnsmasq tftp server, and aim it at /var/lib/tftpboot for files.
  file { '/etc/dnsmasq.d/tftp':
    ensure  => file,
    content => template('pe_razor_complete/tftp.erb'),
    require => Package['dnsmasq'],
    notify  => Service['dnsmasq'],
  }
  file { '/var/lib/tftpboot':
    ensure => directory,
    before => Service['dnsmasq'],
  }

  # All nodes will be told to boot the iPXE (undionly) kernel.  We download the
  # specifically Enterprise-supported version from the official Puppet s3
  # bucket.
  staging::file { 'undionly.kpxe':
    target  => '/var/lib/tftpboot/undionly.kpxe',
    source  => $ipxe_url,
    require => [ File['/var/lib/tftpboot'], Class['pe_razor'] ],
  }

  # The iPXE kernel will fetch a bootstrap.ipxe file, that then aims a chain
  # loader at the Razor server to determine how to proceed.  For instance, new
  # machines are simply told to load a microkernel.
  # The bootstrap is static, but Razor likes to be the one to craft it.
  staging::file { 'bootstrap.ipxe':
    target      => '/var/lib/tftpboot/bootstrap.ipxe',
    source      => $bootstrap_ipxe_url,
    curl_option => '--insecure',
    require     => [ File['/var/lib/tftpboot'], Class['pe_razor'] ],
  }

  # Supply just enough dhcp configuration so that all network-booting machines
  # are instructed to load the iPXE (undionly) kernel.  And when the iPXE kernel
  # requests configuration from dhcp, it gets aimed at the bootstrap.ipxe file.
  file { '/etc/dnsmasq.d/ipxe':
    ensure  => file,
    content => template('pe_razor_complete/ipxe.erb'),
    require => Package['dnsmasq'],
    notify  => Service['dnsmasq'],
  }

}
