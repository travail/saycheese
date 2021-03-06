package SayCheese::Utils;

use strict;
use warnings;
use base qw( Exporter );
use Encode ();
use Encode::Guess ();
use File::Basename qw( dirname );
use File::Path qw( mkpath );
use File::Spec;
use Digest::MD5 ();
use Path::Class;
use URI;
use Class::Inspector;
use Scalar::Util ();
use SayCheese::Config;

our @EXPORT_OK = ( qw(
    guess_encoding encode_utf8 encode_7bit_jis encode_iso_2022_jp decode
    connect_info
    digest2thumbpath url2thumbpath unescape_uri
) );

=head1 NAME

SayCheese::Utils - The SayCheese Utils

=head1 SYNOPSIS

See L<SayCheese>.

=head1 DESCRIPTION

=head1 METHODS

=cut

sub guess_encoding {
    my $text = shift;

    Encode::Guess->set_suspects(qw( euc-jp shiftjis 7bit-jis utf8 ));
    my $encode = Encode::Guess::guess_encoding($text);

    return ref $encode ? $encode->name : 'utf8';
}

sub encode_utf8 {
    my $text = shift;

    return Encode::encode( 'utf8',
        Encode::is_utf8($text) ? $text : SayCheese::Utils::decode($text) );
}

sub encode_7bit_jis {
    my $text = shift;

    return Encode::encode( '7bit-jis',
        Encode::is_utf8($text) ? $text : SayCheese::Utils::decode($text) );
}

sub encode_iso_2022_jp {
    my $text = shift;

    return Encode::encode( 'MIME-Header-ISO_2022_JP',
        Encode::is_utf8($text) ? $text : SayCheese::Utils::decode($text) );
}

sub decode {
    my $text = shift;

    if (Encode::is_utf8($text)) {
        return $text;
    }
    my $encoder = SayCheese::Utils::guess_encoding($text);

    return Encode::decode( $encoder, $text );
}

=head2 connect_info

Return connect_info

=cut

sub connect_info {
    my $config = SayCheese::Config->instance->config;
    return @{$config->{'Model::DBIC::SayCheese'}->{connect_info}};
}

=head2 digest2thumbpath( $digest, $size )

Return md5_hex file name from digest. Default size is medium.

=cut

sub digest2thumbpath {
    my ( $digest, $size ) = @_;

    return unless $digest;

    my $config = SayCheese::Config->instance->config;
    $size ||= $config->{thumbnail}->{default_size};
    return sprintf q{%s/%s/%s/%s/%s.%s},
        $config->{thumbnail}->{dir}->{$size},
        substr( $digest, 0, 1 ),
        substr( $digest, 1, 1 ),
        substr( $digest, 2, 1 ),
        $digest,
        $config->{thumbnail}->{extension};
}

=head2 url2thumbpath( $url, $size )

Return md5_hex file name from url. Default size is medium.

=cut

sub url2thumbpath {
    my ( $url, $size ) = @_;

    return unless $url;

    my $config = SayCheese::Config->instance->config;
    $size ||= $config->{thumbnail}->{default_size};
    my $thumbpath = digest2thumbpath( Digest::MD5::md5_hex( $url ), $size );
    my $dir = dirname( $thumbpath );
    mkpath( $dir ) unless -d $dir;

    return $thumbpath;
}

=head2 no_image_path

=cut

sub no_image_path {
    my $size = shift;

    $size ||= 'medium';
    my $config = SayCheese::Config->instance->config;

    return $config->{no_image}->{$size};
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

    my $config = SayCheese::Config->instance->config;
    $string =~ /^(.*:\/\/)/;

    return grep( {$1 eq $_} @{$config->{invalid_scheme}} )
        ? 0 : 1;
}

=head2 is_valid_uri( $string )

Returns 1 if $string is valid URI, or returns undef.

=cut

sub is_valid_uri {
    my $string = shift;

    my $config = SayCheese::Config->instance->config;
    foreach my $invalid ( @{ $config->{invalid_uri} } ) {
        return 0 if $string =~ m{^$invalid};
    }

    return 1;
}

=head2 is_valid_extension( $string )

Returns 1 if $string is valid extension, or returns 0.

=cut

sub is_valid_extension {
    my $string = shift;

    my $config = SayCheese::Config->instance->config;
    $string =~ /(.*)\.(.*)/;

    return grep( { lc $2 eq $_ } @{ $config->{invalid_extension} } ) ? 0 : 1;
}

=head2 is_valid_content_type( $content_type )

Returns 1 if $string is valid content type, or returns 0.

=cut

sub is_valid_content_type {
    my $string = shift;

    my $config = SayCheese::Config->instance->config;

    return grep( { $string eq $_ } @{ $config->{invalid_content_type} } ) ? 0 : 1;
}

sub is_natural_number {
    my $num = shift;

    return
           Scalar::Util::looks_like_number($num)
        && ( $num > 0 )
        && ( $num % 1 == 0 );
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

                my $dir;
                my @dir_list = $home->dir_list();
                while ( ( $dir = pop( @dir_list ) ) && $dir eq '..' ) {
                    $home = dir( $home )->parent->parent;
                }

#                my ($lastdir) = $home->dir_list( -1, 1 );
#                if ( $lastdir eq '..' ) {
#                    $home = dir($home)->parent->parent;
#                }

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

TRAVAIL

=head1 COPYRIGHT

This program is free software, you can redistribute it and/or modify it under
the same terms as Perl itself.

=cut

1;
