# This class simply declares the pe_razor class without any parameters.  If you
# want to specify parameters for the pe_razor class, the official way is to
# do that in the Enterprise Console.  Look in the PE Razor classification group
# for that.

class pe_razor_complete::server {

  # Use the pe_razor module that's included with Puppet Enterprise
  include pe_razor

  package { 'libarchive':
    ensure => present,
    before => Class['pe_razor'],
  }

  package { 'libarchive-devel':
    ensure   => present,
    provider => 'rpm',
    source   => 'http://puppetfiles.wwt.com/libarchive-devel-3.1.2-10.el7_2.x86_64.rpm',
    require  => Package['libarchive'],
  }

}
