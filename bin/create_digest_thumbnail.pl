#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw/ $Bin /;
use lib "$FindBin::Bin/../lib";
use lib '/home/public/cgi/lib';
use SayCheese;
use SayCheese::Utils qw/ url2thmubpath /;
use SayCheese::FileHandle;

my $config = SayCheese->config;
my $schema = SayCheese::Schema->connect( @{$config->{'Model::DBIC::SayCheese'}->{connect_info}} );
$schema->storage->debug( 1 );
my $itr_thumbnail = $schema->resultset('SayCheese::Schema::Thumbnail')->search;
while ( my $thumbnail = $itr_thumbnail->next ) {
    foreach my $size ( qw/ original large medium small / ) {
        my $filename = url2thmbpath( $thumbnail->url, $size );
        my $fh = SayCheese::FileHandle->new( $filename, "w" );
        $fh->print( $thumbnail->$size );
        $fh->close;
    }
}

exit;
