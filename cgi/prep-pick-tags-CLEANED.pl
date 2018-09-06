#!/usr/bin/perl 
 use DBI;
 use Net::Curl::Easy;
 
  #todebug
 #$yesdebug  =1;
 
 $dbh = DBI->connect( "dbi:Pg:dbname=fg;host=rds.freshgrillfoods.com;port=5432;",  '**REMOVED**', '**REMOVED**',
   { RaiseError => 0,PrintError =>1} )
 || warn "Cannot connect to database: $DBI::errstr";
 
 $dbh2 = DBI->connect( "dbi:Pg:dbname=fg;host=rds.freshgrillfoods.com;port=5432;",  '**REMOVED**', '**REMOVED**',
   { RaiseError => 0,PrintError =>1} )
 || warn "Cannot connect to database: $DBI::errstr";
 
 
 $begintime      = time();
 $date_as_string = localtime;
 
 
 
 
 sub init {
      my $curl = Net::Curl::Easy->new;
 
      $curl->setopt(Net::Curl::Easy::CURLOPT_URL(),"https://www.sku-keeper.com/api");
      $curl->setopt(Net::Curl::Easy::CURLOPT_HEADER(), 1);
      $curl->setopt(Net::Curl::Easy::CURLOPT_USERAGENT(), 'PHP script');
      $curl->setopt(Net::Curl::Easy::CURLOPT_FOLLOWLOCATION(), 1);
      $curl->setopt(Net::Curl::Easy::CURLOPT_COOKIEJAR(), "cookie.txt");
      $curl->setopt(Net::Curl::Easy::CURLOPT_COOKIEFILE(), 'cookie.txt');
      $curl->setopt(Net::Curl::Easy::CURLOPT_POST(), 1);
      $curl->setopt(Net::Curl::Easy::CURLOPT_POSTFIELDS(), "name=**REMOVED**&pass=**REMOVED**&form_id=user_login_block");
 
      my $retcode = $curl->perform;
  }
  
  sub lightDevice {
        my $cmd = shift;
        my $devID = shift;
        my $line1 = shift;
        my $line2 = shift;
        my $confirm = shift;
        my $time = shift;
        my $flash = shift;
   
        if (!defined $confirm) {
            $confirm = 99;
        }
   
        if (!defined $time) {
            $time = 0;
        }
   
        if (!defined $flash) {
            $flash = 1;
        }
        if (!defined $cmd) {
            $cmd = 'flash';
        }
   
   
   
        my $curl = Net::Curl::Easy->new;
   
        $curl->setopt(Net::Curl::Easy::CURLOPT_HEADER(), 1);
        $curl->setopt(Net::Curl::Easy::CURLOPT_COOKIEFILE(), "cookie.txt");
        $curl->setopt(Net::Curl::Easy::CURLOPT_URL(),"https://www.sku-keeper.com/api/$devID/$cmd/$line1/$line2/15,c5,4/$time/$confirm");
   
        my $retcode = $curl->perform;
    }
  #init();
  
  #get form
       my $method = $ENV{'REQUEST_METHOD'};
   
       if ( $method eq "GET" ) {
           $text = $ENV{'QUERY_STRING'};
   
       }
       else {    # default to POST
           read( STDIN, $text, $ENV{'CONTENT_LENGTH'} );
   
           #print "TEXT:$text, $ENV{'CONTENT_LENGTH'}";
       }
   
       my @value_pairs = split( /&/, $text );
       %form_results = ();
   
       foreach $pair (@value_pairs) {
           ( $key, $value ) = split( /=/, $pair );
           $value =~ tr/+/ /;
           $value =~ s/%([\dA-Fa-f][\dA-Fa-f])/pack ("C", hex ($1))/eg;
           $value =~ tr/A-Za-z0-9\ \,\.\:\/\@\-\!\"\_\{\}//dc;
           $value =~ s/^\s+//g;
           $value =~ s/\s+$//g;
   
           if ( ( ( $key =~ /outs/i ) || ( $key =~ /ins/i ) ) && ( $value == 0 ) )
           {
               next;
   
               #code
           }
   
           if  (( $key =~ /subanswer/i )&& ( $value ne "nothing" ))   {
               $invoicelist = $key . ":" . $value;
               push( @orderinvoice, $invoicelist );
           }
               if ( ( ( $key =~ /outs/i ) || ( $key =~ /ins/i ) ) && ( $value > 0 ) ) {
               $itemlist = $key . ":" . $value;
               push( @orderitems, $itemlist );
           }
           $form_results{$key} = $value;    # store the key in the results hash
           $formsubmitted .= "|$key = $form_results{$key}|";
   }
   
   #end get form
 
  #check logged in
   $rcvd_cookies = $ENV{'HTTP_COOKIE'};
  
          @cookies      = split /;/, $rcvd_cookies;
          $userid       = 0;
          $gotcookie    = 0;
          foreach $cookie2 (@cookies) {
              if ( $cookie2 =~ /temp-id/ ) {
  
                  $gotcookie = 1;
                  ( undef, $userid ) = split( /=/, $cookie2 );
  
                  $sql = qq(
          select lower(email)from pick_logins where lower(temp_id) = lower(?) 
          );
                  $sth = $dbh->prepare_cached($sql)
                    or warn "Cannot prepare/execute $sql\nError: " . $sth->errstr;
                  $sth->execute( lc($userid) )
                    or warn "Cannot prepare/execute $sql\nError: " . $sth->errstr;
                  $sth->bind_columns( undef, \$email );
                  $gotsid = 0;
                  while ( $sth->fetch() ) {
                      $gotsemail = $email;
                  }
  
                  $sql = qq(
  select id,email,active from pick_logins where lower(email) = lower(?) 
          );
                  $sth = $dbh2->prepare_cached($sql)
                    or warn "Cannot prepare/execute $sql\nError: " . $sth->errstr;
                  $sth->execute( lc($gotsemail) )
                    or warn "Cannot prepare/execute $sql\nError: " . $sth->errstr;
                  $sth->bind_columns( undef, \$id, \$email, \$active );
                  $gotsid = 0;
                  while ( $sth->fetch() ) {
                      $gotsid     = $id;
                      $gotsemail  = $email;
                      $gotsactive = $active;
                  }
  
  
          }
  }
 #end checked login
 
  if($gotsemail eq""){$gotsemail = "Guest";}
  
  if ($form_results{sdate} eq "")
  {
                  $sql = qq(
          select cast(now() AT TIME ZONE 'PDT' as date);
          );
                  $sth = $dbh->prepare_cached($sql)
                    or warn "Cannot prepare/execute $sql\nError: " . $sth->errstr;
                  $sth->execute(  )
                    or warn "Cannot prepare/execute $sql\nError: " . $sth->errstr;
        while (@row = $sth->fetchrow_array()){
                      $sdate = $row[0];
                  }
  
  
  }
  else
  {
  $sdate = $form_results{sdate} ;
  
  }
  
  
   if(($gotsid == 0) || (($ENV{REMOTE_ADDR} !~ /70.165.35/) &&($gotsemail ne "kevin")))
   {
  $body = <<END_EOS;
  <div class="cute-12-tablet ">
  
  <table cellspacing=0 cellpadding=0 border=0 style=" margin-left:auto;margin-right:auto;">
  <tr><td colspan=99 ><img height=1 alt="" width=1></td></tr>
  <tr><td colspan=2 align=center><h1>Not Logged in! </h1></td></tr>
  <tr><td colspan=2 ><a href="/">Please Login </a></td></tr>
             </table>
  </div>
  END_EOS
  }
  else
 {
 
  
  $body = <<END_EOS;
  <div class="cute-12-tablet ">
  
  <table cellspacing=0 cellpadding=0 border=0 style=" margin-left:auto;margin-right:auto;">
   <tr><td colspan=2 align=center><h2>Prep for pick date: $sdate</td></tr>           </table>
  </div>
  END_EOS
  
  $body .= <<END_EOS;
  <div class="cute-12-tablet ">
  <table  border=0 style=" margin-left:auto;margin-right:auto;text-align: left;">
  END_EOS
                  $sql = qq(
           select pick_order,sales_order,count(*) as skus ,sum(qty) as qty,ceil(sum(qty)/19.0) as est_trays,min(device_hex) as device 
   from nav_orders as n
   join pick_tags as p on n.pick_order = p.location_code
   where pick_date =  ? and device_hex is not null
   group by pick_order,sales_order 
   order by pick_order;
  );
                  $sth = $dbh2->prepare_cached($sql)
                    or warn "Cannot prepare/execute $sql\nError: " . $sth->errstr;
                  $sth->execute($sdate)
                    or warn "Cannot prepare/execute $sql\nError: " . $sth->errstr;
  $body .= "<tr><th>". join("</th><th>",@{ $sth->{NAME_lc} })."</th></tr>\n";
  
  $count =0;
  
        while (@row = $sth->fetchrow_array()){
        @row = map { lc } @row;
  if ($count%2){$bgclass = " class=\"odd\" ";}else {$bgclass = "";}
  #$body .= "<tr $bgclass><td>". join("</td><td>",@row)."</td></tr>\n";
  $body .= <<END_EOS;
  <tr $bgclass>
  <td>$row[0]</td>
  <td>$row[1]</td>
  <td>$row[2]</td>
  <td>$row[3]</td>
  <td>$row[4]</td>
  <td>$row[5]</td>
  </tr>
  END_EOS
  $count++;
  #send intial device info
   #lightDevice('static',$row[5], "sku 0/$row[2]", "qty /$row[3]",1);
   #lightDevice('static2',$row[5], "bin $row[0]", "$row[1]",1);
 
  
    #
    ##lightDevice('F8E0A7:1A84E6', 'hell', 'yeah');
    ##lightDevice('flash','F8E0A7:1A84E6', 'put item 44402', 'qty 22','so123-123');
    ##lightDevice('static','F8E0A7:1A84E6', 'sku 21/22', 'qty333/244');
    ##lightDevice('static2','F8E0A7:1A84E6', 'bin 1', 'so123-123');
   }
   
   
   $body .= <<END_EOS;
   </table>
   </div>
   END_EOS
   
   
   }
   
   
   print("Content-type: text/html\r\n\r\n");
       print <<END_OF_HTML;
   <!DOCTYPE html>
   <html>
   <head>
         <meta charset="utf-8">
             <meta http-equiv="X-UA-Compatible" content="IE=edge">
                 <meta name="viewport" content="width=device-width, initial-scale=1">
                 <title>Fresh Grill Pick Portal</title>
       <link rel="icon" href="/favicon.ico" type="image/ico"/> 
       <!-- Bootstrap -->
          <link rel="stylesheet" href="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css">
          <link href='http://fonts.googleapis.com/css?family=Open+Sans:400,600,700' rel='stylesheet' type='text/css'>
       <link rel="stylesheet" href="/css/normalize.css">
       <link rel="stylesheet" href="/css/cutegrids.css">
       <link href="/css/style.css" rel="stylesheet">
   
       <script src="https://ajax.googleapis.com/ajax/libs/jquery/3.1.1/jquery.min.js"></script>
   
       <!-- HTML5 shim and Respond.js for IE8 support of HTML5 elements and media queries -->
       <!-- WARNING: Respond.js doesn't work if you view the page via file:// -->
       <!--[if lt IE 9]>
         <script src="https://oss.maxcdn.com/html5shiv/3.7.2/html5shiv.min.js"></script>
         <script src="https://oss.maxcdn.com/respond/1.4.2/respond.min.js"></script>
     <![endif]-->
        <script>
     \$(document).ready(function(){
         \$("#nav-mobile").html(\$("#nav-main").html());
         \$("#nav-trigger span").click(function(){
             if (\$("nav#nav-mobile ul").hasClass("expanded")) {
                 \$("nav#nav-mobile ul.expanded").removeClass("expanded").slideUp(250);
                 \$(this).removeClass("open");
             } else {
                 \$("nav#nav-mobile ul").addClass("expanded").slideDown(250);
                 \$(this).addClass("open");
             }
         });
     });
 </script>
  <style>
 th, td {
         padding: 5px;
             text-align: left;
 }
 .odd {background-color:#ddd}
 </style>
  </head>
 
 <body > 
 
    <header class="header">
         <div class="brand-logo container text-center">
             <a href="/dashboard.pl?sdate=$sdate"> <img src="/images/logo.png" alt="Mffais" /></a>
         </div>
 
     <div class="row text-center">
         <div class="cute-12-tablet">
 $gotsemail - <a href="/logout.pl">Log Out</a>
 </div>
 </div>
 
     </header>
     <div class="row text-center">
         <div class="cute-12-tablet">
 <h1>Initial Setup of Pick Devices for Pick Date: $date</h1>
 </div>
 $body
 </div> 
 
     <footer class="text-center">
          <div class="row">
          <p class="copyright">© Copyright Mreshgrillfoods.com 2017</p>
          </div>
      </footer>
      <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.11.2/jquery.min.js"></script>
      <!-- Include all compiled plugins (below), or include individual files as needed -->
      <script src="https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js"></script>
  
              </body>
               </html>
  
 END_OF_HTML
  