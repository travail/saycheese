package SayCheese::Config;

use strict;
use warnings;
use base qw( Class::Singleton );
use Config::Any;
use File::Spec;
use SayCheese::Utils;

=head1 NAME

SayCheese::Config - The SayCheese Config Class

=head1 SYNOPSIS

See L<SayCheese>.

=head1 DESCRIPTION

=head1 METHODS

=head2 _new_instance

=cut

sub _new_instance {
    my $class = shift;

    my $self = {};
    bless $self , $class;
    $self->{config} = $self->load;

    return $self;
}

=head2 app_name

=cut

# looks ugly. Fix later
sub app_name { 'SayCheese' }

=head2 prefix

=cut

sub prefix { SayCheese::Utils::appprefix( shift->app_name ) }

=head2 config

=cut

sub config { shift->{config} }

=head2 laod

=cut

sub load {
    my $self = shift;

    my @files = $self->find_files;
    my $cfg   = Config::Any->load_files( { files => \@files, use_ext => 1 } );

    my $config = {};
    my $config_local = {};
    my $local_suffix = $self->get_config_local_suffix;
    for ( @$cfg ) {
        if ( ( keys %$_ )[ 0 ] =~ m{ $local_suffix \. }xms ) {
            $config_local =  $_->{ (keys %{$_})[0] };
        }
        else {
            $config = {
                %{ $_->{ (keys %{$_})[0] }},
                %{$config} ,
            }
        }
    }

    $config = { %{$config}, %{$config_local} };
    return $config;
}

=head2 local_file

=cut

sub local_file {
    my $self = shift;

    my $prefix = $self->prefix;
    return File::Spec->catfile($self->get_config_dir_path, $prefix . '_' . $self->get_config_local_suffix);
}

=head2 find_files

=cut

sub find_files {
    my $self = shift;

    my ( $path, $extension ) = $self->get_config_path;
    my $suffix     = $self->get_config_local_suffix;
    my @extensions = @{ Config::Any->extensions };

    my @files;
    if ( $extension ) {
        next unless grep { $_ eq $extension } @extensions;
        ( my $local = $path ) =~ s{\.$extension}{_$suffix.$extension};
        push @files, $path, $local;
    }
    else {
        @files = map { ( "$path.$_", "${path}_${suffix}.$_" ) } @extensions;
    }

    return @files;
}

=head2 get_config_dir_path

=cut

sub get_config_dir_path {
    my $self = shift;

    my $home = SayCheese::Utils->home;
    return File::Spec->catfile( $home , 'etc', 'conf', $self->prefix . ".yml");

}

=head2 get_config_path

=cut

sub get_config_path {
    my $self = shift;

    my $path = $self->get_config_dir_path;
    my $extension = 'yml';
    return ( $path, $extension );
}

=head2 get_config_local_suffix

=cut

sub get_config_local_suffix {
    my $self = shift;

    my $suffix = SayCheese::Utils::env_value( $self->app_name, 'CONFIG_LOCAL_SUFFIX' ) || 'local';
    return $suffix;
}

=head1 AUTHOR

TRAVAIL

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
