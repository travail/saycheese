#!/usr/bin/perl

use strict;
use warnings;
use FindBin ();
use lib "$FindBin::Bin/../../lib";
use SayCheese::Utils ();
use SayCheese::Schema;
use SayCheese::FileHandle;

my $schema = SayCheese::Schema->connect(Shiori::Utils::connect_info);
$schema->storage->debug(1);
my $itr_thumbnail = $schema->resultset('Thumbnail')->search;
while ( my $thumbnail = $itr_thumbnail->next ) {
    foreach my $size (qw( original large medium small )) {
        my $filename
            = SayCheese::Utils::url2thmbpath( $thumbnail->url, $size );
        my $fh = SayCheese::FileHandle->new( $filename, "w" );
        $fh->print( $thumbnail->$size );
        $fh->close;
    }
}

exit;
