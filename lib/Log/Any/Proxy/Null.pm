use 5.008001;
use strict;
use warnings;

package Log::Any::Proxy::Null;

# ABSTRACT: Log::Any generator proxy for no adapters
our $VERSION = '1.706';

use Log::Any::Adapter::Util ();
use Log::Any::Proxy;
our @ISA = qw/Log::Any::Proxy/;

# Null proxy objects waiting for inflation into regular proxy objects
my @nulls;

sub new {
    my $obj = shift->SUPER::new( @_ );
    push @nulls, $obj;
    return $obj;
}

sub inflate_nulls {
    bless shift( @nulls ), 'Log::Any::Proxy' while @nulls;
}

my %aliases = Log::Any::Adapter::Util::log_level_aliases();

# Set up methods/aliases and detection methods/aliases
foreach my $name ( Log::Any::Adapter::Util::logging_methods(), keys(%aliases) )
{
    my $namef       = $name . "f";
    my $super_name  = "SUPER::" . $name;
    my $super_namef = "SUPER::" . $namef;
    no strict 'refs';
    *{$name} = sub {
        return unless defined wantarray;
        return shift->$super_name( @_ );
    };
    *{$namef} = sub {
        return unless defined wantarray;
        return shift->$super_namef( @_ );
    };
}

1;
