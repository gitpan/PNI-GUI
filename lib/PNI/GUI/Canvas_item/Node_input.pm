package PNI::GUI::Canvas_item::Node_input;

use Mouse;
use PNI::GUI;

our $VERSION = $PNI::GUI::VERSION;

extends 'PNI::GUI::Canvas_item';

has 'node' =>
  ( is => 'ro', required => 1, isa => 'PNI::GUI::Canvas_item::Node' );
has [ 'tk_rectangle_id', 'tk_input_editor_id' ] => =>
  ( is => 'rw', isa => 'Int' );
has [ 'center_x', 'center_y' ] => ( is => 'rw', isa => 'Int', required => 1 );
has 'name' => ( is => 'ro', isa => 'Str', required => 1 );
has 'half_width' => ( is => 'ro', default => 4 );

sub BUILD {
    my $self = shift;

    my $tk_canvas  = $self->pni_gui_canvas->tk_canvas;
    my $name       = $self->name;
    my $node_id    = $self->node->pni_node->id;
    my $center_x   = $self->center_x;
    my $center_y   = $self->center_y;
    my $half_width = $self->half_width;

    my $tk_rectangle_id = $tk_canvas->createRectangle(
        $center_x - $half_width,
        $center_y + $half_width,
        $center_x + $half_width,
        $center_y - $half_width,
        -fill       => 'gray',
        -activefill => 'black'
    );

    $self->tk_rectangle_id($tk_rectangle_id);
    $self->tk_input_editor_id(0);

    $tk_canvas->addtag( $node_id,     'withtag', $tk_rectangle_id );
    $tk_canvas->addtag( 'input',      'withtag', $tk_rectangle_id );
    $tk_canvas->addtag( "name=$name", 'withtag', $tk_rectangle_id );

    $self->_default_bindings;
}

sub _default_bindings {
    my $self            = shift;
    my $tk_canvas       = $self->pni_gui_canvas()->tk_canvas();
    my $tk_rectangle_id = $self->tk_rectangle_id();

    $tk_canvas->bind( $tk_rectangle_id, '<Enter>' => [ \&_show_info, $self ] );

    $tk_canvas->bind( $tk_rectangle_id,
        '<Double-Button-1>' => [ \&_open_input_editor, $self ] );

    $tk_canvas->bind( $tk_rectangle_id, '<Leave>' => undef );
}

sub _show_info {
    my $tk_canvas = shift;
    my $self      = shift;

    my $data = $self->node->pni_node->get_input( $self->name );

    my $text             = $self->name . ' | ' . $data;
    my $tk_info_label_id = $tk_canvas->createText(
        $tk_canvas->XEvent->x,
        $tk_canvas->XEvent->y - 20,
        -text => $text
    );

    $tk_canvas->bind( $self->tk_rectangle_id,
        '<Leave>' => sub { shift->delete($tk_info_label_id) } );

}

sub _open_input_editor {
    my $tk_canvas  = shift;
    my $self       = shift;
    my $half_width = 4;

    $self->_update_center_coords;

    my $frame = $tk_canvas->Frame( -height => 60, -width => 30 );

    my $label = $frame->Label( -text => $self->name, -width => 10 );
    $label->pack( -side => 'left', -fill => 'none' );

    my $entry = $frame->Entry( -width => 10 );
    $entry->insert( 0, $self->node->pni_node->get_input( $self->name ) );
    $entry->pack( -side => 'right' );

    my $tk_input_editor_id = $tk_canvas->createWindow(
        $self->center_x,
        $self->center_y - ( $half_width * 3 ),
        -window => $frame,
        -tags   => [ $self->node->pni_node->id ]
    );

    $self->tk_input_editor_id($tk_input_editor_id);
    $tk_canvas->bind( $tk_input_editor_id,
        '<B1-Motion>' => [ \&_move, $self ] );
    $entry->bind( '<Return>' => [ \&_close_input_editor, $self ] );
}

sub _close_input_editor {

    my $entry     = shift;
    my $self      = shift;
    my $tk_canvas = $self->pni_gui_canvas()->tk_canvas();

    if ( $self->tk_input_editor_id ) {
        $self->node->pni_node->set_input( $self->name => $entry->get );
        $tk_canvas->delete( $self->tk_input_editor_id );
        $self->tk_input_editor_id(0);
    }
}

sub _update_center_coords {
    my $self = shift;

    my @coords =
      $self->pni_gui_canvas->tk_canvas->coords( $self->tk_rectangle_id );

    $self->center_x( ( $coords[0] + $coords[2] ) / 2 );
    $self->center_y( ( $coords[1] + $coords[3] ) / 2 );
## Please see file perltidy.ERR
}

1;

