#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw/ $Bin /;
use lib "$FindBin::Bin/../lib";
use SayCheese::ConfigLoader;
use SayCheese::Utils qw/ url2thmubpath /;
use SayCheese::Schema;
use SayCheese::FileHandle;

my $config = SayCheese::ConfigLoader->new->config;
my $schema = SayCheese::Schema->connect( @{$config->{'Model::DBIC::SayCheese'}->{connect_info}} );
$schema->storage->debug( 1 );
my $itr_thumbnail = $schema->resultset('Thumbnail')->search;
while ( my $thumbnail = $itr_thumbnail->next ) {
    foreach my $size ( qw/ original large medium small / ) {
        my $filename = url2thmbpath( $thumbnail->url, $size );
        my $fh = SayCheese::FileHandle->new( $filename, "w" );
        $fh->print( $thumbnail->$size );
        $fh->close;
    }
}

exit;
