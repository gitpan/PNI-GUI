package PNI::GUI;
use Mojo::Base 'Mojolicious';

use File::Basename 'dirname';
use File::Spec;

our $VERSION = '0.0.0';

sub startup {
    my $self = shift;

    $self->home->parse( File::Spec->catdir( dirname(__FILE__), 'GUI' ) );

    $self->static->root( $self->home->rel_dir('public') );

    $self->renderer->root( $self->home->rel_dir('templates') );

}

1
__END__

=head1 NAME

PNI::GUI - HTML5 based GUI for Perl Node Interface

=head1 SEE ALSO

L<PNI>

=cut

