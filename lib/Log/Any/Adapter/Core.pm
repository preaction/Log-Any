package Log::Any::Adapter::Core;
use strict;
use warnings;

# Forward 'warn' to 'warning', 'is_warn' to 'is_warning', and so on for all aliases
#
my %aliases = Log::Any->log_level_aliases;
while ( my ( $alias, $realname ) = each(%aliases) ) {
    _make_method( $alias, sub { my $self = shift; $self->$realname(@_) } );
    my $is_alias    = "is_$alias";
    my $is_realname = "is_$realname";
    _make_method( $is_alias,
        sub { my $self = shift; $self->$is_realname(@_) } );
}

# Add printf-style versions of all logging methods and aliases - e.g. errorf, debugf
#
foreach my $name ( Log::Any->logging_methods, keys(%aliases) ) {
    my $methodf = $name . "f";
    my $method = $aliases{$name} || $name;
    _make_method(
        $methodf,
        sub {
            my ( $self, $format, @params ) = @_;
            my @new_params = map { ref($_) ? dump_one_line($_) : $_ } @params;
            my $new_message = sprintf( $format, @new_params );
            $self->$method($new_message);
        }
    );
}

sub _make_method {
    my ( $method, $code, $pkg ) = @_;

    $pkg ||= caller();
    no strict 'refs';
    *{ $pkg . "::$method" } = $code;
}

1;
