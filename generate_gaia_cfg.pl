#!/usr/bin/env perl

=pod

=head1 Using the script for generate Check Point Gaia configs
#===============================================================================
#
#         FILE: generate_gaia_cfg.pl
#
#        USAGE: ./generate_gaia_cfg.pl fw_ip_net.xlsx
#
#  DESCRIPTION: Generate Check Point Gaia configs
#
#      OPTIONS: ---
# REQUIREMENTS: Perl v5.14+ 
#         BUGS: ---
#        NOTES: ---
#       AUTHOR: Vladislav Sapunov 
# ORGANIZATION:
#      VERSION: 1.0.0
#      CREATED: 18.03.2024 22:48:36
#     REVISION: ---
#===============================================================================
=cut

use strict;
use warnings;
use v5.14;
use utf8;
use Spreadsheet::Read;

#use Data::Dumper; # for debug
my $inNetworks = $ARGV[0];

# Source XLSX File with groups names
my $workbook = ReadData($inNetworks) or die "Couldn't Open file " . "$!\n";
my $sheet = $workbook->[1];

our @netColumn; # array of collumns E, F, G, H, I, J, K, L, M, N 
our @gwColumn; # array of collumns B, D
our @hnColumn; # array of collumn A
our @ipAndMask; # # array of $firstIP, $endIP, $bit

for (2 .. 12) {
	@netColumn = ($sheet->{cell}[5][$_], $sheet->{cell}[6][$_], $sheet->{cell}[7][$_], $sheet->{cell}[8][$_], $sheet->{cell}[9][$_], $sheet->{cell}[10][$_], $sheet->{cell}[11][$_], $sheet->{cell}[12][$_], $sheet->{cell}[13][$_], $sheet->{cell}[14][$_]);
	@gwColumn = ($sheet->{cell}[2][$_], $sheet->{cell}[4][$_]);
	@hnColumn = ($sheet->{cell}[1][$_]);
	&get_ip;
	#&show_data; # uncomment for view data of table
	&gen_cfg;
   	@ipAndMask = undef;
	@netColumn = undef;
}

sub get_ip {
	foreach my $row(@netColumn) {
		$row =~ /^((\d+)\.(\d+)\.(\d+)\.(\d+))\/(\d+)$/;
    	my $net     = $1;
   		my $bit     = $6;
		my $fip = $5+1;
		my $eip = $5 + ((2 ** (32-$6))-2);
    	my $firstIP = "$2.$3.$4.$fip";
		my $endIP = "$2.$3.$4.$eip";
		#say "first ip: $firstIP \t end ip: $endIP \t mask: $bit";
		push(@ipAndMask, "$firstIP", $endIP, "$bit");
	}
}
sub show_data {
	say "-=-"x12;
	say "$hnColumn[0]";
	say "-=-"x12;
	#    $firstIP		$endIP		 $bit
	say "$ipAndMask[1]\t$ipAndMask[2]\t$ipAndMask[3]"; # VLAN 10
	say "$ipAndMask[4]\t$ipAndMask[5]\t$ipAndMask[6]"; # VLAN 20
	say "$ipAndMask[7]\t$ipAndMask[8]\t$ipAndMask[9]"; # VLAN 30
	say "$ipAndMask[10]\t$ipAndMask[11]\t$ipAndMask[12]"; # VLAN 40
	say "$ipAndMask[13]\t$ipAndMask[14]\t$ipAndMask[15]"; # VLAN 50
	say "$ipAndMask[16]\t$ipAndMask[17]\t$ipAndMask[18]"; # VLAN 60
	say "$ipAndMask[19]\t$ipAndMask[20]\t$ipAndMask[21]"; # VLAN 70
	say "$ipAndMask[22]\t$ipAndMask[23]\t$ipAndMask[24]"; # VLAN 80
	say "$ipAndMask[25]\t$ipAndMask[26]\t$ipAndMask[27]"; # VLAN 90
	say "$ipAndMask[28]\t$ipAndMask[29]\t$ipAndMask[30]"; # VLAN 100 
	say "-=-"x12;
	say "$gwColumn[0] $gwColumn[1]";
	say "-=-"x12;
	say " "x12;

}

sub gen_cfg {
	# Result outFile of Gaia Embedded configs
	my $outFile     = "FW-$hnColumn[0]_cfg.txt";

	# Open result outFile for writing
	open( FHW, '>', $outFile ) or die "Couldn't Open file $outFile" . "$!\n";

	my $cpConfig=<<__CFG__;
#----------------------------------------------------------------------------------------
lock database override
set hostname FW-$hnColumn[0]

set interface eth1 auto-negotiation on
set interface eth2 auto-negotiation on
set interface eth1 state on
set interface eth2 state on
add bonding group 1
add bonding group 1 interface eth1
add bonding group 1 interface eth2
add interface bond1 vlan 10
add interface bond1 vlan 20
add interface bond1 vlan 30
add interface bond1 vlan 40
add interface bond1 vlan 50
add interface bond1 vlan 60
add interface bond1 vlan 70
add interface bond1 vlan 80
add interface bond1 vlan 90
add interface bond1 vlan 100
set interface eth3 auto-negotiation on
set interface eth3 state on

set interface bond1.10 comments "VLAN 10"
set interface bond1.10 state on
set interface bond1.10 ipv4-address $ipAndMask[1] mask-length $ipAndMask[2]
set interface bond1.20 comments "VLAN 20"
set interface bond1.20 state on
set interface bond1.20 ipv4-address $ipAndMask[4] mask-length $ipAndMask[5]
set interface bond1.30 comments "VLAN 30"
set interface bond1.30 state on
set interface bond1.30 ipv4-address $ipAndMask[7] mask-length $ipAndMask[8]
set interface bond1.40 comments "VLAN 40"
set interface bond1.40 state on
set interface bond1.40 ipv4-address $ipAndMask[10] mask-length $ipAndMask[11]
set interface bond1.50 comments "VLAN 50"
set interface bond1.50 state on
set interface bond1.50 ipv4-address $ipAndMask[13] mask-length $ipAndMask[14]
set interface bond1.60 comments "VLAN 60"
set interface bond1.60 state on
set interface bond1.60 ipv4-address $ipAndMask[16] mask-length $ipAndMask[17]
set interface bond1.70 comments "VLAN 70"
set interface bond1.70 state on
set interface bond1.70 ipv4-address $ipAndMask[19] mask-length $ipAndMask[20]
set interface bond1.80 comments "VLAN 80"
set interface bond1.80 state on
set interface bond1.80 ipv4-address $ipAndMask[22] mask-length $ipAndMask[23]
set interface bond1.90 comments "VLAN 90"
set interface bond1.90 state on
set interface bond1.90 ipv4-address $ipAndMask[25] mask-length $ipAndMask[26]
set interface bond1.100 comments "VLAN 100"
set interface bond1.100 state on
set interface bond1.100 ipv4-address $ipAndMask[28] mask-length $ipAndMask[29]
set interface eth3 comments "External"
set interface eth3 state on
set interface eth3 ipv4-address $gwColumn[1] mask-length 30

set static-route default nexthop gateway address $gwColumn[0] priority 1 on
set static-route default nexthop gateway address 192.168.1.254 off

set management interface eth3.150

delete interface Mgmt ipv4-address
set interface Mgmt state off

set timezone Etc / GMT+3

#----------------------------------------------------------------------------------------
dynamic_objects -n ggr_LocalNet
dynamic_objects -n ggr_DMZNet
dynamic_objects -n ggr_LocalDHCP

dynamic_objects -o ggr_LocalNet -r 127.0.0.1 127.0.0.1 -a
dynamic_objects -o ggr_LocalNet -r $ipAndMask[1] $ipAndMask[3] -a # VLAN 10
dynamic_objects -o ggr_LocalNet -r $ipAndMask[4] $ipAndMask[6] -a # VLAN 20
dynamic_objects -o ggr_LocalNet -r $ipAndMask[7] $ipAndMask[9] -a # VLAN 30
dynamic_objects -o ggr_LocalNet -r $ipAndMask[10] $ipAndMask[12] -a # VLAN 40
dynamic_objects -o ggr_LocalNet -r $ipAndMask[13] $ipAndMask[15] -a # VLAN 50

dynamic_objects -o ggr_DMZNet -r $ipAndMask[16] $ipAndMask[18] -a # VLAN 60
dynamic_objects -o ggr_DMZNet -r $ipAndMask[19] $ipAndMask[21] -a # VLAN 70
dynamic_objects -o ggr_DMZNet -r $ipAndMask[22] $ipAndMask[24] -a # VLAN 80
dynamic_objects -o ggr_DMZNet -r $ipAndMask[25] $ipAndMask[27] -a # VLAN 90
dynamic_objects -o ggr_DMZNet -r $ipAndMask[28] $ipAndMask[30] -a # VLAN 100

dynamic_objects -o ggr_LocalDHCP -r 127.0.0.1 127.0.0.1 -a
#----------------------------------------------------------------------------------------
__CFG__

	say FHW "$cpConfig";

	# Close the filehandle
	close(FHW) or die "$!\n";

	say "**********************************************************************************\n";
	say "Gaia Cfg file: $outFile created successfully!";
	say "**********************************************************************************\n";	
} 

