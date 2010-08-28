package PNI::GUI::Canvas_item::Node;

use Mouse;
use PNI::GUI;

our $VERSION = $PNI::GUI::VERSION;

extends('PNI::GUI::Canvas_item');

has 'pni_node' => ( is => 'ro', isa => 'PNI::Node', required => 1 );
has [ 'width', 'height' ] => ( is => 'rw', isa => 'Int' );
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
    my $node_type     = $node->type();
    my $node_id       = $node->id();
    my $x             = $self->center_x();
    my $y             = $self->center_y();
    my $io_half_width = 4;
    my $width         = 6 * length($node_type);
    my $height        = 20;

    $self->width($width);
    $self->height($height);

    my $tk_border_id = $tk_canvas->createRectangle(
        $x - $self->width() / 2,
        $y + $self->height() / 2,
        $x + $self->width() / 2,
        $y - $self->height() / 2
    );
    $tk_canvas->addtag( $node_id, 'withtag', $tk_border_id );
    $self->tk_border_id($tk_border_id);

    my $tk_label_id = $tk_canvas->createText(
        $x, $y,
        -text       => $node_type,
        -activefill => 'gray'
    );
    $tk_canvas->addtag( $node_id, 'withtag', $tk_label_id );
    $self->tk_label_id($tk_label_id);

    my @input  = $node->input_names;
    my @output = $node->output_names;

    for ( my $i = 0 ; $i <= $#input ; $i++ ) {
        my $num_input_minus_one = $#input || 1;
        my $center_x    = $x - $width / 2 + $i * $width / $num_input_minus_one;
        my $center_y    = $y - $height / 2;
        my $tk_input_id = $tk_canvas->createRectangle(
            $center_x - $io_half_width,
            $center_y + $io_half_width,
            $center_x + $io_half_width,
            $center_y - $io_half_width,
            -fill       => 'gray',
            -activefill => 'black'
        );

        $tk_canvas->addtag( $node_id, 'withtag', $tk_input_id );
        $tk_canvas->addtag( 'input',  'withtag', $tk_input_id );

        #$tk_canvas->addtag( "node_id=$$node" , 'withtag' , $tk_input_id );
        $tk_canvas->addtag( "name=$input[$i]", 'withtag', $tk_input_id );

    }

    for ( my $i = 0 ; $i <= $#output ; $i++ ) {
        my $num_output_minus_one = $#output || 1;
        my $center_x = $x - $width / 2 + $i * $width / $num_output_minus_one;
        my $center_y = $y + $height / 2;
        my $tk_output_id = $tk_canvas->createRectangle(
            $center_x - $io_half_width,
            $center_y + $io_half_width,
            $center_x + $io_half_width,
            $center_y - $io_half_width,
            -fill       => 'gray',
            -activefill => 'black'
        );

        $tk_canvas->addtag( $node_id, 'withtag', $tk_output_id );
        $tk_canvas->addtag( 'output', 'withtag', $tk_output_id );

        #$tk_canvas->addtag( "node_id=$$node" , 'withtag' , $tk_output_id );
        $tk_canvas->addtag( "name=$output[$i]", 'withtag', $tk_output_id );

    }

    $self->_default_bindings;
}

sub _default_bindings {
    my $self         = shift;
    my $node         = $self->pni_node();
    my $node_id      = $node->id();
    my $tk_canvas    = $self->pni_gui_canvas()->tk_canvas();
    my $tk_border_id = $self->tk_border_id();
    my $tk_label_id  = $self->tk_label_id();

    $tk_canvas->bind( $tk_border_id, '<B1-Motion>' => [ \&_move, $self ] );
    $tk_canvas->bind( $tk_label_id,  '<B1-Motion>' => [ \&_move, $self ] );

    for my $tk_input_id ( $tk_canvas->find( 'withtag', "$node_id&&input" ) ) {
        
        $tk_canvas->bind( $tk_input_id,
            '<Enter>' => [ \&_show_input_info, $self, $tk_input_id ] );
       
        # TODO crea la classe Node_input !!!
        #$tk_canvas->bind( $tk_input_id,
        #'<Double-Button-1>' => [ \&_open_inspector, $self ] );
    }

    for my $tk_output_id ( $tk_canvas->find( 'withtag', "$node_id&&output" ) ) {
        $tk_canvas->bind( $tk_output_id,
            '<Enter>' => [ \&_show_output_info, $self, $tk_output_id ] );

        $tk_canvas->bind( $tk_output_id,
            '<ButtonPress-1>' => [ \&_create_link, $self, $tk_output_id ] );
    }
}

sub _open_inspector {
    my $tk_canvas = shift;
    my $self      = shift;
    print "yeah!\n";

    my $frame = $tk_canvas->Frame( -height => 60, -width => 30 );
    my $label = $frame->Label( -text => 'Ok' );
    $label->pack();

    my $tk_inspector_id = $tk_canvas->createWindow(
        $self->center_x,
        $self->center_y,
        -window => $frame,
        -tags   => [ $self->pni_node->id ]
    );

    $self->tk_inspector_id($tk_inspector_id);
    $tk_canvas->bind( $tk_inspector_id, '<B1-Motion>' => [ \&_move, $self ] );
}

sub _show_input_info {

    #print 'input info ',  @_
}

sub _show_output_info {

    #print 'output info ', @_
}

sub _move {
    my $tk_canvas = shift;
    my $self      = shift;
    my $node_id   = $self->pni_node->id();
    my ( $x1, $y1, $x2, $y2 ) = $tk_canvas->coords($node_id);

    my $last_x = $self->pni_gui_canvas->last_x();
    my $last_y = $self->pni_gui_canvas->last_y();

    my $dx = $tk_canvas->XEvent->x - $last_x;
    my $dy = $tk_canvas->XEvent->y - $last_y;

    return if $x1 + $dx < 1;
    return if $y1 + $dy < 1;

    $tk_canvas->move( $_, $dx, $dy )
      for ( $tk_canvas->find( 'withtag', $node_id ) );

    for ( $tk_canvas->find( 'withtag', "source_node_$node_id" ) ) {
        my ( $x1, $y1, $x2, $y2 ) = $tk_canvas->coords($_);
        $tk_canvas->coords( $_, $x1 + $dx, $y1 + $dy, $x2, $y2 );
    }
    for ( $tk_canvas->find( 'withtag', "target_node_$node_id" ) ) {
        my ( $x1, $y1, $x2, $y2 ) = $tk_canvas->coords($_);
        $tk_canvas->coords( $_, $x1, $y1, $x2 + $dx, $y2 + $dy );
    }

    $self->pni_gui_canvas->last_x( $tk_canvas->XEvent->x );
    $self->pni_gui_canvas->last_y( $tk_canvas->XEvent->y );
}

sub _create_link {
    shift;    # skip canvas
    my $self         = shift;
    my $tk_output_id = shift;
    $self->pni_gui_canvas()->create_link($tk_output_id);
}

1;
__END__

