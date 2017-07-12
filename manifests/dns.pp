# Disable DNS service
# Setting 'port' to zero completely disables DNS function, leaving only DHCP and/or TFTP.
#
class pe_razor_complete::dns (
  $dnsmasq_dns_enable = $pe_razor_complete::dnsmasq_dns_enable,
) inherits pe_razor_complete {

  # if $dnsmasq_dns_enable = true
  #   ensure file is absent thus using default dnsmasq config which is to enable dns service
  # if $dnsmasq_dns_enable = false
  #   create /etc/dnsmasq.d/dns and set port=0, thus disabling the dns service
  $ensure = $dnsmasq_dns_enable ? {
    true  => 'absent',
    false => 'present',
  }

  file { '/etc/dnsmasq.d/dns':
    ensure  => $ensure,
    content => 'port=0',
    require => Package['dnsmasq'],
    notify  => Service['dnsmasq'],
  }
}
