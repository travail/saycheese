#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw();
use lib "$FindBin::Bin/../../lib";
use Data::Dumper;
use File::Basename qw();
use File::Path qw();
use Getopt::Long;
use Path::Class::File;
use Pod::Usage;
use SayCheese::API::Thumbnail;
use SayCheese::Utils qw();

use constant THUMB_ROOT_DIR => '/tmp/SayCheese/thumbnail';
use constant THUMB_DIR_MAP => {
    original => THUMB_ROOT_DIR . '/original',
    large    => THUMB_ROOT_DIR . '/large',
    medium   => THUMB_ROOT_DIR . '/medium',
    small    => THUMB_ROOT_DIR . '/small',
};

my $debug = '';
my $help  = '';
Getopt::Long::Configure('bundling');
GetOptions(
    'd|debug' => \$debug,
    'h|help'  => \$help,
);
pod2usage(1) if $help;

main();
exit;

sub main {
    my $api_thumb = SayCheese::API::Thumbnail->new;
    my $iter_thumb = $api_thumb->search( {}, {} );

    while ( my $thumb = $iter_thumb->next ) {
        foreach my $size (qw(original large medium small)) {
            my $p_in
                = SayCheese::Utils::url2thumbpath( $thumb->url->as_string,
                $size );
            my $f_in  = Path::Class::File->new($p_in);
            my $p_out = url2thumbpath( $thumb->url->as_string, $size );
            my $f_out = Path::Class::File->new($p_out);
            if ( -e $p_in ) {
                $f_out->touch;
                my $fh = $f_out->openw || die $!;
                $fh->print( $f_in->slurp );
                $fh->close;
                warn sprintf qq{DEBUG: Writing %s size thumbnail %s.\n},
                    $size, $p_out
                    if $debug;
            }
            else {
                warn sprintf qq{DEBUG: Thumbnail does not exist.\n}, $size,
                    $p_in
                    if $debug;
            }
        }
    }
}

sub digest2thumbpath {
    my ( $digest, $size ) = @_;

    return unless $digest;

    $size ||= 'medium';
    return sprintf q{%s/%s/%s/%s/%s.jpg},
        THUMB_DIR_MAP->{$size},
        substr( $digest, 0, 1 ),
        substr( $digest, 1, 1 ),
        substr( $digest, 2, 1 ),
        $digest,
}

sub url2thumbpath {
    my ( $url, $size ) = @_;

    return unless $url;

    $size ||= 'medium';
    my $thumbpath = digest2thumbpath( Digest::MD5::md5_hex($url), $size );
    my $dir = File::Basename::dirname($thumbpath);

    File::Path::mkpath( $dir ) unless -d $dir;

    return $thumbpath;
}


__END__

=head1 NAME

migrate_thumbnail.pl - Migrate Thumbnails

=head1 SYNOPSIS

migrate_thumbnail.pl [options]

=head1 OPTIONS

=over 8

=item B<-d --debug>
debug mode.

=item B<-h, --help>
show this messages.

=back

=cut
