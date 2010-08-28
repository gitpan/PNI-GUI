package PNI::GUI::Window;

use Mouse;
use PNI::GUI::Canvas;
use PNI::GUI;

our $VERSION = $PNI::GUI::VERSION;

has 'tk_main_window' => (
    is      => 'ro',
    isa     => 'Tk::MainWindow',
    default => sub {
        my $tk_main_window = new MainWindow( title => 'PNI' );
        $tk_main_window->protocol( 'WM_DELETE_WINDOW', \&Tk::exit );
        return $tk_main_window;
    }
);

has 'pni_gui_canvas' => (
    is      => 'ro',
    isa     => 'PNI::GUI::Canvas',
    default => sub {
        my $self = shift;
        return new PNI::GUI::Canvas(
            tk_main_window => $self->tk_main_window() );
    }
);

sub BUILD {
    my $self = shift;
    $self->tk_main_window()->bind( '<Key>' => \&_print_keysym );
}

sub _print_keysym {
    my ($widget) = @_;

    # get reference to X11 event structure
    my $e = $widget->XEvent;
    my ( $keysym_text, $keysym_decimal ) = ( $e->K, $e->N );
    my ( $X, $Y, $x, $y ) = ( $e->X, $e->Y, $e->x, $e->y );
    print "Character = $keysym_decimal, keysym = $keysym_text"
      . " at abs=($X,$Y), rel=($x,$y).\n";

      if( $keysym_text eq 'i' ){
      print "\n\n\ngot i\n\n\n";
      }
}    # end _print_keysym

1;
