use 5.008001;
use strict;
use warnings;

package Log::Any::Adapter::Base;

# ABSTRACT: Base class for Log::Any adapters
# VERSION

use Log::Any;
use Log::Any::Adapter::Util qw/make_method/;

sub new {
    my $class = shift;
    my $self  = {@_};
    bless $self, $class;
    $self->init(@_);
    return $self;
}

sub init { }

sub delegate_method_to_slot {
    my ( $class, $slot, $method, $adapter_method ) = @_;

    make_method( $method,
        sub { my $self = shift; return $self->{$slot}->$adapter_method(@_) },
        $class );
}

sub dump_one_line {
    my ( $self, $value ) = @_;

    return Data::Dumper->new( [$value] )->Indent(0)->Sortkeys(1)->Quotekeys(0)
      ->Terse(1)->Useqq(1)->Dump();
}

# Forward 'warn' to 'warning', 'is_warn' to 'is_warning', and so on for all aliases
#
my %aliases = Log::Any->log_level_aliases;
while ( my ( $alias, $realname ) = each(%aliases) ) {
    make_method( $alias, sub { my $self = shift; $self->$realname(@_) } );
    my $is_alias    = "is_$alias";
    my $is_realname = "is_$realname";
    make_method( $is_alias, sub { my $self = shift; $self->$is_realname(@_) } );
}

# Add printf-style versions of all logging methods and aliases - e.g. errorf, debugf
#
foreach my $name ( Log::Any->logging_methods, keys(%aliases) ) {
    my $methodf = $name . "f";
    my $method = $aliases{$name} || $name;
    make_method(
        $methodf,
        sub {
            my ( $self, $format, @params ) = @_;
            my @new_params =
              map {
                   !defined($_) ? '<undef>'
                  : ref($_)     ? $self->dump_one_line($_)
                  : $_
              } @params;
            my $new_message = sprintf( $format, @new_params );
            $self->$method($new_message);
        }
    );
}

1;

__END__

