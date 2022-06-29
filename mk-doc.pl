use strict;
require './load-data.pl';

sub details {
"<details class='tree-nav__item is-expandable'>
  <summary class='tree-nav__item-title'>$_[0]</summary>
  <div class='tree-nav__item'>
    $_[1]
  </div>
</details>";
}

sub codeSubtree {
  my $s = '';
  my @a = sort { $a <=> $b; } @{$_[0]};
  foreach (@a) {
    my $id = $idx->{$_};
    my $data_ = $data->{$id};

    my $shortDesc = $data_->{shortDesc};

    my $explanation = '';
    $explanation = details 'Explanation', $data_->{explanation}
      if exists $data_->{explanation};

    my $userResponse = '';
    $userResponse = details 'User Response', $data_->{userResponse}
      if exists $data_->{userResponse};

    my $sum = "<p>$id</p>" . $explanation . $userResponse;

    $s .= details "$_ $shortDesc", $sum;
  }
  $s;
}

sub subtree {
  my $a = $st->{$_[0]};
  my $s = '';
  foreach my $i (sort keys (%$a)) {
    $s .= details "$i $sqlstateSubcode{$i}", codeSubtree ($a->{$i});
  }
  $s;
}

sub tree {
  my $s = '';
  foreach my $sqlstate_ (@$sqlstate) {
    my ($i, $stDesc) = @$sqlstate_;

    $s .= details "$i $stDesc", subtree ($i);
  }
  $s;
}

sub tpl {
  my $tree = tree;

"<html>
<head>
  <link href='./ionicons.css' rel='stylesheet' type='text/css'>
  <link href='./doc.css' rel='stylesheet' type='text/css'>
</head>
<body>
$tree
</body>
</html>";
}

print tpl;
