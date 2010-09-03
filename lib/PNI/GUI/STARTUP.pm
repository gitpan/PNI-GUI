package PNI::GUI::STARTUP;

use PNI::GUI;

sub import {
    PNI::GUI::start_up;
}

1;

=head1 NAME

PNI::GUI::STARTUP - Perl Node Interface cheat module to start PNI::GUI

=head1 SYNOPSIS

perl -MPNI::GUI::STARTUP

=head1 DESCRIPTION

This is just a convenience module to start PNI::GUI .
It was written as a trick for pni.c code .

=head1 SEE ALSO

PNI::GUI

pnigui

=head1 AUTHOR

G. Casati , E<lt>fibo@cpan.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2010 by G. Casati

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself .

=cut
