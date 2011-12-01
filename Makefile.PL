use strict;
use ExtUtils::MakeMaker;

WriteMakefile
  AUTHOR    => 'G. Casati <fibo@cpan.org>',
  EXE_FILES => ['script/pnigui'],
  NAME      => 'PNI-GUI',
  PREREQ_PM => {
    'File::Basename' => 0,
    'File::Spec'     => 0,
    'Mojolicious'    => '2.0',
  },
  VERSION_FROM => 'lib/PNI/GUI.pm',

