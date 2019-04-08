package Data::Lookup;
use strict;
use warnings;
use Exporter 'import';

our @EXPORT = qw();
our @EXPORT_OK = qw(Reach);
our $VERSION = '0.1';

sub Reach {
    (!@ || ref $_[0] ne 'ARRAY' && ref $_[0] ne 'HASH') && die 'need hash or array ref as first argument';
    my $ptr = shift;
    while(@_) {
        if(!defined $ptr) {return wantarray ? (0,undef) : 0}

        my $key = shift;
        if($key =~ /^[0-9]+$/) {
            if(ref $ptr ne 'ARRAY' || !exists $ptr->[$key]) {return wantarray ? (0,undef) : 0}
            $ptr = $ptr->[$key];
        }
        elsif(substr($key,0,1) eq '%' && substr($key,1) =~ /^\d+$/) {
            $key = substr($key,1);
            if(ref $ptr ne 'HASH' || !exists $ptr->{$key}) {return wantarray ? (0,undef) : 0}
            $ptr = $ptr->{$key};
        }
        else {
            if(ref $ptr ne 'HASH' || !exists $ptr->{$key}) {return wantarray ? (0,undef) : 0}
            $ptr = $ptr->{$key};
        }
    }
    return wantarray ? (1,$ptr) : 1;
}

1;

__END__

=head1 NAME

Data::Lookup - neatly lookup complex data structures without any autovivification.

=head1 SYNOPSIS

    use Data::Lookup 'Reach';

    $dump = {
        raw => {
            strings => ['foo', 'bar'],
            count => 2
        }
        repr => 'foo bar',
        101 => 'magical greatness'
    };

    if(Reach($dump,qw[raw count])) {
        print "got the count: $count\n";
    }

    ($is_found_repr, $repr) = Reach($dump, 'repr');
    if($is_found_repr) {
        print "got the representation: '$repr'\n";
    }

    ($is_found_first_string, $first_string) = Reach($dump, qw[raw strings 0]);
    if($is_found_first_string) {
        print "got the first string: '$first_string'\n";
    }

    ($is_found_magic, $magic) = Reach($dump, '%101');
    if($is_found_magic) {
        print "got the magic: '$magic'\n";
    }

=head1 DESCRIPTION

Each time when one lookups an absent key in hash or array, Perl implicitly
creates it, causing the original hash or array to change. This is called
Autovivification.

Autovivification allows to lookup nested hashes or arrays without breaking the
program flow. If one doesn't care about further representation of the
underlying data structure, he or she could simply lookup by the full path to
get the desired value. If the representation is important, one should care
about checking each key for existence, which could produce long and multiline
code for deeply nested data structures.

The present module allows to lookup into whichever deep data structures
without autovivification in one line.

=head1 METHODS

=over 4

=item Reach(DSREF, [PATH...])

In scalar context returns availability (0 if not available or 1 otherwise) of
key by PATH in hash ref or array ref DSREF.

In list context returns the availability and the value.

Hashes are able to have numerical keys, but numbers in PATH could lead to
ambiguity: lookup in hash or array? To bypass this one could type percent
sign (%) before numerical path piece, which will force to lookup in hash.
Otherwise, numerical path pieces will lead to lookup in array. 

=back

=head1 AUTHOR

Arshak Martirosyan      mat90X@mail.ru

Copyright (c) 2019 Arshak Martirosyan. All rights reserved. This program is
free software; you can redistribute it and/or modify it under the same terms as
Perl itself.

=head1 VERSION

Version 0.1 (March 24 2019)

=cut
