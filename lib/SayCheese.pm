package SayCheese;

use strict;
use warnings;

use Catalyst::Runtime '5.70';
use IO::File;

# Set flags and add plugins for the application
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a YAML file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root 
#                 directory

use Catalyst qw/
   -Debug
   ConfigLoader
   Static::Simple
   DateTime::Constructor
   DBIC::Profiler
   Dumper
/;

our $VERSION = '0.01';

# Configure the application. 
#
# Note that settings in SayCheese.yml (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with a external configuration file acting as an override for
# local deployment.

$ENV{IS_TEST} = __PACKAGE__->config->{home} eq '/home/travail/public_html/SVNHOME/SayCheese' ? 1 : 0;
__PACKAGE__->config( file => $ENV{IS_TEST} ? __PACKAGE__->config->{home} . '/etc/test.yml' : __PACKAGE__->config->{home} . '/etc/saycheese.yml' );

# Start the application
__PACKAGE__->setup;


=head2 thumbnail

=cut

sub thumbnail : Private { shift->model('DBIC::SayCheese::Thumbnail') }

=head2 check_thumbnail

=cut

sub check_thumbnails {
    my $c = shift;

    my $itr_thumbnail = $c->thumbnail->search;
    while ( my $thumb = $itr_thumbnail->next ) {
        my $path = sprintf q{%s/%d.%s}, $c->config->{thumbnail}->{thumbnail_path}, $thumb->id, $thumb->extention;
        $thumb->print_thumbnail unless -e $path;
    }
}

=head2 output_json

=cut

sub output_json : Private {
    my $c = shift;

    $c->stash->{only_json} = 1;
    $c->forward('View::JSON');
}

=head2 output_html

=cut

sub output_html : Private {
    my $c = shift;

    $c->stash->{only_html} = 1;
    $c->forward('View::HTML');
}


=head1 NAME

SayCheese - Catalyst based application

=head1 SYNOPSIS

    script/saycheese_server.pl

=head1 DESCRIPTION

[enter your description here]

=head1 SEE ALSO

L<SayCheese::Controller::Root>, L<Catalyst>

=head1 AUTHOR

Catalyst developer

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;
