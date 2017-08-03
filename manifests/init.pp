# This main class simply includes the subclasses that install PE razor and the
# additional services that it depends on to PXE boot machines.
#
# Parameters are described in comments preceding them in the class definition.
#
# This module requires three forge modules in order to function:
#     nanliu-staging
#     puppetlabs-firewall
#     puppetlabs-stdlib

class pe_razor_complete (
  # What interface, and what IP range should the DHCP server use?
  $dnsmasq_dns_enable   = true,
  $dnsmasq_dhcp_enable  = true,
  $dnsmasq_dhcp_start   = '10.11.12.100',
  $dnsmasq_dhcp_end     = '10.11.12.200',
  $dnsmasq_dhcp_netmask = '255.255.255.0',
  $dnsmasq_dhcp_lease   = '24h',
  $dnsmasq_interface    = eth1,
  $ipxe_url             = 'https://s3.amazonaws.com/pe-razor-resources/undionly-20140116.kpxe',
  $bootstrap_ipxe_url   = "https://${::facts['fqdn']}:8151/api/microkernel/bootstrap?nic_max=1&http_port=8150",
  $tftp_port_range      = '2700,2750',

  # Try to act as a NAT router so DHCP machines can get out?
  $ipv4_nat             = true,
  $ipv4_nat_outiface    = 'eth0',

) {

  include pe_razor_complete::server
  include pe_razor_complete::client
  include pe_razor_complete::dhcp
  include pe_razor_complete::pxe
  include pe_razor_complete::dns

  if ( $ipv4_nat == true ) {
    include pe_razor_complete::ipv4_nat
  }

}
