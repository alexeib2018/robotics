#!/usr/bin/env perl
use strict;
use warnings;
use Net::Curl::Easy;


require "settings.pl";
our $name;
our $pass;


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


sub print_header {
	my $devid = shift;
	my $line1 = shift;
	my $line2 = shift;
	my $time = shift;
	my $flash = shift;

	print "Content-type: text/html\n\n";
	print "<html>
			<body>
				<div style='font-size: large; margin: 10px;'>
					FreshGrill Robotics
				</div>
				<div style='font-size: larger; margin: 10px;'>
					devid = $devid<br>
		       		line1 = $line1<br>
		       		line2 = $line2<br>
		       		time = $time<br>
		       		flash = $flash<br>
		       	</div>
		       	<div style='font-size:larger; margin:10px;' id='show_btn'>
		       		<button onclick='show_debug()'>Show Voodo Robotics debug</button>
		       	</div>
		       	<div style='font-size:larger; margin:10px; display:none;' id='hide_btn'>
		       		<button onclick='hide_debug()'>Hide Voodo Robotics debug</button>
		       	</div>
		       	<script type='text/javascript'>
		       		function show_debug() {
		       			document.getElementById('show_btn').style.display = 'none'
		       			document.getElementById('hide_btn').style.display = ''
		       			document.getElementById('voodoo_robotics_debug').style.display = ''
		       		}
		       		function hide_debug() {
		       			document.getElementById('show_btn').style.display = ''
		       			document.getElementById('hide_btn').style.display = 'none'
		       			document.getElementById('voodoo_robotics_debug').style.display = 'none'
		       		}
		       	</script>
		       	<div style='display:none' id='voodoo_robotics_debug'>
	      ";
}

sub print_footer {
	print "		</div>
			</body>
		   </html>
		  ";
}

sub get_form_data {
	my $method = $ENV{'REQUEST_METHOD'};

	my $text = '';
	if ( $method eq "GET" ) {
		$text = $ENV{'QUERY_STRING'};

	}
	else {    # default to POST
	   	read( STDIN, $text, $ENV{'CONTENT_LENGTH'} );
	}
	# print "text: $text\n";

	my @value_pairs = split( /&/, $text );

	my %form_results = ();

	foreach my $pair (@value_pairs) {
		( my $key, my $value ) = split( /=/, $pair );
		$value =~ tr/+/ /;
		$value =~ s/%([\dA-Fa-f][\dA-Fa-f])/pack ("C", hex ($1))/eg;
		$value =~ tr/A-Za-z0-9\ \,\.\:\/\@\-\!\"\_\{\}//dc;
		$value =~ s/^\s+//g;
		$value =~ s/\s+$//g;

		$form_results{$key} = $value;    # store the key in the results hash
	}
	%form_results;
}


print "Content-type: text/utf-8\n\n";
my %form_data = get_form_data();

my $devid = %form_data{'devid'};
my $line1 = %form_data{'line1'};
my $line2 = %form_data{'line2'};
my $flash = %form_data{'flash'};
my $time = %form_data{'time'};

print "devid: $devid\n";
print "line1: $line1\n";
print "line2: $line2\n";
print "flash: $flash\n";
print "time: $time\n";

q(
any '/' => sub {
	my $self = shift;
	my $devid = $self->param('devid');
	my $line1 = $self->param('line1');
	my $line2 = $self->param('line2');
	my $flash = $self->param('flash');
	my $time = $self->param('time');

	if (!defined $time) {
		$time = 10;
	}

	if (!defined $flash) {
		$flash = 1;
	}

	print_header($devid, $line1, $line2, $time, $flash);

	init();
	lightDevice($devid, $line1, $line2, $time, $flash);

	# print_footer();

	$self->render(text => '', format => 'text');
};

app->start;
);
