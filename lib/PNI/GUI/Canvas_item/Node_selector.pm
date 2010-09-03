package PNI::GUI::Canvas_item::Node_selector;

use Mouse;
use Tk::Tree;
use PNI::GUI;

our $VERSION = $PNI::GUI::VERSION;

extends 'PNI::GUI::Canvas_item';

has 'tk_canvas_id' => ( is => 'rw', isa => 'Int' );

has 'tk_tree' => (
    is      => 'rw',
    isa     => 'Tk::Tree',
    lazy    => 1,
    default => sub {
        my $self    = shift;
        my $tk_tree = $self->pni_gui_canvas->tk_canvas->Tree(
            -height => 10,
            -width  => 40
        );
        return $tk_tree;
    }
);

sub BUILD {
    my $self = shift;

    my $node_collection = PNI::NODECOLLECTION;
    for my $node_category ( keys %{$node_collection} ) {

        $self->tk_tree()->add(
            $node_category,
            -text  => $node_category,
            -state => 'disabled'
        );

        for my $node_type ( @{ $node_collection->{$node_category} } ) {
            $self->tk_tree()->add(
                "$node_category.$node_type",
                -text  => $node_type,
                -state => 'normal'
            );
        }
    }

    my $tk_canvas_id = $self->pni_gui_canvas->tk_canvas->createWindow(
        $self->pni_gui_canvas()->last_x(),
        $self->pni_gui_canvas()->last_y(),
        -window => $self->tk_tree()
    );

    $self->tk_canvas_id($tk_canvas_id);

    $self->tk_tree()->configure( -command => [ \&_create_node, $self ] );
}

sub _create_node {
    my $self      = shift;
    my $node_path = shift;
    $node_path =~ s/\./::/g;
    $self->pni_gui_canvas()->create_node($node_path);
    $self->tk_tree()->destroy();
    $self->pni_gui_canvas->tk_canvas->delete( $self->tk_canvas_id );
}

1;
