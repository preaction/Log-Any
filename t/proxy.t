
use v5.20;
use warnings;
use Test::More;

use Log::Any::Proxy ();

# XXX: Need a better way to do this
use Log::Any::Adaptor::Test;
push @Log::Any::Proxy::adaptors, Log::Any::Adaptor::Test->new;

my $log = Log::Any::Proxy->new;
my $recursive = sub {
    my $i = $_[0] + 1;
    return if $i > 3;
    $log->context( $i => $i );
    $log->info( 'Information before', { a => 'a' } );
    __SUB__->( $i );
    $log->info( 'Information after', { b => 'b' } );
};
$log->context( 0 => 0 );
$recursive->( 0 );

is_deeply $Log::Any::Proxy::adaptors[0]{log},
    [
        [ 7, 'Information before', { 0 => 0, 1 => 1, a => 'a' } ],
        [ 7, 'Information before', { 0 => 0, 1 => 1, 2 => 2, a => 'a' } ],
        [ 7, 'Information before', { 0 => 0, 1 => 1, 2 => 2, 3 => 3, a => 'a' } ],
        [ 7, 'Information after', { 0 => 0, 1 => 1, 2 => 2, 3 => 3, b => 'b' } ],
        [ 7, 'Information after', { 0 => 0, 1 => 1, 2 => 2, b => 'b' } ],
        [ 7, 'Information after', { 0 => 0, 1 => 1, b => 'b' } ],
    ];


my $saved_context = $log->context( req_id => 12345 );

# 1) Controller handler method - Same log object
# 2) Model method called by controller - Different log object
# 3) Controller subref called later - Same log object
# 4) Model method called by controller subref called later - Different
# log object


done_testing;
