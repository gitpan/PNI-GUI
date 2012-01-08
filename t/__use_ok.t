use strict;
use warnings;
use Test::More tests => 1;

BEGIN {
    use_ok($_)
      or BAIL_OUT(" $_ module does not compile :-(")
      for qw(
      PNI::GUI
    );
}

