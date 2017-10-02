use 5.008001;
use strict;
use warnings;

package Log::Any::Adapter::Util;

# ABSTRACT: Common utility functions for Log::Any
our $VERSION = '1.702';

use Exporter;
our @ISA = qw/Exporter/;

my %LOG_LEVELS;
BEGIN {
    %LOG_LEVELS = (
        EMERGENCY => 0,
        ALERT     => 1,
        CRITICAL  => 2,
        ERROR     => 3,
        WARNING   => 4,
        NOTICE    => 5,
        INFO      => 6,
        DEBUG     => 7,
        TRACE     => 8,
    );
}

use constant \%LOG_LEVELS;

our @EXPORT_OK = qw(
  cmp_deeply
  detection_aliases
  detection_methods
  dump_one_line
  log_level_aliases
  logging_aliases
  logging_and_detection_methods
  logging_methods
  make_method
  numeric_level
  read_file
  require_dynamic
);

push @EXPORT_OK, keys %LOG_LEVELS;

our %EXPORT_TAGS = ( 'levels' => [ keys %LOG_LEVELS ] );

my ( %LOG_LEVEL_ALIASES, @logging_methods, @logging_aliases, @detection_methods,
    @detection_aliases, @logging_and_detection_methods );

BEGIN {
    %LOG_LEVEL_ALIASES = (
        inform => 'info',
        warn   => 'warning',
        err    => 'error',
        crit   => 'critical',
        fatal  => 'critical'
    );
    @logging_methods =
      qw(trace debug info notice warning error critical alert emergency);
    @logging_aliases               = keys(%LOG_LEVEL_ALIASES);
    @detection_methods             = map { "is_$_" } @logging_methods;
    @detection_aliases             = map { "is_$_" } @logging_aliases;
    @logging_and_detection_methods = ( @logging_methods, @detection_methods );
}

=func logging_methods

Returns a list of all logging method. E.g. "trace", "info", etc.

=cut

sub logging_methods               { @logging_methods }

=func detection_methods

Returns a list of detection methods.  E.g. "is_trace", "is_info", etc.

=cut

sub detection_methods             { @detection_methods }

=func logging_and_detection_methods

Returns a list of logging and detection methods (but not aliases).

=cut

sub logging_and_detection_methods { @logging_and_detection_methods }

=func log_level_aliases

Returns key/value pairs mapping aliases to "official" names.  E.g. "err" maps
to "error".

=cut

sub log_level_aliases             { %LOG_LEVEL_ALIASES }

=func logging_aliases

Returns a list of logging alias names.  These are the keys from
L</log_level_aliases>.

=cut

sub logging_aliases               { @logging_aliases }

=func detection_aliases

Returns a list of detection aliases.  E.g. "is_err", "is_fatal", etc.

=cut

sub detection_aliases             { @detection_aliases }

=func numeric_level

Given a level name (or alias), returns the numeric value described above under
log level constants.  E.g. "err" would return 3.

=cut

sub numeric_level {
    my ($level) = @_;
    my $canonical =
      exists $LOG_LEVEL_ALIASES{ lc $level } ? $LOG_LEVEL_ALIASES{ lc $level } : $level;
    return $LOG_LEVELS{ uc($canonical) };
}

=func dump_one_line

Given a reference, returns a one-line L<Data::Dumper> dump with keys sorted.

=cut

# lazy trampoline to load Data::Dumper only on demand but then not try to
# require it pointlessly each time
*dump_one_line = sub {
    require Data::Dumper;

    my $dumper = sub {
        my ($value) = @_;

        return Data::Dumper->new( [$value] )->Indent(0)->Sortkeys(1)->Quotekeys(0)
        ->Terse(1)->Useqq(1)->Dump();
    };

    my $string = $dumper->(@_);
    no warnings 'redefine';
    *dump_one_line = $dumper;
    return $string;
};

=func make_method

Given a method name, a code reference and a package name, installs the code
reference as a method in the package.

=cut

sub make_method {
    my ( $method, $code, $pkg ) = @_;

    $pkg ||= caller();
    no strict 'refs';
    *{ $pkg . "::$method" } = $code;
}

=func require_dynamic (DEPRECATED)

Given a class name, attempts to load it via require unless the class
already has a constructor available.  Throws an error on failure. Used
internally and may become private in the future.

=cut

sub require_dynamic {
    my ($class) = @_;

    return 1 if $class->can('new'); # duck-type that class is loaded

    unless ( defined( eval "require $class; 1" ) )
    {    ## no critic (ProhibitStringyEval)
        die $@;
    }
}

=func read_file (DEPRECATED)

Slurp a file.  Does *not* apply any layers.  Used for testing and may
become private in the future.

=cut

sub read_file {
    my ($file) = @_;

    local $/ = undef;
    open( my $fh, '<:utf8', $file ) ## no critic
      or die "cannot open '$file': $!";
    my $contents = <$fh>;
    return $contents;
}

=func cmp_deeply (DEPRECATED)

Compares L<dump_one_line> results for two references.  Also takes a test
label as a third argument.  Used for testing and may become private in the
future.

=cut

sub cmp_deeply {
    my ( $ref1, $ref2, $name ) = @_;

    my $tb = Test::Builder->new();
    $tb->is_eq( dump_one_line($ref1), dump_one_line($ref2), $name );
}

# 0.XX version loaded Log::Any and some adapters relied on this happening
# behind the scenes.  Since Log::Any now uses this module, we load Log::Any
# via require after compilation to mitigate circularity.
require Log::Any;

1;

=head1 DESCRIPTION

This module has utility functions to help develop L<Log::Any::Adapter>
subclasses or L<Log::Any::Proxy> formatters/filters.  It also has some
functions used in internal testing.

=head1 USAGE

Nothing is exported by default.

=head2 Log level constants

If the C<:levels> tag is included in the import list, the following numeric
constants will be imported:

    EMERGENCY => 0
    ALERT     => 1
    CRITICAL  => 2
    ERROR     => 3
    WARNING   => 4
    NOTICE    => 5
    INFO      => 6
    DEBUG     => 7
    TRACE     => 8

=cut

# vim: ts=4 sts=4 sw=4 et tw=75:
