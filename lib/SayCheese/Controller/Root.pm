package SayCheese::Controller::Root;

use Moose;
BEGIN { extends 'Catalyst::Controller' }
no Moose;

use SayCheese::API::Thumbnail;
use SayCheese::Constants qw( ROWS );

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

sub index : Path('/') {
    my ( $self, $c ) = @_;

    my $url  = $c->req->param('url')  || '';
    my $rows = $c->req->param('rows') || ROWS;
    my $page = $c->req->param('page') || 1;
    my $api  = SayCheese::API::Thumbnail->new;
    my $iter_thumbnail = $api->index_thumbnails(
        { url => $url },
        {
            rows => $rows,
            page => $page,
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

    $c->not_found;
}

=head2 render

=cut

sub render : ActionClass('RenderView') {
    my ( $self, $c ) = @_;

    $c->log->info('*** SayCheese::Controller::Root::render ***');

    $c->load_template if !$c->stash->{template};
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
