package PNI::GUI;
use Mojo::Base 'Mojolicious';

use File::Basename 'dirname';
use File::Spec;

our $VERSION = '0.01.0';

sub startup {
    my $self = shift;
    $self->secret('xD');
    my $r    = $self->routes;

    $self->home->parse( File::Spec->catdir( dirname(__FILE__), 'GUI' ) );
    $self->static->root( $self->home->rel_dir('public') );
    $self->renderer->root( $self->home->rel_dir('templates') );

    $r->route('/')->via('GET')->to(
        cb => sub {
            shift->render(
                'MainWindow',
                dojo_config  => 'isDebug: true,parseOnLoad: true',
                dojo_theme   => 'tundra',
                dojo_version => '1.6',
            );
        }
    );

}

1
__END__

=head1 NAME

PNI::GUI - HTML5 based GUI for Perl Node Interface

=head1 SYNOPSIS

    $ pnigui daemon

=head1 ENVIRONMENT

=head2 MOJO_MODE

=head2 MOJO_SECRET

=head1 SEE ALSO

L<PNI>

=cut

