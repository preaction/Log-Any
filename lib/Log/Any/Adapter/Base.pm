package Log::Any::Adapter::Base;
use strict;
use warnings;
use Log::Any::Adapter::Core 0.16 ();    # In the Log-Any distribution
our @ISA = qw(Log::Any::Adapter::Core);

# This is an empty wrapper around Log::Any::Adapter::Core.  That module
# is part of Log-Any and is not indexed.  Adapters should inherit from
# this module and thereby depend on Log-Any-Adapter

1;

__END__

=pod

=head1 NAME

Log::Any::Adapter::Base - Base class for Log::Any adapters

=head1 DESCRIPTION

This is the base class for Log::Any adapters. See
L<Log::Any::Adapter::Development|Log::Any::Adapter::Development> for
information on developing Log::Any adapters.

