package Log::Any::Util;
use Carp qw( croak longmess );
use Data::Dumper;
use strict;
use warnings;
use base qw(Exporter);

our @EXPORT = qw(
);

our @EXPORT_OK = qw(
  make_alias
  require_dynamic
  dp
  dps
);

sub make_alias {
    my ( $method, $code, $pkg ) = @_;

    $pkg ||= caller();
    no strict 'refs';
    *{ $pkg . "::$method" } = $code;
}

sub _dump_value_with_caller {
    my ($value) = @_;

    my $dump =
      Data::Dumper->new( [$value] )->Indent(1)->Sortkeys(1)->Quotekeys(0)
      ->Terse(1)->Dump();
    my @caller = caller(1);
    return sprintf( "[dp at %s line %d.] [%d] %s\n",
        $caller[1], $caller[2], $$, $dump );
}

sub require_dynamic {
    my ($class) = @_;

    eval "require $class";
    die $@ if $@;
}

sub dp {
    print STDERR _dump_value_with_caller(@_);
}

sub dps {
    print STDERR longmess( _dump_value_with_caller(@_) );
}

1;
