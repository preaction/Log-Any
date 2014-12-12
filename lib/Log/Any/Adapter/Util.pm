use 5.008001;
use strict;
use warnings;

package Log::Any::Adapter::Util;

# ABSTRACT: Common utility functions for Log::Any
our $VERSION = "0.90";

use Data::Dumper;
use base qw(Exporter);

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

use constant %LOG_LEVELS;

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
  read_file
  require_dynamic
  :levels
);

our %EXPORT_TAGS = ( ':levels' => [ keys %LOG_LEVELS ] );

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

sub log_level_aliases             { %LOG_LEVEL_ALIASES }
sub logging_methods               { @logging_methods }
sub logging_aliases               { @logging_aliases }
sub detection_methods             { @detection_methods }
sub detection_aliases             { @detection_aliases }
sub logging_and_detection_methods { @logging_and_detection_methods }

sub cmp_deeply {
    my ( $ref1, $ref2, $name ) = @_;

    my $tb = Test::Builder->new();
    $tb->is_eq( dump_one_line($ref1), dump_one_line($ref2), $name );
}

sub dump_one_line {
    my ($value) = @_;

    return Data::Dumper->new( [$value] )->Indent(0)->Sortkeys(1)->Quotekeys(0)
      ->Terse(1)->Dump();
}

sub make_method {
    my ( $method, $code, $pkg ) = @_;

    $pkg ||= caller();
    no strict 'refs';
    *{ $pkg . "::$method" } = $code;
}

sub read_file {
    my ($file) = @_;

    local $/ = undef;
    open( my $fh, '<', $file )
      or die "cannot open '$file': $!";
    my $contents = <$fh>;
    return $contents;
}

sub require_dynamic {
    my ($class) = @_;

    unless ( defined( eval "require $class" ) )
    {    ## no critic (ProhibitStringyEval)
        die $@;
    }
}

sub numeric_level {
    my ($level) = @_;
    my $canonical =
      exists $LOG_LEVEL_ALIASES{$level} ? $LOG_LEVEL_ALIASES{$level} : $level;
    return $LOG_LEVELS{ uc($canonical) };
}

1;
