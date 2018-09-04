#!/usr/bin/env perl
use strict;
use warnings;
use Net::Curl::Easy;
use Mojolicious::Lite;


my $name = 'yourname';
my $pass = 'yourpassword';


sub init {
	my $curl = Net::Curl::Easy->new;

	$curl->setopt(Net::Curl::Easy::CURLOPT_URL(),"https://www.sku-keeper.com/api");
	$curl->setopt(Net::Curl::Easy::CURLOPT_HEADER(), 1);
	$curl->setopt(Net::Curl::Easy::CURLOPT_USERAGENT(), 'PHP script');
	$curl->setopt(Net::Curl::Easy::CURLOPT_FOLLOWLOCATION(), 1);
	$curl->setopt(Net::Curl::Easy::CURLOPT_COOKIEJAR(), "cookie.txt");
	$curl->setopt(Net::Curl::Easy::CURLOPT_COOKIEFILE(), 'cookie.txt');
	$curl->setopt(Net::Curl::Easy::CURLOPT_POST(), 1);
	$curl->setopt(Net::Curl::Easy::CURLOPT_POSTFIELDS(), "name=$name&pass=$pass&form_id=user_login_block");

	my $retcode = $curl->perform;
}

sub lightDevice {
	my $devID = shift;
	my $line1 = shift;
	my $line2 = shift;
	my $time = shift;
	my $flash = shift;

	if (!defined $time) {
		$time = 10;
	}

	if (!defined $flash) {
		$flash = 1;
	}

	my $cmd = 'pick';
	if ($flash) {
		$cmd = 'message';
	}

	my $curl = Net::Curl::Easy->new;

	$curl->setopt(Net::Curl::Easy::CURLOPT_HEADER(), 1);
	$curl->setopt(Net::Curl::Easy::CURLOPT_COOKIEFILE(), "cookie.txt");
	$curl->setopt(Net::Curl::Easy::CURLOPT_URL(),"https://www.sku-keeper.com/api/$devID/$cmd/$line1/$line2/15,c5,4/$time");

	my $retcode = $curl->perform;
}

#init();
#lightDevice('E8D787:72D9D7', 'hell', 'yeah');
#lightDevice('FFFE81:A42B35', 'hell', 'yeah');
#lightDevice('FAAD4B:8E336A', 'hell', 'yeah');
#lightDevice('FF754A:E24C16', 'hell', 'yeah');
#lightDevice('FB9915:C956FC', 'hell', 'yeah');

any '/' => sub {
	my $self = shift;

	print "Content-type: text/html\n\n";
	init();
	#lightDevice($self);
	lightDevice('FB9915:C956FC', 'hell', 'yeah');

	$self->render(text => 'FreshGrill Food robotics', format => 'text');
};

#any 'app.pl' => sub {
#	my $self = shift;

	#init();
	#lightDevice($self);

#	$self->render(text => 'FreshGrill Food robotics', format => 'json');
#};

app->start;
