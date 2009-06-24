package Log::Any::Util;
use Carp qw( croak longmess );
use Data::Dumper;
use strict;
use warnings;
use base qw(Exporter);

our @EXPORT = qw(
  dp
  dps
);

our @EXPORT_OK = qw(
);

sub _dump_value_with_caller {
    my ($value) = @_;

    my $dump =
      Data::Dumper->new( [$value] )->Indent(1)->Sortkeys(1)->Quotekeys(0)
      ->Terse(1)->Dump();
    my @caller = caller(1);
    return sprintf( "[dp at %s line %d.] [%d] %s\n",
        $caller[1], $caller[2], $$, $dump );
}

sub dp {
    print STDERR _dump_value_with_caller(@_);
}

sub dps {
    print STDERR longmess( _dump_value_with_caller(@_) );
}

1;
