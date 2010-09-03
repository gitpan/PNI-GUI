package PNI::GUI::Canvas_item::Node;

use Mouse;
use PNI::GUI;
use PNI::GUI::Canvas_item::Node_input;
use PNI::GUI::Canvas_item::Node_output;

our $VERSION = $PNI::GUI::VERSION;

extends('PNI::GUI::Canvas_item');

#has [ 'width', 'height' ] => ( is => 'rw', isa => 'Int' );
has 'pni_node' => ( is => 'ro', isa => 'PNI::Node', required => 1 );
has [ 'center_x', 'center_y' ] => ( is => 'rw', isa => 'Int', required => 1 );
has [
    qw(
      tk_border_id
      tk_label_id
      tk_inspector_id
      )
] => ( is => 'rw', isa => 'Int' );

sub BUILD {
    my $self = shift;

    my $tk_canvas     = $self->pni_gui_canvas()->tk_canvas();
    my $node          = $self->pni_node();
    my $x             = $self->center_x();
    my $y             = $self->center_y();
    my $io_half_width = 4;
    my $width         = 6 * length($node->type);
    my $height        = 20;

    #$self->width($width);
    #$self->height($height);

    my $tk_border_id = $tk_canvas->createRectangle(
        $x - $width / 2,
        $y + $height / 2,
        $x + $width / 2,
        $y - $height / 2
    );
    $tk_canvas->addtag( $node->id, 'withtag', $tk_border_id );
    $self->tk_border_id($tk_border_id);

    my $tk_label_id = $tk_canvas->createText(
        $x, $y,
        -text       => $node->type
    );
    $tk_canvas->addtag( $node->id, 'withtag', $tk_label_id );
    $self->tk_label_id($tk_label_id);

    my @input  = sort $node->input_names;
    my @output = sort $node->output_names;

    for ( my $i = 0 ; $i <= $#input ; $i++ ) {
        my $num_input_minus_one = $#input || 1;
        my $center_x = $x - $width / 2 + $i * $width / $num_input_minus_one;
        my $center_y = $y - $height / 2;

        my $node_input = PNI::GUI::Canvas_item::Node_input->new(
            pni_gui_canvas => $self->pni_gui_canvas,
            center_x       => $center_x,
            center_y       => $center_y,
            node           => $self,
            name           => $input[$i]
        );
    }

    for ( my $i = 0 ; $i <= $#output ; $i++ ) {
        my $num_output_minus_one = $#output || 1;
        my $center_x = $x - $width / 2 + $i * $width / $num_output_minus_one;
        my $center_y = $y + $height / 2;

        my $node_output = PNI::GUI::Canvas_item::Node_output->new(
            pni_gui_canvas => $self->pni_gui_canvas,
            center_x       => $center_x,
            center_y       => $center_y,
            node           => $self,
            name           => $output[$i]
        );

    }

    $self->_default_bindings;
}

sub _default_bindings {
    my $self         = shift;
    my $tk_canvas    = $self->pni_gui_canvas()->tk_canvas();
    my $tk_border_id = $self->tk_border_id();
    my $tk_label_id  = $self->tk_label_id();

    $tk_canvas->bind( $tk_border_id, '<B1-Motion>' => [ \&_move, $self ] );
    $tk_canvas->bind( $tk_label_id,  '<B1-Motion>' => [ \&_move, $self ] );

}

sub _move {
    my $tk_canvas = shift;
    my $self      = shift;
    my $node   = $self->pni_node;
    my ( $x1, $y1, $x2, $y2 ) = $tk_canvas->coords($node->id);

    my $last_x = $self->pni_gui_canvas->last_x();
    my $last_y = $self->pni_gui_canvas->last_y();

    my $dx = $tk_canvas->XEvent->x - $last_x;
    my $dy = $tk_canvas->XEvent->y - $last_y;

    return if $x1 + $dx < 1;
    return if $y1 + $dy < 1;

    $tk_canvas->move( $_, $dx, $dy )
      for ( $tk_canvas->find( 'withtag', $node->id ) );

    for ( $tk_canvas->find( 'withtag', 'source_node_' . $node->id ) ) {
        my ( $x1, $y1, $x2, $y2 ) = $tk_canvas->coords($_);
        $tk_canvas->coords( $_, $x1 + $dx, $y1 + $dy, $x2, $y2 );
    }
    for ( $tk_canvas->find( 'withtag', 'target_node_' . $node->id ) ) {
        my ( $x1, $y1, $x2, $y2 ) = $tk_canvas->coords($_);
        $tk_canvas->coords( $_, $x1, $y1, $x2 + $dx, $y2 + $dy );
    }

    $self->pni_gui_canvas->last_x( $tk_canvas->XEvent->x );
    $self->pni_gui_canvas->last_y( $tk_canvas->XEvent->y );
}

1;
__END__

