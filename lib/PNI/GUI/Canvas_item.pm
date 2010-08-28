package PNI::GUI::Canvas_item;

use Mouse;
use PNI::GUI;

our $VERSION = $PNI::GUI::VERSION;

has 'pni_gui_canvas' => (
    is       => 'ro',
    isa      => 'PNI::GUI::Canvas',
    required => 1
);

1;
