package Log::Any;
use 5.006;
use Carp qw(croak);
use Log::Any::Manager;
use Log::Any::Util qw(dp);
use strict;
use warnings;

our $VERSION = '0.01';

my $Manager = Log::Any::Manager->new();

sub import {
    my $class  = shift;
    my $caller = caller();

    my @export_params = ( $caller, @_ );
    $class->_export_to_caller(@export_params);
}

sub _export_to_caller {
    my $class  = shift;
    my $caller = shift;

    # Parse parameters passed to 'use Log::Any'
    #
    my @vars;
    foreach my $param (@_) {
        if ( substr( $param, 0, 1 ) eq '$' ) {
            push( @vars, $param );
        }
        else {
            croak $class->_invalid_import_error($param);
        }
    }

    # Import requested variables into caller
    #
    foreach my $var (@vars) {
        my $value;
        if ( $var eq '$log' ) {
            $value = $class->get_logger( category => $caller );
        }
        else {
            croak $class->_invalid_import_error($var);
        }
        my $no_sigil_var = substr( $var, 1 );
        no strict 'refs';
        *{"$caller\::$no_sigil_var"} = \$value;
    }
}

sub _invalid_import_error {
    my ( $class, $param ) = @_;

    die "invalid import '$param' - valid imports are '\$log'";
}

sub set_adapter {
    my $class = shift;
    $Manager->set_adapter(@_);
}

sub get_logger {
    my ( $class, %params ) = @_;
    $Manager->get_logger( category => scalar( caller() ), %params );
}

sub logging_methods {
    my $class = shift;
    return qw(debug info notice warning error critical alert emergency);
}

sub detection_methods {
    my $class = shift;
    return map { "is_$_" } $class->logging_methods();
}

sub logging_and_detection_methods {
    my $class = shift;
    my @list = ( $class->logging_methods, $class->detection_methods );
    return @list;
}

1;

__END__

=pod

=head1 NAME

Log::Any -- Log anywhere

=head1 SYNOPSIS

    use Log::Any;

=head1 DESCRIPTION

Log::Any provides

=head1 AUTHOR

Jonathan Swartz

=head1 SEE ALSO

L<Some::Module>

=head1 COPYRIGHT & LICENSE

Copyright (C) 2007 Jonathan Swartz.

Log::Any is provided "as is" and without any express or implied warranties,
including, without limitation, the implied warranties of merchantibility and
fitness for a particular purpose.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
