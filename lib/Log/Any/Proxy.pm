use 5.008001;
use strict;
use warnings;

package Log::Any::Proxy;

# ABSTRACT: Log::Any generator proxy object
# VERSION

use Log::Any;

sub _default_formatter {
    my ( $format, @params ) = @_;
    my @new_params =
      map { !defined($_) ? '<undef>' : ref($_) ? _dump_one_line($_) : $_ }
      @params;
    return sprintf( $format, @new_params );
}

sub _dump_one_line {
    my ($value) = @_;

    return Data::Dumper->new( [$value] )->Indent(0)->Sortkeys(1)->Quotekeys(0)
      ->Terse(1)->Useqq(1)->Dump();
}

sub new {
    my $class = shift;
    my $self = { formatter => \&_default_formatter, @_ };
    Carp::croak("$class requires an 'adapter' parameter")
      unless $self->{adapter};
    bless $self, $class;
    $self->init(@_);
    return $self;
}

sub init { }

for my $attr ( qw/adapter filter formatter prefix/ ) {
    no strict 'refs';
    *{$attr} = sub { return $_[0]->{$attr} };
}

my %aliases = Log::Any->log_level_aliases;

# Set up methods/aliases and detection methods/aliases
foreach my $name ( Log::Any->logging_methods, keys(%aliases) ) {
    my $realname    = $aliases{$name} || $name;
    my $namef       = $name . "f";
    my $is_name     = "is_$name";
    my $is_realname = "is_$realname";
    no strict 'refs';
    *{$is_name} = sub {
        my ($self) = @_;
        return $self->{adapter}->$is_realname;
    };
    *{$name} = sub {
        my ( $self, $message ) = @_;
        return unless defined $message and length $message;
        $message = $self->{filter}->($message) if defined $self->{filter};
        return unless defined $message and length $message;
        $message = "$self->{prefix}$message"
          if defined $self->{prefix} && length $self->{prefix};
        return $self->{adapter}->$realname($message);
    };
    *{$namef} = sub {
        my ( $self, @args ) = @_;
        return unless $self->{adapter}->$is_realname;
        my $message = $self->{formatter}->(@args);
        return unless defined $message and length $message;
        return $self->$name($message);
    };
}

1;

