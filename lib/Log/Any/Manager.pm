package Log::Any::Manager;
use strict;
use warnings;
use Carp qw(croak);
use Log::Any::Adapter::Util qw(require_dynamic);

sub new {
    my $class = shift;
    my $self = { entries => [] };
    bless $self, $class;

    # Create the initial Null entry (this is always present)
    #
    $self->set('Null');
    my $null_entry = $self->{entries}->[0];

    # Start our category cache with any null adapters already returned from raw Log::Any
    #
    $self->{category_cache} = {
        map {
            (
                $_ => {
                    adapter => $Log::Any::NullAdapters{$_},
                    entry   => $null_entry
                }
              )
        } keys(%Log::Any::NullAdapters)
    };

    return $self;
}

sub get_logger {
    my ( $self, $category ) = @_;

    # Create a new adapter for this category if it is not already in cache
    #
    my $category_cache = $self->{category_cache};
    if ( !defined( $category_cache->{$category} ) ) {
        my $entry = $self->_choose_entry_for_category($category);
        my $adapter = $self->_new_adapter_for_entry( $entry, $category );
        $category_cache->{$category} = { entry => $entry, adapter => $adapter };
    }
    return $category_cache->{$category}->{adapter};
}

sub _choose_entry_for_category {
    my ( $self, $category ) = @_;

    foreach my $entry ( @{ $self->{entries} } ) {
        if ( $category =~ $entry->{pattern} ) {
            return $entry;
        }
    }
    die "no entries matched '$category' - should not get here!";
}

sub _new_adapter_for_entry {
    my ( $self, $entry, $category ) = @_;

    return $entry->{adapter_class}
      ->new( @{ $entry->{adapter_params} }, category => $category );
}

sub set {
    my $self = shift;
    my $options;
    if ( ref( $_[0] ) eq 'HASH' ) {
        $options = shift(@_);
    }
    my ( $adapter_name, @adapter_params ) = @_;

    croak "expected adapter name"
      unless defined($adapter_name) && $adapter_name =~ /\S/;

    my $pattern = $options->{category};
    if ( !defined($pattern) ) {
        $pattern = qr/.*/;
    }
    elsif ( !ref($pattern) ) {
        $pattern = qr/^\Q$pattern\E$/;
    }

    $adapter_name =~ s/^Log:://;    # Log::Dispatch -> Dispatch, etc.
    my $adapter_class = (
          substr( $adapter_name, 0, 1 ) eq '+'
        ? substr( $adapter_name, 1 )
        : "Log::Any::Adapter::$adapter_name"
    );
    require_dynamic($adapter_class);

    my $entry = $self->_new_entry( $pattern, $adapter_class, \@adapter_params );
    unshift( @{ $self->{entries} }, $entry );

    $self->_reselect_matching_adapters($pattern);

    if ( my $lex_ref = $options->{lexically} ) {
        $$lex_ref = Log::Any::Manager::_Guard->new(
            sub { $self->remove($entry) unless _in_global_destruction() } );
    }

    return $entry;
}

sub remove {
    my ( $self, $entry ) = @_;

    my $pattern = $entry->{pattern};
    my $size    = scalar( @{ $self->{entries} } );
    die "cannot remove bottom entry"
      if $entry eq $self->{entries}->[ $size - 1 ];
    $self->{entries} = [ grep { $_ ne $entry } @{ $self->{entries} } ];
    $self->_reselect_matching_adapters($pattern);
}

sub _new_entry {
    my ( $self, $pattern, $adapter_class, $adapter_params ) = @_;

    return {
        pattern        => $pattern,
        adapter_class  => $adapter_class,
        adapter_params => $adapter_params,
    };
}

sub _reselect_matching_adapters {
    my ( $self, $pattern ) = @_;

    return if _in_global_destruction();

    # Reselect adapter for each category matching $pattern
    #
    while ( my ( $category, $category_info ) =
        each( %{ $self->{category_cache} } ) )
    {
        my $new_entry = $self->_choose_entry_for_category($category);
        if ( $new_entry ne $category_info->{entry} ) {
            my $new_adapter =
              $self->_new_adapter_for_entry( $new_entry, $category );
            %{ $category_info->{adapter} } = %$new_adapter;
            bless( $category_info->{adapter}, ref($new_adapter) );
            $category_info->{entry} = $new_entry;
        }
    }
}

# This is adapted from the pure perl parts of Devel::GlobalDestruction
if ( defined ${^GLOBAL_PHASE} ) {
    eval 'sub _in_global_destruction () { ${^GLOBAL_PHASE} eq q[DESTRUCT] }; 1'
      or die $@;
}
else {
    require B;
    my $started = !B::main_start()->isa(q[B::NULL]);
    unless ($started) {
        eval '0 && $started; CHECK { $started = 1 }; 1'
          or die $@;
    }
    eval
      '0 && $started; sub _in_global_destruction () { $started && B::main_start()->isa(q[B::NULL]) }; 1'
      or die $@;
}

package    # hide from PAUSE
  Log::Any::Manager::_Guard;

sub new { bless $_[1], $_[0] }

sub DESTROY { $_[0]->() }

1;
