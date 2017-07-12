# Disable DNS service
# Setting 'port' to zero completely disables DNS function, leaving only DHCP and/or TFTP.
#
class pe_razor_complete::dns {

  # Enable the dnsmasq tftp server, and aim it at /var/lib/tftpboot for files.
  file { '/etc/dnsmasq.d/dns':
    ensure  => file,
    content => 'port=0',
    require => Package['dnsmasq'],
    notify  => Service['dnsmasq'],
  }

}
