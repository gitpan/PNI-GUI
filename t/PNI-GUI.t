use strict;
use Test::More tests => 8;

BEGIN { 
    use_ok('PNI::GUI');
    use_ok('PNI::GUI::Canvas');
    use_ok('PNI::GUI::Canvas_item');
    use_ok('PNI::GUI::Canvas_item::Node');
    use_ok('PNI::GUI::Canvas_item::Node_input');
    use_ok('PNI::GUI::Canvas_item::Node_output');
    use_ok('PNI::GUI::Canvas_item::Node_selector');
    use_ok('PNI::GUI::Window');
}
