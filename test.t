#!/usr/bin/perl -w
use strict;
use warnings;
use lib qw(.);
use Storable 'dclone';
use Test::More;
use Data::Lookup 'Reach';

my $ret = {
    code => 1,
    response => {
        status => 3,
        codes => [4, 7, 8],
        desc => 'request done well',
    },
    error => undef,
    warning => 'extra options were set',
    2 => {level => 1},
    3 => [4, 7, 2],
    '%%4' => 10,
};

my $clone = dclone $ret;

for my $test (
    {path => [qw(code)], val => 1},
    {path => [qw(response)], val => {status => 3, codes => [4, 7, 8], desc => 'request done well'}},
    {path => [qw(response status)], val => 3},
    {path => [qw(response codes)], val => [4, 7, 8]},
    {path => [qw(warning)], val => 'extra options were set'},
    {path => [qw(%2)], val => {level => 1}},
    {path => [qw(%2 level)], val => 1},
    {path => [qw(%3)], val => [4, 7, 2]},
    {path => [qw(%3 1)], val => 7, name => "1th element of '%3'"},
    {path => [qw(%%4)], val => 10},
    {path => [qw(query)], val => 'selet * from tbl', name => 'absent key', absent => 1},
    {path => [qw(data row 5)], val => 'foo\tbar', name => 'nested absent key', absent => 1},
    )   
{
    my $test_name = sprintf "reach '%s'", $test->{name} // $test->{path}[-1];
    my ($isfnd,$val) = Reach($ret,@{$test->{path}});
    if($test->{absent}) {
        ok(!$isfnd && !defined $val, $test_name);
    }
    elsif(ref $test->{val} eq 'HASH' || ref $test->{val} eq 'ARRAY') {
        is_deeply($isfnd && $val || {}, $test->{val}, $test_name);
    }
    elsif($test->{val} =~ /^\d+$/) {
        ok($isfnd && $val == $test->{val}, $test_name);
    }
    else {
        ok($isfnd && $val eq $test->{val}, $test_name);
    }
}

my ($isfnd,$val) = Reach($ret,'error');
ok($isfnd && !defined $val, "reach 'error'");

is_deeply($ret, $clone, 'no new keys');

done_testing();
