package PNI::GUI;
use Mojo::Base 'Mojolicious';

use File::Basename 'dirname';
use File::Spec;

our $VERSION = '0.02.0';

sub startup {
    my $self = shift;
    my $r    = $self->routes;

    $self->secret( $ENV{PNIGUI_SECRET} );

    $self->home->parse( File::Spec->catdir( dirname(__FILE__), 'GUI' ) );
    $self->static->root( $self->home->rel_dir('public') );
    $self->renderer->root( $self->home->rel_dir('templates') );

    $r->get('/')->to( cb => sub { shift->render('MainWindow'); } );
    $r->get('/root')->to('root#to_json');
    $r->get('/edge/:id')->to('edge#to_json');
    $r->get('/node/:id')->to('node#to_json');
    $r->get('/scenario/:id')->to('scenario#to_json');
    $r->post('/scenario/:id/add_node')->to('scenario#add_node');
    $r->post('/scenario/:id/add_edge')->to('scenario#add_edge');
    $r->post('/scenario/:id/add_comment')->to('scenario#add_comment');

}

1
__END__

=head1 NAME

PNI::GUI - HTML5 based GUI for Perl Node Interface

=head1 SYNOPSIS

    $ pnigui daemon

=head1 ENVIRONMENT

=head2 MOJO_MODE

=head2 PNIGUI_SECRET

=head1 SEE ALSO

L<PNI>

=cut

