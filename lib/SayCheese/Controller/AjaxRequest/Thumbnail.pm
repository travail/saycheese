package SayCheese::Controller::AjaxRequest::Thumbnail;

use strict;
use warnings;
use base 'Catalyst::Controller';
use URI::Fetch;
use URI::Escape;
use Gearman::Client;

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

    my $res = URI::Fetch->fetch( $url );
    unless ( $res ) {
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

    $c->stash->{json_data} = $obj->as_hashref;
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

    my $obj = $c->cache->get( $url );
    if ( $obj ) {
        $c->log->info('*** Cache Hit!!! ***');
    } else {
        $c->log->info('*** Cache Not Hit... ***');
        $obj = $c->thumbnail->find_by_url( $url );
        $c->cache->set( $url, $obj ) if $obj;
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

    my $obj = $c->cache->get( $url );
    if ( $obj ) {
        $c->log->info('*** Cache Hit!!! ***');
    } else {
        $c->log->info('*** Cache Not Hit... ***');
        $obj = $c->thumbnail->find_by_url( $url );
        $c->cache->set( $url, $obj ) if $obj;
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

    my $obj = $c->cache->get( $url );
    if ( $obj ) {
        $c->log->info('*** Cache Hit!!! ***');
    } else {
        $c->log->info('*** Cache Not Hit... ***');
        $obj = $c->thumbnail->find_by_url( $url );
        $c->cache->set( $url, $obj ) if $obj;
    }

    $c->res->content_type( qw( image/jpeg image/gif image/png ) );
    $c->stash->{template}  = 'include/small.inc';
    $c->stash->{thumbnail} = $obj;
    $c->output_file;
}


=head2 api

=cut

sub api : PathPart('api') Chained('') Args('') {
    my ( $self, $c ) = @_;

    my $url = $c->req->uri->path_query;
    $url =~ s/^\/api\///;

    my $obj = $c->cache->get( $url );
    if ( $obj ) {
        $c->log->info('*** Cache Hit!!! ***');
    } else {
        $c->log->info('*** Cache Not Hit... ***');
        $obj = $c->thumbnail->find_by_url( $url );
        $c->cache->set( $url, $obj ) if $obj;
    }

    $c->res->content_type( qw( image/jpeg image/gif image/png ) );
    $c->stash->{template}  = 'include/thumbnail.inc';
    $c->stash->{thumbnail} = $obj;
    $c->output_file;
}

=head2 search_url

=cut

sub search_url : Local {
    my ( $self, $c ) = @_;

    my $url = $c->req->param('url');
    my $itr_thumbnail = $c->thumbnail->search( { url => { LIKE => sprintf q{%s%%}, $url } }, { order_by => 'url ASC' } );

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
