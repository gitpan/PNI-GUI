package PNI::GUI::Canvas_item::Node_output;

use Mouse;
use PNI::GUI;

our $VERSION = $PNI::GUI::VERSION;

extends 'PNI::GUI::Canvas_item';

has 'node' =>
  ( is => 'ro', required => 1, isa => 'PNI::GUI::Canvas_item::Node' );
has 'tk_rectangle_id' => => ( is => 'rw', isa => 'Int' );
has [ 'center_x', 'center_y' ] => ( is => 'rw', isa => 'Int', required => 1 );
has 'name' => ( is => 'ro', isa => 'Str', required => 1 );

sub BUILD {
    my $self = shift;

    my $tk_canvas  = $self->pni_gui_canvas()->tk_canvas();
    my $name       = $self->name;
    my $node_id    = $self->node->pni_node->id();
    my $center_x   = $self->center_x();
    my $center_y   = $self->center_y();
    my $half_width = 4;

    my $tk_rectangle_id = $tk_canvas->createRectangle(
        $center_x - $half_width,
        $center_y + $half_width,
        $center_x + $half_width,
        $center_y - $half_width,
        -fill       => 'gray',
        -activefill => 'black'
    );

    $self->tk_rectangle_id($tk_rectangle_id);

    $tk_canvas->addtag( $node_id,     'withtag', $tk_rectangle_id );
    $tk_canvas->addtag( 'output',     'withtag', $tk_rectangle_id );
    $tk_canvas->addtag( "name=$name", 'withtag', $tk_rectangle_id );

    $self->_default_bindings;
}

sub _default_bindings {
    my $self            = shift;
    my $tk_canvas       = $self->pni_gui_canvas()->tk_canvas();
    my $tk_rectangle_id = $self->tk_rectangle_id();

    $tk_canvas->bind( $tk_rectangle_id, '<Enter>' => [ \&_show_info, $self ] );

    $tk_canvas->bind( $tk_rectangle_id,
        '<ButtonPress-1>' => [ \&_create_link, $self ] );

}

sub _show_info {
    my $tk_canvas = shift;
    my $self      = shift;

    my $data = $self->node->pni_node->get_output( $self->name );

    my $text             = $self->name . ' | ' . $data;
    my $tk_info_label_id = $tk_canvas->createText(
        $tk_canvas->XEvent->x,
        $tk_canvas->XEvent->y + 20,
        -text => $text
    );

    $tk_canvas->bind( $self->tk_rectangle_id,
        '<Leave>' => sub { shift->delete($tk_info_label_id) } );

}

sub _create_link {
    shift;    # skip canvas
    my $self = shift;
    $self->pni_gui_canvas()->create_link( $self->tk_rectangle_id );
}

1;
__END__

