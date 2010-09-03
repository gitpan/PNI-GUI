package PNI::GUI;

use Mouse;

our $VERSION = '0.04';

use Tk;
use PNI;
use PNI::GUI::Window;

#use File::Spec;

# this is a hook to PNI so Tk::Mainloop and PNI::LOOP can coexist.
PNI::NODE 'Jolly', task => sub { &DoOneEvent for ( 0 .. 50 ) };

sub start_up {
    new PNI::GUI::Window;
    PNI::LOOP;
}

1;

__END__

=head1 NAME

PNI::GUI - Perl Node Interface GUI

=head1 SYNOPSIS

use PNI::GUI;

PNI::GUI::start_up;

# or better, just call pnigui.pl from commandline
#
# or even perl -MPNI::GUI::STARTUP

=head1 DESCRIPTION

This is a Tk implementation of a minimalistic GUI for the Perl Node Interface. 
What I intend for a "Node Interface" ? 
Suppose you want to open a file, parse it and send it by mail: 
immagine you have three boxes named "file", "parse" and "mail" in a canvas,
and you connect them together with lines and in the meanwhile there is an
engine that it is executing your "Picture" while you are drawing it ...
ok maybe it's easier that you give it a try rather then i try to explain it :) 

=head1 SEE ALSO

PNI
PNI::Node
PNI::Link

pnigui

=head1 AUTHOR

G. Casati , E<lt>fibo@cpan.orgE<gt>

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2010 by G. Casati

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself .

=cut

