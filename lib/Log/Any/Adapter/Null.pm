package Log::Any::Adapter::Null;
use Log::Any::Util qw(make_method);
use strict;
use warnings;
use base qw(Log::Any::Adapter::Base);

# All methods are no-ops
#
foreach my $method ( Log::Any->logging_and_detection_methods() ) {
    make_method( $method, sub { } );
}

1;

__END__

=pod

=head1 NAME

Log::Any::Adapter::Null

=head1 SYNOPSIS

    Log::Any->set_adapter('Null');

=head1 DESCRIPTION

This Log::Any adapter discards all log messages and returns false for all
detection methods (e.g. is_debug). This is the default adapter when Log::Any is
loaded.

=head1 SEE ALSO

L<Log::Any|Log::Any>

=head1 AUTHOR

Jonathan Swartz

=head1 COPYRIGHT & LICENSE

Copyright (C) 2007 Jonathan Swartz, all rights reserved.

This program is free software; you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut
