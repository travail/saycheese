package SayCheese::HTML::Parser;

use Moose;
use HTML::TreeBuilder;
use SayCheese::UserAgent;
use SayCheese::Utils ();
use namespace::autoclean;

has user_agent => (
    is       => 'rw',
    required => 0,
    lazy     => 1,
    builder  => '_build_user_agent',
);

has timeout => (
    is       => 'ro',
    isa      => 'Int',
    default  => 5,
    required => 0,
);

has is_success => (
    is       => 'rw',
    isa      => 'Bool',
    default  => 0,
    required => 0,
);

has status_code => (
    is       => 'rw',
    isa      => 'Int',
    default  => 0,
    required => 0,
);

has content => (
    is       => 'rw',
    isa      => 'Str',
    default  => undef,
    required => 0,
);

has decoded_content => (
    is       => 'rw',
    isa      => 'Str',
    default  => undef,
    required => 0,
);

sub _build_user_agent {
    my $self = shift;

    return SayCheese::UserAgent->new( timeout => $self->timeout );
}

__PACKAGE__->meta->make_immutable;

sub parse {
    my ( $self, $target ) = @_;

    Carp::Clan::croak("No 'target' specified") if !$target;

    if ( my $type = ref $target ) {
        if ( $type eq 'SCALAR' ) {
            return $self->_parse_from_string($target);
        }
        else {
            return $self->parse_from_fh($target);
        }
    }
    elsif ( $target =~ m{^http(.*)}s ) {
        return $self->_parse_from_uri($target);
    }
    else {
        return $self->_parse_from_file($target);
    }
}

sub _parse_from_string { Carp::Clan::croak('Not implemented') }
sub _parse_from_fh     { Carp::Clan::croak('Not implemented') }

sub _parse_from_uri {
    my ( $self, $uri ) = @_;

    my $res = $self->user_agent->get($uri);
    $self->status_code( $res->code );
    $self->is_success( $res->is_success );
    return '' if !$res->is_success;

    $self->content( $res->content );
    $self->decoded_content( $res->decoded_content );

    return $self;
}

sub _parse_from_file { Carp::Clan::croak('Not implemented') }

sub title {
    my $self = shift;

    my $decoded_content = $self->decoded_content;
    return '' if !$decoded_content;

    my $tree = HTML::TreeBuilder->new;
    $tree->parse( SayCheese::Utils::decode($decoded_content) );
    $tree->eof;

    my $title = '';
    foreach my $element ( $tree->find('title') ) {
        $title = $element->as_text;
    }

    return length $title ? SayCheese::Utils::encode_utf8($title) : '';
}

1;
