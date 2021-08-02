package Log::Any::Adaptor::Test;
our $VERSION = '1.999_000';
# ABSTRACT: Base class for Log::Any adaptors

# XXX: Move to Log::Any::Base
sub new {
    my ( $class, @args ) = @_;
    my %self;
    if ( @args == 1 ) {
        %self = %{ $args[0] };
    }
    else {
        %self = @args;
    }
    return bless \%self, $class;
}

1;
