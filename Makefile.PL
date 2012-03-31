use 5.006; #due to 'warnings' pragma
use ExtUtils::MakeMaker;

WriteMakefile(
    'NAME'          => 'CPAN::Testers::WWW::Reports::Query::Reports',
    'VERSION_FROM'  => 'lib/CPAN/Testers/WWW/Reports/Query/Reports.pm',
    'PREREQ_PM'     => {
        WWW::Mechanize      => 0,
    },

    'NO_META'       => 1,

    'ABSTRACT'      => 'Retrieve CPAN Testers metadata direct from the CPAN Testers website.',
    'AUTHOR'        => 'Barbie <barbie@cpan.org>'
);
