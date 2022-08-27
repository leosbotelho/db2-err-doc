use strict;

my @r = qw(
  SQL0000 SQL0249
  SQL0250 SQL0499
  SQL0500 SQL0749
  SQL0750 SQL0999
  SQL1000 SQL1249
  SQL1250 SQL1499
  SQL1500 SQL1749
  SQL1750 SQL1999
  SQL2000 SQL2249
  SQL2250 SQL2499
  SQL2500 SQL2749
  SQL2750 SQL2999
  SQL3000 SQL3249
  SQL3250 SQL3499
  SQL3500 SQL3749
  SQL3750 SQL3999
  SQL4000 SQL4999
  SQL5000 SQL5999
  SQL6000 SQL6999
  SQL7000 SQL9999
  SQL10000 SQL19999
  SQL20000 SQL20249
  SQL20250 SQL20499
  SQL20500 SQL20999
  SQL21000 SQL27499
  SQL27500 SQL27999
  SQL28000 SQL33999
);

my $url = 'https://www.ibm.com/docs/en/db2/11.5?topic=messages-';

for (my $i = 0;$i < @r;$i += 2) {
  my $s = lc $r[$i] . '-' . lc $r[$i+1];

  if (open my $fh, '-|', ('curl', '-o', './in/sqlmsg/' . $s, $url . $s)) {
    close $fh or print "$s might've failed\n";
  } else {
    print "$s failed\n";
  }

  sleep 1;
}
