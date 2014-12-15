use 5.008001;
use strict;
use warnings;

package Log::Any::Adapter::Base;

our $VERSION = '0.91'; # TRIAL

use Log::Any;

# we import dump_one_line in case anything uses it
use Log::Any::Adapter::Util qw/make_method dump_one_line/;

sub new {
    my $class = shift;
    my $self  = {@_};
    bless $self, $class;
    $self->init(@_);
    return $self;
}

sub init { }

# we have this in case anything uses it
sub delegate_method_to_slot {
    my ( $class, $slot, $method, $adapter_method ) = @_;

    make_method( $method,
        sub { my $self = shift; return $self->{$slot}->$adapter_method(@_) },
        $class );
}

# Forward 'warn' to 'warning', 'is_warn' to 'is_warning', and so on for all aliases
my %aliases = Log::Any->log_level_aliases;
while ( my ( $alias, $realname ) = each(%aliases) ) {
    make_method( $alias, sub { my $self = shift; $self->$realname(@_) } );
    my $is_alias    = "is_$alias";
    my $is_realname = "is_$realname";
    make_method( $is_alias, sub { my $self = shift; $self->$is_realname(@_) } );
}

1;
