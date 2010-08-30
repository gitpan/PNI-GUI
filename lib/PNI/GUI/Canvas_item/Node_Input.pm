package PNI::GUI::Canvas_item::Node_Input;

use Mouse;
use PNI::GUI;

our $VERSION = $PNI::GUI::VERSION;

extends 'PNI::GUI::Canvas_item';

has 'node' =>
  ( is => 'ro', required => 1, isa => 'PNI::GUI::Canvas_item::Node' );
has 'tk_rectangle_id' => => ( is => 'rw', isa => 'Int' );
has [ 'center_x', 'center_y' ] => ( is => 'rw', isa => 'Int', required => 1 );

sub BUILD {
    my $tk_canvas     = $self->pni_gui_canvas()->tk_canvas();
    my $node_id       = $self->node->pni_node->id();
    my $x             = $self->center_x();
    my $y             = $self->center_y();
    my $io_half_width = 4;

    my $tk_rectangle_id = $tk_canvas->createRectangle(
        $center_x - $io_half_width,
        $center_y + $io_half_width,
        $center_x + $io_half_width,
        $center_y - $io_half_width,
        -fill       => 'gray',
        -activefill => 'black'
    );

    $self->tk_rectangle_id($tk_rectangle_id);
}

1;

