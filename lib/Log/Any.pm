package Log::Any;
use 5.006;
use Carp qw(croak);
use strict;
use warnings;

our $VERSION = '0.01';

my ( $Logger_Spec, $Logger_Cache, @Exports );

sub import {
    my $class  = shift;
    my $caller = caller();

    my @export_params = ($caller, @_);
    push( @Exports, \@export_params );
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
            elsif ( $var =~ /^\$log_is_(debug|info|warn|error|fatal)$/ ) {
                my $method = "is_$1";
                $value = $class->get_logger( category => $caller )->$method;
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

sub set_logger {
    my $class = shift;
    $Logger_Spec = shift;
    $class->handle_logger_change();
}

# TODO: better name
sub handle_logger_change {
    my ($class) = @_;

    %Logger_Cache = ();
    foreach my $export_params (@Exports) {
        $class->_export_to_caller(@$export_params);
    }
}

sub get_logger {
    my ( $class, %params ) = @_;

    # Get category from params or from caller package
    #
    my $category = delete( $params{'category'} );
    if ( !defined($category) ) {
        $category = caller()
          || croak 'no category specified and could not determine from caller';
    }

    # Call resolve_logger_spec to get logger; memoize for category
    #
    my $logger = $Logger_Cache{$category};
    if ( !defined($logger) ) {
        $logger = $class->resolve_logger_spec( $Logger_Spec, $category );
        $Logger_Cache{$category} = $logger;
    }

    return $logger;
}

sub resolve_logger_spec {
    my ( $class, $spec, $category ) = @_;

    if ( !defined($spec) ) {
        return $class->null_logger();
    }
    elsif ( blessed($spec) ) {
        return $spec;
    }
    elsif ( ref($spec) eq 'CODE' ) {
        return $class->_resolve_logger_spec( $spec->($category) );
    }
    elsif ( $spec eq 'log4perl' ) {
        return Log::Log4perl->get_logger($category);
    }
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
