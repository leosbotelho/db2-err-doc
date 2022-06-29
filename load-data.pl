use strict;
require './out/sqlmsg.pl';

our $sqlstate = [];
{
  open my $fh, '<', 'out/sqlstate' or die;
  while (!eof $fh) {
    my $line = <$fh>;
    defined $line or die;

    $line =~ /(.+?)[ ](.+)/;
    push @$sqlstate, [$1, $2];
    if ($1 eq '0N') {
      push @$sqlstate, ['10', 'XQuery error'];
    }
  }
  close $fh or die;
}

our %sqlstateSubcode = ();
{
  open my $fh, '<', 'out/sqlstate-subcode' or die;
  my $st;
  my $s;
  while (!eof $fh) {
    my $line = <$fh>;
    defined $line or die;

    if ($line =~ /^([A-Z0-9]{5})[ ]\t(.+)/) {
      $st = $1;
      $sqlstateSubcode{$st} = $2;
    } else {
      $sqlstateSubcode{$st} .= $line;
    }
  }
  close $fh or die;
}

1;
