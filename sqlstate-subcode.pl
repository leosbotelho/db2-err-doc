my $s;
{
  open my $fh, '<', 'in/sqlstate-subcode' or die;
  local $/;
  $s = <$fh> or die;
  close $fh or die;
}

my $re = qr/
^Class [ ] Code .+? \n

Table [ ] [0-9]+\. .+? \n

SQLSTATE .+? \n

\t \n

Meaning \n

(?<tbl>(?s).+?)
(?=Class[ ]Code|\z)
/mx;

while ($s =~ /\G$re/mg) {
  print $+{tbl};
}
