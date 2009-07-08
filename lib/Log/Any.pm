package Log::Any;
use 5.006;
use Carp qw(croak);
use strict;
use warnings;

our $VERSION = '0.01';

my $Manager = Log::Any::Manager->new();

sub import {
    my $class  = shift;
    my $caller = caller();

    my @export_params = ($caller, @_);
    $class->_export_to_caller( $caller, @export_params );
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
    if ( my @vars = grep { /^\$/ } @params ) {
        foreach my $var (@vars) {
            my $value;
            if ( $var eq '$log' ) {
                $value = $class->get_logger( category => $caller );
            }
            else {
                croak $class->_invalid_import_error($param);
            }
            my $no_sigil_var = substr( $var, 1 );
            no strict 'refs';
            *{"$caller\::$no_sigil_var"} = \$value;
        }
    }
}

sub _invalid_import_error {
    my ( $class, $param ) = @_;

    die "invalid import '$param' - valid imports are '$log'";
}

sub use_logger {
    my $class = shift;
    $Manager->use_logger(@_);
}

sub get_logger {
    my $class = shift;
    $Manager->get_logger(@_);
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
the sam

e term

s as Perl itself.

=cut
