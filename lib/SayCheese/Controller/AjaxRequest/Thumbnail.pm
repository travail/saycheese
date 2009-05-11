package SayCheese::Controller::AjaxRequest::Thumbnail;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use DateTime::Format::HTTP;
use Storable qw();
use SayCheese::API::Thumbnail;
use SayCheese::Constants qw( CACHE_FOR );
use SayCheese::DateTime;
use SayCheese::FileHandle;
use SayCheese::Gearman::Client;
use SayCheese::UserAgent;
use SayCheese::Utils qw();

=head1 NAME

SayCheese::Controller::AjaxRequest::Thumbnail - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 create

=cut

sub create : Path('create') : Args(0) {
    my ( $self, $c ) = @_;

    my $url = $c->req->param('url') || '';
    if ( !$url ) {
        $c->stash->{json_data} = {};
        $c->output_json;
        return;
    }

    my $ua  = SayCheese::UserAgent->new;
    my $res = $ua->get($url);
    if ( !$res->is_success ) {
        $c->stash->{json_data} = {};
        $c->output_json;
        return;
    }

    my $api = SayCheese::API::Thumbnail->new;
    my $obj = $api->find_by_url($url);
    if ($obj) {
        ## nothing to do.
    }
    else {
        my $client = SayCheese::Gearman::Client->new;
        my $id     = $client->do_task( 'saycheese',
            Storable::freeze( { url => $url } ), {} );
        $obj = $api->find($$id);
    }

    $c->stash->{json_data} = $obj ? $obj->as_hashref : {};
    $c->output_json;
}

=head2 delete

=cut

sub delete : Path('delete') : Args(0) {
    my ( $self, $c ) = @_;

    my $id  = $c->req->param('id') || '';
    my $api = SayCheese::API::Thumbnail->new;
    my $obj = $api->find($id);
    $obj->delete if $obj;

    $c->res->redirect('resent_thumbnails');
}

=head2 recent_thumbnails

=cut

sub recent_thumbnails : Path('recent_thumbnails') : Args(0) {
    my ( $self, $c ) = @_;

    my $api            = SayCheese::API::Thumbnail->new;
    my $iter_thumbnail = $api->index_thumbnails;

    $c->stash->{template}       = 'include/thumbnails.inc';
    $c->stash->{iter_thumbnail} = $iter_thumbnail;
    $c->output_file;
}

=head2 search_url

=cut

sub search_url : Path('search_url') : Args(0) {
    my ( $self, $c ) = @_;

    my $url            = $c->req->param('url') || '';
    my $api            = SayCheese::API::Thumbnail->new;
    my $iter_thumbnail = $api->search(
        { url      => { LIKE => sprintf q{%s%%}, $url } },
        { order_by => 'url ASC' },
    );

    $c->stash->{template}       = 'include/search_url_results.inc';
    $c->stash->{iter_thumbnail} = $iter_thumbnail;
    $c->output_file;
}

=head original

Returns original size thumbnail.

=cut

sub original : PathPart('original') Chained('') Args() {
    my ( $self, $c ) = @_;

    my $thumbnail = $c->cache->get( $c->req->uri->path_query );
    $c->res->content_type(qw( image/jpeg image/gif image/png ));
    $c->stash->{template} = 'include/thumbnail.inc';
    if ($thumbnail) {
        $c->log->info('*** Cache Hit! ***');
        $c->stash->{thumbnail} = $thumbnail;
        $c->output_file;
        $c->http_cache(
            content_type   => 'image/jpeg',
            content_length => length $c->res->body
        );
    }
    else {
        $c->log->info('*** Cache Not Hit... ***');
        my $url = $c->req->uri->path_query;
        $url =~ s{^/original/}{};
        $url = SayCheese::Utils::unescape_uri($url);
        my $thumbpath = SayCheese::Utils::url2thumbpath( $url, 'original' );
        if ( !-e $thumbpath ) {
            $c->log->info("*** Thumbnail Not Found... $thumbpath ***");
            my $api = SayCheese::API::Thumbnail->new;
            my $obj = $api->find_by_url_like($url);
            $thumbpath = $obj->original_path if $obj;
        }
        if ( -e $thumbpath ) {
            $c->log->info("*** Thumbnail Found! $thumbpath ***");
            $thumbnail = $c->slurp_thumbnail($thumbpath);
            $c->stash->{thumbnail} = $thumbnail;
            $c->output_file;
            $c->http_cache(
                content_type   => 'image/jpeg',
                content_length => length $c->res->body
            );
            $c->cache->set( $c->req->uri->path_query, $thumbnail );
        }
        else {
            $c->forward( 'no_image', [qw( medium )] );
        }
    }
}

=head large

Returns large size thumbnail.

=cut

sub large : PathPart('large') Chained('') Args() {
    my ( $self, $c ) = @_;

    my $thumbnail = $c->cache->get( $c->req->uri->path_query );
    $c->res->content_type(qw( image/jpeg image/gif image/png ));
    $c->stash->{template} = 'include/thumbnail.inc';
    if ($thumbnail) {
        $c->log->info('*** Cache Hit! ***');
        $c->stash->{thumbnail} = $thumbnail;
        $c->output_file;
        $c->http_cache(
            content_type   => 'image/jpeg',
            content_length => length $c->res->body
        );
    }
    else {
        $c->log->info('*** Cache Not Hit... ***');
        my $url = $c->req->uri->path_query;
        $url =~ s{^/large/}{};
        $url = SayCheese::Utils::unescape_uri($url);
        my $thumbpath = SayCheese::Utils::url2thumbpath( $url, 'large' );
        if ( !-e $thumbpath ) {
            $c->log->info("*** Thumbnail Not Found... $thumbpath ***");
            my $api = SayCheese::API::Thumbnail->new;
            my $obj = $api->find_by_url_like($url);
            $thumbpath = $obj->large_path if $obj;
        }
        if ( -e $thumbpath ) {
            $c->log->info("*** Thumbnail Found! $thumbpath ***");
            $thumbnail = $c->slurp_thumbnail($thumbpath);
            $c->stash->{thumbnail} = $thumbnail;
            $c->output_file;
            $c->http_cache(
                content_type   => 'image/jpeg',
                content_length => length $c->res->body
            );
            $c->cache->set( $c->req->uri->path_query, $thumbnail );
        }
        else {
            $c->forward( 'no_image', [qw( medium )] );
        }
    }
}

=head medium

Returns medium size thumbnail.

=cut

sub medium : PathPart('medium') Chained('') Args() {
    my ( $self, $c ) = @_;

    my $thumbnail = $c->cache->get( $c->req->uri->path_query );
    $c->res->content_type(qw( image/jpeg image/gif image/png ));
    $c->stash->{template} = 'include/thumbnail.inc';
    if ($thumbnail) {
        $c->log->info('*** Cache Hit! ***');
        $c->stash->{thumbnail} = $thumbnail;
        $c->output_file;
        $c->http_cache(
            content_type   => 'image/jpeg',
            content_length => length $c->res->body
        );
    }
    else {
        $c->log->info('*** Cache Not Hit... ***');
        my $url = $c->req->uri->path_query;
        $url =~ s{^/medium/}{};
        $url = SayCheese::Utils::unescape_uri($url);
        my $thumbpath = SayCheese::Utils::url2thumbpath( $url, 'medium' );
        if ( !-e $thumbpath ) {
            $c->log->info("*** Thumbnail Not Found... $thumbpath ***");
            my $api = SayCheese::API::Thumbnail->new;
            my $obj = $api->find_by_url_like($url);
            $thumbpath = $obj->medium_path if $obj;
        }
        if ( -e $thumbpath ) {
            $c->log->info("*** Thumbnail Found! $thumbpath ***");
            $thumbnail = $c->slurp_thumbnail($thumbpath);
            $c->stash->{thumbnail} = $thumbnail;
            $c->output_file;
            $c->http_cache(
                content_type   => 'image/jpeg',
                content_length => length $c->res->body
            );
            $c->cache->set( $c->req->uri->path_query, $thumbnail );
        }
        else {
            $c->forward( 'no_image', [qw( medium )] );
        }
    }
}

=head small

Returns small size thumbnail.

=cut

sub small : PathPart('small') Chained('') Args() {
    my ( $self, $c ) = @_;

    my $thumbnail = $c->cache->get( $c->req->uri->path_query );
    $c->res->content_type(qw( image/jpeg image/gif image/png ));
    $c->stash->{template} = 'include/thumbnail.inc';
    if ($thumbnail) {
        $c->log->info('*** Cache Hit! ***');
        $c->stash->{thumbnail} = $thumbnail;
        $c->output_file;
        $c->http_cache(
            content_type   => 'image/jpeg',
            content_length => length $c->res->body
        );
    }
    else {
        $c->log->info('*** Cache Not Hit... ***');
        my $url = $c->req->uri->path_query;
        $url =~ s{^/small/}{};
        $url = SayCheese::Utils::unescape_uri($url);
        my $thumbpath = SayCheese::Utils::url2thumbpath( $url, 'small' );
        if ( !-e $thumbpath ) {
            $c->log->info("*** Thumbnail Not Found... $thumbpath ***");
            my $api = SayCheese::API::Thumbnail->new;
            my $obj = $api->find_by_url_like($url);
            $thumbpath = $obj->small_path if $obj;
        }
        if ( -e $thumbpath ) {
            $c->log->info("*** Thumbnail Found! $thumbpath ***");
            $thumbnail = $c->slurp_thumbnail($thumbpath);
            $c->stash->{thumbnail} = $thumbnail;
            $c->output_file;
            $c->http_cache(
                content_type   => 'image/jpeg',
                content_length => length $c->res->body
            );
            $c->cache->set( $c->req->uri->path_query, $thumbnail );
        }
        else {
            $c->forward( 'no_image', [qw( small )] );
        }
    }
}

=head2 no_image

Returns NO IMAGE.

=cut

sub no_image : Private {
    my ( $self, $c, $size ) = @_;

    $c->stash->{template} = 'include/thumbnail.inc';
    $c->stash->{thumbnail} = $c->no_image($size);
    $c->output_file;
}

=head1 AUTHOR

TRAVAIL

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
