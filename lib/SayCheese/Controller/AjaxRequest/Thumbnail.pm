package SayCheese::Controller::AjaxRequest::Thumbnail;

use strict;
use warnings;
use base 'Catalyst::Controller';
use SayCheese::Utils qw/ url2thumbpath unescape_uri /;
use SayCheese::FileHandle;
use Digest::MD5 qw/ md5_hex /;
use Gearman::Client;
use DateTime::Format::HTTP;

=head1 NAME

SayCheese::Controller::AjaxRequest::Thumbnail - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 create

=cut

sub create : Local {
    my ( $self, $c ) = @_;

    my $url = $c->req->param('url');
    unless ( $url ) {
        $c->stash->{json_data} = {};
        $c->output_json;
        return;
    }

    my $res = $c->ua->get( $url );
    unless ( $res->is_success ) {
        $c->stash->{json_data} = {};
        $c->output_json;
        return;
    }

    my $obj = $c->model('DBIC::SayCheese::Thumbnail')->find_by_url( $url );
    if ( $obj ) {
        ## nothing to do.
    } else {
        my $client = Gearman::Client->new( job_servers => $c->config->{job_servers} );
        my $id = $client->do_task( 'saycheese', $url, {} );
        $obj   = $c->thumbnail->find( $$id );
    }

    $c->stash->{json_data} = $obj ? $obj->as_hashref : {};
    $c->output_json;
}

=haed2 update

=cut

sub update : Local {
    my ( $self, $c ) = @_;

    my $id = $c->req->param('id');
    my $obj = $c->thumbnail->find( $id );
    if ( $id ) {
        my $cache = $c->cache->get( $obj->url );
        if ( $cache ) {
            $c->log->info('*** Cache Hit! ***');
            $c->cache->delete( $obj->url );
            $c->log->info('*** Delete Cache ***');
        }
        my $client = Gearman::Client->new( job_servers => $c->config->{job_servers} );
        $client->do_task( 'saycheese', $obj->url, {} );
        $c->cache->set( $obj->url, $obj );
    }

    $c->res->redirect('recent_thumbnails');
}

=head2 delete

=cut

sub delete : Local {
    my ( $self, $c ) = @_;

    my $id  = $c->req->param('id');
    my $obj = $c->thumbnail->find( $id );
    $obj->delete if $obj;

    $c->res->redirect('resent_thumbnails');
}

=head2 recent_thumbnails

=cut

sub recent_thumbnails : Local {
    my ( $self, $c ) = @_;

    my $req = $c->req;
    my $itr_thumbnail = $c->thumbnail->index_thumbnails;

    $c->stash->{template}      = 'include/thumbnails.inc';
    $c->stash->{itr_thumbnail} = $itr_thumbnail;
    $c->output_file;
}

=head2 search_url

=cut

sub search_url : Local {
    my ( $self, $c ) = @_;

    my $url = $c->req->param('url');
    my $itr_thumbnail = $c->thumbnail->search(
        { url => { LIKE => sprintf q{%s%%}, $url } },
        { order_by => 'url ASC' },
    );

    $c->stash->{template}      = 'include/search_url_results.inc';
    $c->stash->{itr_thumbnail} = $itr_thumbnail;
    $c->output_file;
}

=head large

    Return large size thumbnail.

=cut

sub large : PathPart('large') Chained('') Args('') {
    my ( $self, $c ) = @_;

    my $url = $c->req->uri->path_query;
    $url =~ s{^/large/}{};
    $url = unescape_uri( $url );

    my $thumbnail = $c->cache->get( $url );
    if ( $thumbnail ) {
        $c->log->info('*** Cache Hit! ***');
        $c->forward( 'set_http_header', [ length( $thumbnail ) ] );
    } else {
        $c->log->info('*** Cache Not Hit... ***');
        my $thumbpath = url2thumbpath( $url, 'large' );
        if ( !-e $thumbpath ) {
            $c->log->info("*** Thumbnail Not Found... $thumbpath ***");
            my $obj = $c->thumbnail->find_by_url_like( $url );
            $thumbpath = $obj->large_path if $obj;
        }
        if ( -e $thumbpath ) {
            $c->log->info("*** Thumbnail Found! $thumbpath ***");
            $thumbnail = $c->slurp_thumbnail( $thumbpath );
            $c->cache->set( $url, $thumbnail );
            $c->forward( 'set_http_header', [ length( $thumbnail ) ] );
        } else {
            $thumbnail = $c->no_image('medium');
        }
    }

    $c->forward( 'post_process' , [ $thumbnail ] );
}

=head medium

    Return medium size thumbnail.

=cut

sub medium : PathPart('medium') Chained('') Args('') {
    my ( $self, $c ) = @_;

    my $url = $c->req->uri->path_query;
    $url =~ s{^/medium/}{};
    $url = unescape_uri( $url );

    my $thumbnail = $c->cache->get( $url );
    if ( $thumbnail ) {
        $c->log->info('*** Cache Hit! ***');
        $c->forward( 'set_http_header', [ length( $thumbnail ) ] );
    } else {
        $c->log->info('*** Cache Not Hit... ***');
        my $thumbpath = url2thumbpath( $url, 'medium' );
        if ( !-e $thumbpath ) {
            $c->log->info("*** Thumbnail Not Found... $thumbpath ***");
            my $obj = $c->thumbnail->find_by_url_like( $url );
            $thumbpath = $obj->medium_path if $obj;
        }
        if ( -e $thumbpath ) {
            $c->log->info("*** Thumbnail Found! $thumbpath ***");
            $thumbnail = $c->slurp_thumbnail( $thumbpath );
            $c->cache->set( $url, $thumbnail );
            $c->forward( 'set_http_header', [ length( $thumbnail ) ] );
        } else {
            $thumbnail = $c->no_image('medium');
        }
    }

    $c->forward( 'post_process', [ $thumbnail ] );
}

=head small

    Return small size thumbnail.

=cut

sub small : PathPart('small') Chained('') Args('') {
    my ( $self, $c ) = @_;

    my $url = $c->req->uri->path_query;
    $url =~ s{^/small/}{};
    $url = unescape_uri( $url );

    my $thumbnail = $c->cache->get( $url );
    if ( $thumbnail ) {
        $c->log->info('*** Cache Hit! ***');
        $c->forward( 'set_http_header', [ length( $thumbnail ) ] );
    } else {
        $c->log->info('*** Cache Not Hit... ***');
        my $thumbpath = url2thumbpath( $url, 'small' );
        if ( !-e $thumbpath ) {
            $c->log->info("*** Thumbnail Not Found... $thumbpath ***");
            my $obj = $c->thumbnail->find_by_url_like( $url );
            $thumbpath = $obj->small_path if $obj;
        }
        if ( -e $thumbpath ) {
            $c->log->info("*** Thumbnail Found! $thumbpath ***");
            $thumbnail = $c->slurp_thumbnail( $thumbpath );
            $c->cache->set( $url, $thumbnail );
            $c->forward( 'set_http_header', [ length( $thumbnail ) ] );
        } else {
            $thumbnail = $c->no_image('small')
        }
    }

    $c->forward( 'post_process', [ $thumbnail ] );
}

=head2 post_process

    Post Processor. Set Content-Type, stash 'thumbnail.inc' and thumbnail, and out put file.

=cut

sub post_process : Private {
    my ( $self, $c, $thumbnail ) = @_;

    $c->forward('set_content_type');
    $c->stash->{template}  = 'include/thumbnail.inc';
    $c->stash->{thumbnail} = $thumbnail;
    $c->output_file;
}

=head2 set_http_header

    Set Expires, Last-Modified, Content-Length for cache

=cut

sub set_http_header : Private {
    my ( $self, $c, $content_length ) = @_;

    $c->res->headers->header(
        'Expires'        => DateTime::Format::HTTP->format_datetime( $c->dt->add( seconds => $c->config->{cache}->{expires} ) ),
        'Last-Modified'  => DateTime::Format::HTTP->format_datetime( $c->dt ),
        'Content-Length' => $content_length,
    );
}

=head2 set_content_type

    Set Contet-Type for image

=cut

sub set_content_type : Private {
    my ( $self, $c ) = @_;

    $c->res->content_type( qw( image/jpeg image/gif image/png ) );
}

=head1 AUTHOR

travail

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
