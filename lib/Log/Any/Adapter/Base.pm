package Log::Any::Adapter::Base;
use Carp qw(croak);
use Log::Any::Util qw(make_alias dump_one_line);
use strict;
use warnings;

sub new {
    my $class = shift;
    my $self  = {@_};
    bless $self, $class;
    $self->init();
    return $self;
}

sub init { }

sub delegate_method_to_slot {
    my ( $class, $slot, $method, $adapter_method ) = @_;

    make_alias( $method,
        sub { my $self = shift; return $self->{$slot}->$adapter_method(@_) },
        $class );
}

# Alias 'warn' to 'warning', etc.
#
my %aliases = Log::Any->log_level_aliases;
while (my ($alias, $realname) = each(%aliases)) {
    make_alias($alias, \&$realname);
}

# Add printf-style versions of all logging methods and aliases - e.g. errorf, debugf
#
foreach my $name (Log::Any->logging_methods, keys(%aliases)) {
    my $methodf = $name . "f";
    my $method = $aliases{$name} || $name;
    make_alias($methodf,
               sub {
                   my ($self, $format, @params) = @_;
                   my @new_params = map { ref($_) ? dump_one_line($_) : $_ } @params;
                   my $new_message = sprintf($format, @new_params);
                   $self->$method($new_message);
               });
}

1;
