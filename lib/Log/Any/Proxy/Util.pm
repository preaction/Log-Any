use 5.008001;
use strict;
use warnings;

package Log::Any::Proxy::Util;

# ABSTRACT: Common utility functions for Log::Any::Proxy objects
our $VERSION = '1.719';

use Exporter;
our @ISA = qw/Exporter/;

our @EXPORT_OK = qw(
  hook_names
);

our %EXPORT_TAGS = ( );

my ( @hook_names );

BEGIN {
    @hook_names                    = qw( context );
}

=sub hook_names

Returns a list of hook names.

=cut

sub hook_names { @hook_names }

1;
