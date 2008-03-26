package SayCheese::Controller::Root;

use strict;
use warnings;
use base 'Catalyst::Controller';
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

sub index : Private {
    my ( $self, $c ) = @_;

    my $req = $c->req;
    my $itr_thumbnail = $c->thumbnail->index_thumbnails(
        url  => $req->param('url') || undef,
        rows => $req->param('rows') || $c->config->{default_rows},
        page => $req->param('page') || 1,
    );

    $c->stash->{itr_thumbnail} = $itr_thumbnail;
    $c->stash->{fillform} = { url => $req->param('url') || undef };
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

    return if $c->stash->{only_file};
    return if $c->stash->{only_json};

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

Catalyst developer

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
