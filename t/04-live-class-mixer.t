#!perl

use strict;
use warnings;
use Test::More;
use Module::Build;

eval "use Net::SNMP";
plan skip_all => "Net::SNMP required for testing Net::SNMP::Mixin module"
  if $@;

eval "use Net::SNMP::Mixin";
plan skip_all =>
  "Net::SNMP::Mixin required for testing Net::SNMP::Mixin module"
  if $@;

plan tests => 12;

#plan 'no_plan';

is( Net::SNMP->mixer('Net::SNMP::Mixin::Dot1qVlanStatic'),
  'Net::SNMP', 'mixer returns the class name' );

my $builder        = Module::Build->current;
my $snmp_agent     = $builder->notes('snmp_agent');
my $snmp_community = $builder->notes('snmp_community');
my $snmp_version   = $builder->notes('snmp_version');

SKIP: {
  skip '-> no live tests', 7, unless $snmp_agent;

  my ( $session, $error ) = Net::SNMP->session(
    hostname  => $snmp_agent,
    community => $snmp_community || 'public',
    version   => $snmp_version || '2c',
  );

  ok( !$error, 'got snmp session for live tests' );
  isa_ok( $session, 'Net::SNMP' );
  ok(
    $session->can('map_vlan_static_ids2names'),
    'can $session->map_vlan_static_ids2names'
  );
  ok(
    $session->can('map_vlan_static_ids2ports'),
    'can $session->map_vlan_static_ids2ports'
  );
  ok(
    $session->can('map_vlan_static_ports2ids'),
    'can $session->map_vlan_static_ports2ids'
  );

  eval { $session->init_mixins };
  ok( !$@, 'init_mixins successful' );

  eval { $session->init_mixins(1) };
  ok( !$@, 'already initalized but reload forced' );

  eval { $session->init_mixins };
  like(
    $@,
    qr/already initalized and reload not forced/i,
    'already initalized and reload not forced'
  );

  eval { $session->map_vlan_static_ids2names };
  ok( !$@, 'map_vlan_static_ids2names' );

  eval { $session->map_vlan_static_ids2ports };
  ok( !$@, 'map_vlan_static_ids2ports' );

  eval { $session->map_vlan_static_ports2ids };
  ok( !$@, 'map_vlan_static_ports2ids' );

}

# vim: ft=perl sw=2
