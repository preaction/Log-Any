package Log::Any::Util;
use Carp qw( longmess );
use Data::Dumper;
use strict;
use warnings;
use base qw(Exporter);

our @EXPORT_OK = qw(
  dump_one_line
  make_method
  require_dynamic
);

sub make_method {
    my ( $method, $code, $pkg ) = @_;

    $pkg ||= caller();
    no strict 'refs';
    *{ $pkg . "::$method" } = $code;
}

sub dump_one_line {
    my ($value) = @_;

    return Data::Dumper->new( [$value] )->Indent(0)->Sortkeys(1)->Quotekeys(0)
      ->Terse(1)->Dump();
}

sub _dump_value_with_caller {
    my ($value) = @_;

    my $dump   = dump_one_line($value);
    my @caller = caller(1);
    return sprintf( "[dp at %s line %d.] [%d] %s\n",
        $caller[1], $caller[2], $$, $dump );
}

sub require_dynamic {
    my ($class) = @_;

    unless ( defined( eval "require $class" ) )
    {    ## no critic (ProhibitStringyEval)
        die $@;
    }
}

1;
