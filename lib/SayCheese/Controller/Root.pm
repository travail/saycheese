package SayCheese::Controller::Root;

use strict;
use warnings;
use parent 'Catalyst::Controller';
use SayCheese::API::Thumbnail;
use SayCheese::Constants;

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config->{namespace} = '';

=head1 NAME

SayCheese::Controller::Root - Root Controller for SayCheese

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=cut


=head2 default

=cut

sub index : Path : Args(0) {
    my ( $self, $c ) = @_;

    my $url  = $c->req->param('url')  || '';
    my $rows = $c->req->param('rows') || '';
    my $page = $c->req->param('page') || '';
    my $api  = SayCheese::API::Thumbnail->new;
    my $iter_thumbnail = $api->index_thumbnails(
        { url => $url || undef },
        {
            rows => $rows || 20,
            page => $page || 1,
        }
    );

    $c->stash->{iter_thumbnail} = $iter_thumbnail;
    $c->stash->{fillform} = { url => $url };
}

=head2 default

=cut

sub default : Private {
    my ( $self, $c ) = @_;

    $c->log->info('*** SayCheese::Controller::Root::default ***');

    $c->load_template('index.tt');
    $c->forward('index');
}

=head2 render

=cut

sub render : ActionClass('RenderView') {
    my ( $self, $c ) = @_;

    $c->log->info('*** SayCheese::Controller::Root::render ***');

    $c->load_template unless $c->stash->{template};
}

=head2 end

Attempt to render a view, if needed.

=cut 

sub end : Private {
    my ( $self, $c ) = @_;

    $c->log->info('*** SayCheese::Controller::Root::end ***');

    $c->forward('render');
    $c->fillform( $c->stash->{fillform} ) if $c->stash->{fillform};
}


=head1 AUTHOR

TRAVAIL

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
