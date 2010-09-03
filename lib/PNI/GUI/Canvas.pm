package PNI::GUI::Canvas;

use Mouse;
use PNI::GUI::Canvas_item::Node_selector;
use PNI::GUI::Canvas_item::Node;
use PNI::GUI;

our $VERSION = $PNI::GUI::VERSION;

#TODO aggiusta sto tapullo
my $NODE = {};
use Tk;
has 'tk_main_window' => (
    is       => 'ro',
    isa      => 'Tk::MainWindow',
    required => 1
);

has 'tk_canvas' => (
    is      => 'ro',
    isa     => 'Tk::Canvas',
    default => sub {
        my $self      = shift;
        my $tk_canvas = $self->tk_main_window()->Canvas();
        $tk_canvas->configure(
            -confine          => 0,
            -height           => 400,
            -width            => 600,
            -scrollregion     => [ 0, 0, 1000, 1000 ],
            -xscrollincrement => 1,
            -background       => 'white'
        );

        $tk_canvas->pack( -expand => 1, -fill => 'both' );

        return $tk_canvas;
    }
);

has [ 'last_x', 'last_y' ] => ( is => 'rw', isa => 'Int' );
has 'current_id' => ( is => 'rw' );

sub BUILD {
    my $self = shift;
    $self->_default_bindings;
}

sub _default_bindings {
    my $self      = shift;
    my $tk_canvas = $self->tk_canvas();
    $tk_canvas->CanvasBind( '<ButtonPress-1>'   => [ \&_click,        $self ] );
    $tk_canvas->CanvasBind( '<Double-Button-1>' => [ \&_double_click, $self ] );
    $tk_canvas->CanvasBind( '<ButtonRelease-1>' => undef );
    $tk_canvas->CanvasBind( '<B1-Motion>'       => undef );
}

sub _store_last_xy {
    my $self = shift;
    $self->last_x( $self->tk_canvas()->XEvent->x );
    $self->last_y( $self->tk_canvas()->XEvent->y );

    #print $self->last_x, ' ', $self->last_y, "\n";
}

sub _store_current_id {
    my $self = shift;

    # if it is a canvas item, store the current_id
    # otherwise store a zero id
    my @current = $self->tk_canvas->find( 'withtag', 'current' );
    if (@current) {
        #print $tk_canvas->type($_) , " $_\n" for @current;
        $self->current_id( $current[0] );
    }
    else {
        $self->current_id(0);
    }
}

sub _click {

    #print 'got _click ', "\n";
    my $tk_canvas = shift;
    my $self      = shift;
    $self->_store_last_xy();
    $self->_store_current_id();
}

sub _double_click {
    my $tk_canvas = shift;
    my $self      = shift;

    $self->_store_last_xy();
    $self->_store_current_id();

    #print 'got _double_click ', $self->current_id, "\n";
    if ( $self->current_id ) {

        # checking if it was clicked an item, then i do nothing
        # cause i delegate to it the binding callout.
    }
    else {

        # if no canvas item was clicked i open a node selector.
        new PNI::GUI::Canvas_item::Node_selector( pni_gui_canvas => $self );

        $tk_canvas->CanvasBind( '<Double-Button-1>' => undef );
        $tk_canvas->CanvasBind( '<ButtonPress-1>'   => undef );
    }
}

sub create_node {
    my $self        = shift;
    my $node_type   = shift;
    my $pni_node    = PNI::NODE $node_type;
    my $pni_node_id = $pni_node->id();
    new PNI::GUI::Canvas_item::Node(
        pni_gui_canvas => $self,
        pni_node       => $pni_node,
        center_x       => $self->last_x(),
        center_y       => $self->last_y()
    );

    $NODE->{$pni_node_id} = $pni_node;

    $self->_default_bindings;
}

sub create_link {
    my $self         = shift;
    my $tk_output_id = shift;
    my $tk_canvas    = $self->tk_canvas();

    my ( $x1, $y1, $x2, $y2 ) = $tk_canvas->coords($tk_output_id);
    my $output_center_x = ( $x1 + $x2 ) / 2;
    my $output_center_y = ( $y1 + $y2 ) / 2;

    my $link_id = $tk_canvas->createLine(
        $output_center_x, $output_center_y, $output_center_x,
        $output_center_y, -arrow => 'none'
    );

    $tk_canvas->lower( $link_id, $tk_output_id );
    $tk_canvas->CanvasBind(
        '<B1-Motion>' => [
            \&_move_unconnected_link, $tk_output_id,
            $link_id,                 $output_center_x,
            $output_center_y
        ]
    );

    $tk_canvas->CanvasBind(
        '<ButtonRelease-1>' => [
            \&_connect_link, $self,            $tk_output_id,
            $link_id,        $output_center_x, $output_center_y
        ]
    );
}

sub _move_unconnected_link {
    my ( $tk_canvas, $tk_output_id, $link_id, $output_center_x,
        $output_center_y )
      = @_;

    $tk_canvas->coords( $link_id, $output_center_x, $output_center_y,
        $tk_canvas->XEvent->x, $tk_canvas->XEvent->y );

}

sub _connect_link {
    my ( $tk_canvas, $self, $tk_output_id, $link_id, $output_center_x,
        $output_center_y )
      = @_;

    my $tk_input_id = (
        $tk_canvas->find(
            'closest', $tk_canvas->XEvent->x, $tk_canvas->XEvent->y
        )
    )[0];

    my @input_tags = $tk_canvas->gettags($tk_input_id);

    my $is_not_connected = not grep( /^connected$/, @input_tags );
    my $is_an_input = grep( /^input$/, @input_tags );

    if ( $is_an_input and $is_not_connected ) {

        my ( $x1, $y1, $x2, $y2 ) = $tk_canvas->coords($tk_input_id);
        my $input_center_x = ( $x1 + $x2 ) / 2;
        my $input_center_y = ( $y1 + $y2 ) / 2;
        $tk_canvas->coords(
            $link_id,        $output_center_x, $output_center_y,
            $input_center_x, $input_center_y
        );

        my $target_node_id = ( grep /Node.*/, @input_tags )[0];
        my $target_node    = $NODE->{$target_node_id};
        my $input_name     = ( grep /name=.*/, @input_tags )[0];
        $input_name =~ s/^name=(.*)/$1/;

        my @output_tags = $tk_canvas->gettags($tk_output_id);

        my $source_node_id = ( grep /Node.*/, @output_tags )[0];
        my $source_node    = $NODE->{$source_node_id};
        my $output_name    = ( grep /name=.*/, @output_tags )[0];
        $output_name =~ s/^name=(.*)/$1/;

        $tk_canvas->addtag( "source_node_$source_node_id", 'withtag',
            $link_id );
        $tk_canvas->addtag( "target_node_$target_node_id", 'withtag',
            $link_id );
        $tk_canvas->addtag( 'connected', 'withtag', $tk_input_id );

        PNI::LINK $source_node => $target_node, $output_name => $input_name;
    }
    else {

        # if mouse is not released inside an input node
        # just destroy the newbie link .
        $tk_canvas->delete($link_id);
    }

    $self->_default_bindings;
}

1;
