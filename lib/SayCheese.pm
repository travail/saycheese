package SayCheese;

use strict;
use warnings;
use NEXT;

use Catalyst::Runtime '5.70';

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
    Cache::Memcached
    FillInForm
    DateTime::Constructor
    DBIC::Profiler
    +SayCheese::Plugin::UserAgent
    +SayCheese::Plugin::NoImage
    View
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

__PACKAGE__->config( 'Plugin::ConfigLoader' => { file => __PACKAGE__->path_to('etc/conf/') } );

# Start the application
__PACKAGE__->setup;


=head2 thumbnail

=cut

sub thumbnail : Private { shift->model('DBIC::SayCheese::Thumbnail') }


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
