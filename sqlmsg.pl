use strict;
use Data::Dumper;
use Mojo::DOM58;

'
-1553: ok

01669: err
01670: ^

-8019: ok

429BO: err
42501: ^

-20065: ok
';

sub trim { $_[0] =~ s/^\s+|\s+$//gr }

sub innerHtml {
  my $s = '';
  $s .= $_->to_string foreach (@{$_[0]->child_nodes});
  $s;
}

my $this = {};

my %stLen = ();

my $data = {};
my %idx = ();

my $st = {};
my $stOod = {};

my @files;
{
  opendir my $dh, './in/sqlmsg' or die;
  @files = readdir $dh or die;
  closedir $dh or die;
}

foreach my $fname (@files) {
  next if $fname eq '.' or $fname eq '..';

  my $dom;
  {
    open my $fh, '<', './in/sqlmsg/' . $fname or die;
    local $/;
    my $out = <$fh> or die;
    close $fh or die;

    $dom = Mojo::DOM58->new($out);
  }

  foreach my $e0 ($dom->find('main article')->each) {
    my $id = $e0->{id};

    if ($id =~ /^sql/i) {
      $id = uc $id;

      my $c;
      my @st = ();
      my $stOod_ = 0;

      my $shortDesc;
      {
        my @shortDesc = @{$e0->find('.msghead > .shortdesc')};
        die unless @shortDesc == 1;
        $shortDesc = $shortDesc[0]->text;
      }

      my %explanation;
      {
        my @explanation = @{$e0->find('.msgBody > .msgExplanation')};
        unless (@explanation == 1) {
          die if @explanation > 1;
        } else {
          my $e = $explanation[0];
          $e->find('.sectiontitle')->first->remove;

          %explanation = (explanation => trim innerHtml ($e));
        }
      }

      my $e;
      my %userResponse;
      {
        my @userResponse = @{$e0->find('.msgBody > .msgUserResponse')};
        die unless @userResponse < 2;
        if (@userResponse) {
          $e = $userResponse[0];
          $e->find('.sectiontitle')->first->remove;

          %userResponse = (userResponse => trim innerHtml ($e));
        }
      }

      die if exists $data->{$id};
      $data->{$id} = {
        fname => $fname,
        shortDesc => $shortDesc,
        %explanation,
        %userResponse
      };

      if (defined $e) {
        foreach my $p ($e->find('p')->each) {
          foreach my $strong ($p->find('strong')->each) {
            if ($strong->text =~ /^sql(state|code)$/) {
              my $t = $1;
              my $s0 = $p->text;
              my $s = trim ($s0 =~ s/\s*:\s*//r);

              $p->remove;

              if ($s0 =~ /\s*:/) {
                if ($t eq 'code') {
                  if (defined $c) {
                    #
                    if ($s eq '429BO' or $s eq '42501' or $s eq '01669' or $s eq '01670') {
                      @st = ($s);
                    } else {
                      $this->{$id}{duplicateCode} = '';
                    }
                  } else {
                    unless ($s =~ /(\+|-)?[0-9]+/) {
                      $this->{$id}{invalidCode} = $s;
                    } else {
                      $c = $s + 0;
                    }
                  }
                } else {
                  if ($s =~ /[0-9] \s* (\s* , \s* [0-9])* /x) {
                    foreach (split /\Q,/, $s) {
                      my $s_ = uc trim ($_);
                      $stLen{length $s_}++;
                      push @st, $s_;
                    }
                  } else {
                    $stLen{length $s}++;
                    @st = ($s);
                    $stOod_ = 1;
                  }
                }
              }
            }
          }
        }

        unless ($this->{$id}) {
          my $b = defined $c;

          if ($b) {
            die if exists $idx{$c};
            $idx{$c} = $id;
          }

          if (!@st or !$b) {
            unless (!@st and !$b) {
              if (!@st) {
                #
                unless ($c == -1553 or $c == -8019 or $c == -20065) {
                  $this->{$id}{missingState} = '';
                }
              }
              $this->{$id}{missingCode} = '' if !$b;
            }
          } else {
            if ($stOod_) {
              push @{$stOod->{$st[0]}}, $c;
            } else {
              foreach (@st) {
                my $l0 = substr ($_, 0, 2);
                push @{$st->{$l0}{$_}}, $c;
              }
            }
          }
        }
      }
    }
  }
}

$Data::Dumper::Terse = 1;
$Data::Dumper::Indent = 0;

print 'our $data = ', Dumper($data), ";\n\n";
print 'our $idx = ', Dumper(\%idx), ";\n\n";
print 'our $st = ', Dumper($st), ";\n\n";
print 'our $stOod = ', Dumper($stOod), ";\n\n";
