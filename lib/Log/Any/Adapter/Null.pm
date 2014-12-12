use 5.008001;
use strict;
use warnings;

package Log::Any::Adapter::Null;

# ABSTRACT: Discards all log messages
our $VERSION = "0.90";

use base qw/Log::Any::Adapter::Base/;

# Collect all logging and detection methods, including aliases and printf variants
#
my %aliases     = Log::Any->log_level_aliases;
my @alias_names = keys(%aliases);
my @all_methods = (
    Log::Any->logging_and_detection_methods(),
    @alias_names,
    ( map { "is_$_" } @alias_names ),
    ( map { $_ . "f" } ( Log::Any->logging_methods, @alias_names ) ),
);

# All methods are no-ops and return false
#
foreach my $method (@all_methods) {
    no strict 'refs';
    *{$method} = sub { return undef }; ## no critic: intentional explict undef ?!
}

1;

__END__

=pod

=head1 SYNOPSIS

    Log::Any::Adapter->set('Null');

=head1 DESCRIPTION

This Log::Any adapter discards all log messages and returns false for all
detection methods (e.g. is_debug). This is the default adapter when Log::Any is
loaded.

=head1 SEE ALSO

L<Log::Any|Log::Any>, L<Log::Any::Adapter|Log::Any::Adapter>

=cut
