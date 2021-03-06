package SayCheese;

use Moose;
use Catalyst;
extends 'Catalyst';
no Moose;

use Path::Class::File;
use SayCheese::Constants qw( CACHE_FOR );
use SayCheese::DateTime;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a YAML file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root 
#                 directory

#use Catalyst qw(
#);

our $VERSION = '0.01';

# Configure the application. 
#
# Note that settings in SayCheese.yml (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with a external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    'Plugin::ConfigLoader' => { file => __PACKAGE__->path_to('etc/conf/') } );

# Start the application
__PACKAGE__->setup(qw(
    ConfigLoader
    Session
    Session::State::Cookie
    Session::Store::Memcached::Fast
    Authentication
    FillInForm
    +SayCheese::Plugin::NoImage
));
#    Cache::Memcached::Fast

=head2 slurp_thumnail

  Slurp thumbnail.

=cut

sub slurp_thumbnail {
    my ( $c, $path ) = @_;

    my $file = Path::Class::File->new($path);
    my $data = $file->slurp;

    return $data;
}

=head2 load_template

=cut

sub load_template {
    my ( $c, $template ) = @_;

    if ( $template || $c->action ) {
        $c->stash->{template} = $template || $c->action->reverse . '.tt';
    }
    else {
        $c->log->warn("No template loaded");
    }
}

=head2 output_file

=cut

sub output_file {
    my ( $c, %args ) = @_;

    $c->load_template( $args{file} ) if $args{file};
    my $method = $args{detach} ? 'detach' : 'forward';
    $c->$method('View::File');
}

=head2 output_json

=cut

sub output_json {
    my ( $c, %args ) = @_;

    $c->load_template( $args{file} ) if $args{file};
    my $method = $args{detach} ? 'detach' : 'forward';
    $c->$method('View::JSON');
}

=head2 output_thumbnail

=cut

sub output_thumbnail {
    my ( $c, $thumbnail ) = @_;

    $c->res->body($thumbnail);
    $c->http_cache(
        content_type   => 'image/jpeg',
        content_length => length $c->res->body
    );
}

=head2 output_no_image

Returns NO IMAGE.

=cut

sub output_no_image {
    my ( $c, %args ) = @_;

    $c->res->body( $c->no_image( $args{size} ) );
    $c->res->content_type('image/jpeg');
    $c->res->status(404);
}

=head2 not_found

Returns 404

=cut

sub not_found {
    my $c = shift;

    $c->res->status(404);
    $c->output_file(file => 'not_found.tt');
}

=head2 http_cache

=cut

sub http_cache {
    my ( $c, %args ) = @_;

    my $content_type   = $args{content_type}   || 'text/html';
    my $content_length = $args{content_length} || 0;
    my $expires        = $args{expires}        || CACHE_FOR;

    my $now = SayCheese::DateTime->now;
    my $exp = $now->clone->add( seconds => $expires );
    $c->res->content_type($content_type);
    $c->res->headers->header(
        'Expires'        => SayCheese::DateTime->format_http($exp),
        'Last-Modified'  => SayCheese::DateTime->format_http($now),
        'Content-Length' => $content_length,
    );
}

sub use_stats {1}
sub debug {1}

=head1 NAME

SayCheese - Catalyst based application

=head1 SYNOPSIS

    script/saycheese_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<SayCheese::Controller::Root>, L<Catalyst>

=head1 AUTHOR

TRAVAIL

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
