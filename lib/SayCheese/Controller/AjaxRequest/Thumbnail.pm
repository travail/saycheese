package SayCheese::Controller::AjaxRequest::Thumbnail;

use strict;
use warnings;
use base 'Catalyst::Controller';
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
        $obj->print_thumbnail;
    } else {
        my $client = Gearman::Client->new( job_servers => $c->config->{job_servers} );
        my $id = $client->do_task( 'saycheese', $url, {} );
        $obj   = $c->thumbnail->find( $$id );
    }

    $c->stash->{json_data} = $obj ? $obj->as_hashref : {};
    $c->output_json;
}

=head2 delete

=cut

sub delete : Local {
    my ( $self, $c ) = @_;

    my $id = $c->req->param('id');
    my $obj = $c->thumbnail->find( $id );
    if ( $obj ) {
        unlink $obj->path;
        $obj->delete;
    }

    $c->res->redirect('resent_thumbnails');
}

=head2 recent_thumbnails

=cut

sub recent_thumbnails : Local {
    my ( $self, $c ) = @_;

    my $req = $c->req;
    my $itr_thumbnail = $c->thumbnail->search( {},
        {
            order_by => 'id DESC',
            rows     => $req->param('rows') || $c->config->{default_rows},
            page     => $req->param('page') || 1,
        }
    );

    $c->stash->{template}      = 'include/thumbnails.inc';
    $c->stash->{itr_thumbnail} = $itr_thumbnail;
    $c->output_file;
}

=head large

=cut

sub large : PathPart('large') Chained('') Args('') {
    my ( $self, $c ) = @_;

    my $url = $c->req->uri->path_query;
    $url =~ s/^\/large\///;
    $url =~ s/%7E/~/;

    my $obj = $c->cache->get( $url );
    if ( $obj ) {
        $c->log->info('*** Cache Hit!!! ***');
    } else {
        $c->log->info('*** Cache Not Hit... ***');
        $obj = $c->thumbnail->find_by_url( $url );
        if ( $obj ) {
            $c->cache->set( $url, $obj );
            ## set Expires, Last-Modified, Content-Length for cache
            $c->res->headers->header(
                'Expires'        => DateTime::Format::HTTP->format_datetime( $c->dt->add( seconds => $c->config->{cache}->{expires} ) ),
                'Last-Modified'  => DateTime::Format::HTTP->format_datetime( $c->dt ),
                'Content-Length' => length $obj->large,
            );
        } else {
            $obj = {};
            $obj->{large} = $c->no_image_l;
        }
    }

    $c->res->content_type( qw( image/jpeg image/gif image/png ) );
    $c->stash->{template}  = 'include/large.inc';
    $c->stash->{thumbnail} = $obj;
    $c->output_file;
}

=head medium

=cut

sub medium : PathPart('medium') Chained('') Args('') {
    my ( $self, $c ) = @_;

    my $url = $c->req->uri->path_query;
    $url =~ s/^\/medium\///;
    $url =~ s/%7E/~/;

    my $obj = $c->cache->get( $url );
    if ( $obj ) {
        $c->log->info('*** Cache Hit!!! ***');
    } else {
        $c->log->info('*** Cache Not Hit... ***');
        $obj = $c->thumbnail->find_by_url( $url );
        if ( $obj ) {
            $c->cache->set( $url, $obj );
            ## set Expires, Last-Modified, Content-Length for cache
            $c->res->headers->header(
                'Expires'        => DateTime::Format::HTTP->format_datetime( $c->dt->add( seconds => $c->config->{cache}->{expires} ) ),
                'Last-Modified'  => DateTime::Format::HTTP->format_datetime( $c->dt ),
                'Content-Length' => length $obj->medium,
            );
        } else {
            $obj = {};
            $obj->{medium} = $c->no_image_m;
        }
    }

    $c->res->content_type( qw( image/jpeg image/gif image/png ) );
    $c->stash->{template}  = 'include/medium.inc';
    $c->stash->{thumbnail} = $obj;
    $c->output_file;
}

=head small

=cut

sub small : PathPart('small') Chained('') Args('') {
    my ( $self, $c ) = @_;

    my $url = $c->req->uri->path_query;
    $url =~ s/^\/small\///;
    $url =~ s/%7E/~/;

    my $obj = $c->cache->get( $url );
    if ( $obj ) {
        $c->log->info('*** Cache Hit!!! ***');
    } else {
        $c->log->info('*** Cache Not Hit... ***');
        $obj = $c->thumbnail->find_by_url( $url );
        if ( $obj ) {
            $c->cache->set( $url, $obj ) if $obj;
            ## set Expires, Last-Modified, Content-Length for cache
            $c->res->headers->header(
                'Expires'        => DateTime::Format::HTTP->format_datetime( $c->dt->add( seconds => $c->config->{cache}->{expires} ) ),
                'Last-Modified'  => DateTime::Format::HTTP->format_datetime( $c->dt ),
                'Content-Length' => length $obj->small,
            );
        } else {
            $obj = {};
            $obj->{small} = $c->no_image_s;
        }
    }

    $c->res->content_type( qw( image/jpeg image/gif image/png ) );
    $c->stash->{template}  = 'include/small.inc';
    $c->stash->{thumbnail} = $obj;
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

=head1 AUTHOR

A clever guy

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
