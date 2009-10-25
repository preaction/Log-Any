package Log::Any::Manager::Starter;
use Log::Any::Util qw(make_method);
use Log::Any::Adapter::Null;
use strict;
use warnings;
use base qw(Log::Any::Manager::Base);

sub new {
    my $class = shift;
    my $self  = {@_};
    bless $self, $class;
    $self->{category_cache} = {};
    return $self;
}

sub _get_logger_for_category {
    my ( $self, $category ) = @_;

    $self->{category_cache}->{$category} ||=
      { adapter => Log::Any::Adapter::Null->new() };
    return $self->{category_cache}->{$category}->{adapter};
}

1;
