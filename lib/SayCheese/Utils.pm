package SayCheese::Utils;

use strict;
use warnings;
use base qw/ Exporter /;
use SayCheese::ConfigLoader;
use File::Basename qw/ dirname /;
use File::Path qw/ mkpath /;
use File::Spec;
use Digest::MD5 qw//;
use Path::Class;
use URI;
use Class::Inspector;

our @EXPORT_OK = ( qw/
    connect_info
    digest2thumbpath url2thumbpath unescape_uri
/ );

=head1 NAME

SayCheese::Utils - The SayCheese Utils

=head1 SYNOPSIS

See L<SayCheese>.

=head1 DESCRIPTION

=head1 METHODS

=head2 connect_info

Return connect_info

=cut

sub connect_info {
    my $config = SayCheese::ConfigLoader->new->config;
    return @{$config->{'Model::DBIC::SayCheese'}->{connect_info}};
}

=head2 digest2thumbpath( $digest, $size )

Return md5_hex file name from digest. Default size is medium.

=cut

sub digest2thumbpath {
    my ( $digest, $size ) = @_;

    return unless $digest;

    my $config = SayCheese::ConfigLoader->new->config;
    $size ||= $config->{thumbnail}->{default_size};
    return sprintf q{%s/%s/%s/%s.%s},
        $config->{thumbnail}->{dir}->{$size},
            substr( $digest, 0, 1 ),
                substr( $digest, 1, 1 ),
                    $digest,
                        $config->{thumbnail}->{extension};
}

=head2 url2thumbpath( $url, $size )

Return md5_hex file name from url. Default size is medium.

=cut

sub url2thumbpath {
    my ( $url, $size ) = @_;

    return unless $url;

    my $config = SayCheese::ConfigLoader->new->config;
    $size ||= $config->{thumbnail}->{default_size};
    my $thumbpath = digest2thumbpath( Digest::MD5::md5_hex( $url ), $size );
    my $dir = dirname( $thumbpath );
    mkpath( $dir ) unless -d $dir;

    return $thumbpath;
}

=head2 unescape_uri( $escaped_uri )

Unescape URI especialy %7E and %23.

=cut

sub unescape_uri {
    my $uri = shift;

    return unless $uri;

    $uri =~ s{%7E}{~}i;
    $uri =~ s{%23}{#}i;

    return $uri;
}

=head2 is_valid_scheme( $string )

Returns 1 if $string is valid scheme, or returns undef.

=cut

sub is_valid_scheme {
    my $string = shift;

    my $config = SayCheese::ConfigLoader->new->config;
    $string =~ /^(.*:\/\/)/;

    return grep {$1 eq $_} @{$config->{invalid_scheme}}
        ? 0 : 1;
}

=head2 is_valid_extension( $string )

Returns 1 if $string is valid extension, or returns undef.

=cut

sub is_valid_extension {
    my $string = shift;

    my $config = SayCheese::ConfigLoader->new->config;
    $string =~ /(.*)\.(.*)/;

    return grep {$2 eq $_} @{$config->{invalid_extension}}
        ? 0 : 1;
}

=head2 appprefix

=cut

sub appprefix {
    my $class = shift;
    $class =~ s/::/_/g;
    $class = lc($class);
    return $class;
}

=head2 class2appclass

=cut

sub class2appclass {
    my $class = shift || '';
    my $appname = '';
    if ( $class =~ /^(.+?)::([MVC]|Model|View|Controller)::.+$/ ) {
        $appname = $1;
    }
    return $appname;
}

=head2 class2classprefix

=cut

sub class2classprefix {
    my $class = shift || '';
    my $prefix;
    if ( $class =~ /^(.+?::([MVC]|Model|View|Controller))::.+$/ ) {
        $prefix = $1;
    }
    return $prefix;
}

=head2 class2classsuffix

=cut

sub class2classsuffix {
    my $class = shift || '';
    my $prefix = class2appclass($class) || '';
    $class =~ s/$prefix\:://;
    return $class;
}

=head2 class2env

=cut

sub class2env {
    my $class = shift || '';
    $class =~ s/::/_/g;
    return uc($class);
}

=head2 class2prefix

=cut

sub class2prefix {
    my $class = shift || '';
    my $case  = shift || 0;
    my $prefix;
    if ( $class =~ /^.+?::([MVC]|Model|View|Controller)::(.+)$/ ) {
        $prefix = $case ? $2 : lc $2;
        $prefix =~ s{::}{/}g;
    }
    return $prefix;
}

=head2 class2tmpdir

=cut

sub class2tempdir {
    my $class  = shift || '';
    my $create = shift || 0;
    my @parts = split '::', lc $class;

    my $tmpdir = dir( File::Spec->tmpdir, @parts )->cleanup;

    if ( $create && !-e $tmpdir ) {

        eval { $tmpdir->mkpath };

        if ($@) {
            # FIXME
            #MyApp::Exception->throw(
            #    message => qq/Couldn't create tmpdir '$tmpdir', "$@"/ );
        }
    }

    return $tmpdir->stringify;
}

=head2 home

=cut

sub home {
    my $class = shift;

    # make an $INC{ $key } style string from the class name
    (my $file = "$class.pm") =~ s{::}{/}g;

    if ( my $inc_entry = $INC{$file} ) {
        {
            # look for an uninstalled Catalyst app

            # find the @INC entry in which $file was found
            (my $path = $inc_entry) =~ s/$file$//;
            my $home = dir($path)->absolute->cleanup;

            # pop off /lib and /blib if they're there
            $home = $home->parent while $home =~ /b?lib$/;

            # only return the dir if it has a Makefile.PL or Build.PL
            if (-f $home->file("Makefile.PL") or -f $home->file("Build.PL")) {

                # clean up relative path:
                # MyApp/script/.. -> MyApp

                my ($lastdir) = $home->dir_list( -1, 1 );
                if ( $lastdir eq '..' ) {
                    $home = dir($home)->parent->parent;
                }

                return $home->stringify;
            }
        }

        {
            # look for an installed Catalyst app

            # trim the .pm off the thing ( Foo/Bar.pm -> Foo/Bar/ )
            ( my $path = $inc_entry) =~ s/\.pm$//;
            my $home = dir($path)->absolute->cleanup;

            # return if if it's a valid directory
            return $home->stringify if -d $home;
        }
    }

    # we found nothing
    return 0;
}

=head2 prefix

=cut

sub prefix {
    my ( $class, $name ) = @_;
    my $prefix = &class2prefix($class);
    $name = "$prefix/$name" if $prefix;
    return $name;
}

=env_value

=cut

sub env_value {
    my ( $class, $key ) = @_;

    $key = uc($key);
    my @prefixes = ( class2env($class), 'CATALYST' );

    for my $prefix (@prefixes) {
        if ( defined( my $value = $ENV{"${prefix}_${key}"} ) ) {
            return $value;
        }
    }

    return;
}

=head1 AUTHOR

travail, C<travail@travail.jp>

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
