package PNI::GUI::Scenario;
use Mojo::Base 'Mojolicious::Controller';

sub add_edge { }
sub add_node { }
sub del_edge { }
sub del_node { }

sub to_json {
    my $self = shift;

    my $id = $self->stash('id') || 0;
    $self->render_json( { id => $id } );
}

1
__END__
