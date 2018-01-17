use 5.008001;
use strict;
use warnings;

package Log::Any::Adapter::Null;

# ABSTRACT: Discards all log messages
our $VERSION = '1.706';

use Log::Any::Adapter::Base;
our @ISA = qw/Log::Any::Adapter::Base/;

use Log::Any::Adapter::Util ();

# All methods are no-ops and return false

foreach my $method (Log::Any::Adapter::Util::logging_and_detection_methods()) {
    no strict 'refs';
    *{$method} = sub { return '' }; # false
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
