#!/usr/bin/perl -w
use strict;

use lib qw(./lib);
use Test::More tests => 14;

use CPAN::Testers::WWW::Reports::Query::Reports;
use Data::Dumper;

# various argument sets for examples

my @args = (
    { 
        date    => '2005-02-08',
        results => { from => 182971, to => 183076, range => '182971-183076' }
    },
    { 
        date    => '',
        results => undef
    },
    { 
        range   => '7211',
        count   => 1,
        results => { '7211' => {
                        'version'   => '1.25',
                        'dist'      => 'GD',
                        'osvers'    => '2.7',
                        'state'     => 'pass',
                        'perl'      => '5.5.3',
                        'fulldate'  => '200002231727',
                        'osname'    => 'solaris',
                        'postdate'  => '200002',
                        'platform'  => 'sun4-solaris',
                        'guid'      => '00007211-b19f-3f77-b713-d32bba55d77f',
                        'id'        => '7211',
                        'type'      => '2',
                        'tester'    => 'schinder@pobox.com'
                   } }
    },
    { 
        range   => '7211-',
        start   => 7211,
        count   => 2500,
        results => { '7211' => {
                        'version'   => '1.25',
                        'dist'      => 'GD',
                        'osvers'    => '2.7',
                        'state'     => 'pass',
                        'perl'      => '5.5.3',
                        'fulldate'  => '200002231727',
                        'osname'    => 'solaris',
                        'postdate'  => '200002',
                        'platform'  => 'sun4-solaris',
                        'guid'      => '00007211-b19f-3f77-b713-d32bba55d77f',
                        'id'        => '7211',
                        'type'      => '2',
                        'tester'    => 'schinder@pobox.com'
                   } }
    },
    { 
        range   => '-7211',
        stop    => 7211,
        count   => 2500,
        results => { '7211' => {
                        'version'   => '1.25',
                        'dist'      => 'GD',
                        'osvers'    => '2.7',
                        'state'     => 'pass',
                        'perl'      => '5.5.3',
                        'fulldate'  => '200002231727',
                        'osname'    => 'solaris',
                        'postdate'  => '200002',
                        'platform'  => 'sun4-solaris',
                        'guid'      => '00007211-b19f-3f77-b713-d32bba55d77f',
                        'id'        => '7211',
                        'type'      => '2',
                        'tester'    => 'schinder@pobox.com'
                   } }
    },
    { 
        range   => '-',
        count   => 2500
    }
);

my $query = CPAN::Testers::WWW::Reports::Query::Reports->new();
isa_ok($query,'CPAN::Testers::WWW::Reports::Query::Reports');

SKIP: {
    skip "Network unavailable", 13 if(pingtest());

    for my $args (@args) {
        if(defined $args->{date}) {
            my $data = $query->date( $args->{date} );
            if($data && $args->{results}) {
                is($data->{$_},$args->{results}{$_},".. got '$_' in date hash [$args->{date}]") for(keys %{$args->{results}});
            } elsif($args->{results}) {
                my $skip = $args->{results} ? scalar(keys %{$args->{results}}) : 0;
                SKIP: {
                    skip "No response from request, site may be down", $skip;

                    #diag($query->error());
                    if($args->{results}) { ok(1)   for(keys %{$args->{results}}) }
                }
            } else {
                is($data, undef,".. got no results, as expected [$args->{date}]");
            }
        } elsif(defined $args->{range}) {
            my $data = $query->range( $args->{range} );
            if($data) {
                if($args->{results}) {
                    #diag(Dumper( $data ));
                    is_deeply($data->{$_},$args->{results}{$_},".. got '$_' in range hash [$args->{range}]") 
                        for(keys %{$args->{results}});
                }
                my @keys = sort { $a <=> $b } keys %$data;
                if($args->{start}) {
                    is($keys[0], $args->{start},".. got start value [$args->{range}]");
                }
                if($args->{stop}) {
                    is($keys[-1], $args->{stop},".. got stop value [$args->{range}]");
                }
                if($args->{count}) {
                    cmp_ok(scalar @keys, '<=', $args->{count},".. counted number of records [$args->{range}]");
                }
            } else {
                my $skip = $args->{results} ? scalar(keys %{$args->{results}}) : 0;
                for(qw(start stop count)) {
                    $skip++ if($args->{$_});
                }

                SKIP: {
                    skip "No response from request, site may be down", $skip;

                    #diag($query->error());
                    if($args->{results}) { ok(1)   for(keys %{$args->{results}}) }
                    ok(1)   if($args->{start});
                    ok(1)   if($args->{stop});
                    ok(1)   if($args->{count});
                }
            }
        } else {
            ok(0,'missing date or range test');
        }
    }
}

# crude, but it'll hopefully do ;)
sub pingtest {
    my $domain = 'www.cpantesters.org';
    my $cmd =   $^O =~ /solaris/i                           ? "ping -s $domain 56 1" :
                $^O =~ /dos|os2|mswin32|netware|cygwin/i    ? "ping -n 1 $domain "
                                                            : "ping -c 1 $domain >/dev/null 2>&1";

    system($cmd);
    my $retcode = $? >> 8;
    # ping returns 1 if unable to connect
    return $retcode;
}
