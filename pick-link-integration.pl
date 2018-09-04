#!/usr/bin/env perl

#use strict;
#use warnings;
use WWW::Curl::Easy;
 
sub init {
	my $curl = WWW::Curl::Easy->new;
	 
	$curl->setopt(CURLOPT_URL,"https://www.sku-keeper.com/api");
	$curl->setopt(CURLOPT_HEADER, 1);
	$curl->setopt(CURLOPT_USERAGENT, 'PHP script');
	$curl->setopt(CURLOPT_FOLLOWLOCATION, 1);
	$curl->setopt(CURLOPT_COOKIEJAR, "cookie.txt");
	$curl->setopt(CURLOPT_COOKIEFILE, 'cookie.txt');
	$curl->setopt(CURLOPT_POST, 1);
	$curl->setopt(CURLOPT_POSTFIELDS, "name=yourname&pass=yourpassword&form_id=user_login_block");

	my $retcode = $curl->perform;
}

sub lightDevice {
	my $devID = shift;
	my $line1 = shift;
	my $line2 = shift;
	my $time = 10;
	my $flash = 1;

	my $cmd = 'pick';
	if ($flash) {
		$cmd = 'message';
	}

	my $curl = WWW::Curl::Easy->new;

	$curl->setopt(CURLOPT_HEADER, 1);
	$curl->setopt(CURLOPT_RETURNTRANSFER, 1);
	$curl->setopt(CURLOPT_COOKIEFILE, "cookie.txt");
	$curl->setopt(CURLOPT_URL,"https://www.sku-keeper.com/api/$devID/$cmd/$line1/$line2/15,c5,4/$time");

	my $retcode = $curl->perform;
}

init();
lightDevice('E8D787:72D9D7', 'hell', 'yeah');
lightDevice('FFFE81:A42B35', 'hell', 'yeah');
lightDevice('FAAD4B:8E336A', 'hell', 'yeah');
lightDevice('FF754A:E24C16', 'hell', 'yeah');
lightDevice('FB9915:C956FC', 'hell', 'yeah');
