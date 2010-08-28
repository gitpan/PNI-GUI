use 5.8.8;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => 'PNI::GUI',
    VERSION_FROM      => 'lib/PNI/GUI.pm',
    EXE_FILES => [ 'pnigui.pl' ],
    PREREQ_PM         => {
        Mouse => 0,
        PNI => 0.05,
        Tk => 0
    },
    ($] >= 5.005 ?
      (ABSTRACT_FROM  => 'lib/PNI/GUI.pm',
       AUTHOR         => 'G. Casati <fibo@cpan.org>') : ()),
);
