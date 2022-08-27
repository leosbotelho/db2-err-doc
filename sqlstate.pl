my $s;
{
  open my $fh, '<', 'in/sqlstate' or die;
  local $/;
  $s = <$fh> or die;
  close $fh or die;
}

while ($s =~ /\G^([0-9A-Z]{2})\s+(.+?)\s+Table [0-9]+\n/mg) {
  print "$1 $2\n";
}
