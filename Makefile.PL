use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'         => 'GD::XYScale',
    'VERSION_FROM' => 'lib/GD/XYScale.pm',
    'PREREQ_PM'    => { 'GD' => 0 },
    ($] >= 5.005 ? (
    'AUTHOR'       => 'Burak Gursoy <burak@cpan.org>',
    'ABSTRACT'     => 'Draw a 2D X-Y scale and use it',
     ) : ()),
);
