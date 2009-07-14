package Log::Any::Adapter::Base;
use Carp qw(croak);
use Log::Any;
use Log::Any::Util qw(make_method dump_one_line);
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

    make_method( $method,
        sub { my $self = shift; return $self->{$slot}->$adapter_method(@_) },
        $class );
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
            my @new_params = map { ref($_) ? dump_one_line($_) : $_ } @params;
            my $new_message = sprintf( $format, @new_params );
            $self->$method($new_message);
        }
    );
}

1;

__END__

=pod

=head1 NAME

Log::Any::Adapter::Base

=head1 DESCRIPTION

This is the base class for Log::Any adapters. See
L<Log::Any::Adapter::Development|Log::Any::Adapter::Development> for
information on developing Log::Any adapters.

=head1 AUTHOR

Jonathan Swartz

=head1 COPYRIGHT & LICENSE

Copyright (C) 2009 Jonathan Swartz, all rights reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
