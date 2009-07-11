package Log::Any::Util;
use Carp qw( longmess );
use Data::Dumper;
use strict;
use warnings;
use base qw(Exporter);

our @EXPORT = qw(
);

our @EXPORT_OK = qw(
  make_method
  read_file
  require_dynamic
  dump_one_line
  dp
  dps
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

sub read_file {
    my ($file) = @_;

    open( my $fh, $file );
    local $/;
    my $contents = <$fh>;
    return $contents;
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
