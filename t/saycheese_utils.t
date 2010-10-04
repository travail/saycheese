use strict;
use warnings;
use Test::More tests => 21;
use Data::Dumper;

BEGIN { use_ok 'SayCheese::Utils' }

my @invalid_extension = qw(
    http://example.com/example.pdf
    http://example.com/example.mov
    http://example.com/example.rm
    http://example.com/example.wmv
    http://example.com/example.mp3
    http://example.com/example.mp4
    http://example.com/example.wav
    http://example.com/example.ppt
    http://example.com/example.doc
    http://example.com/example.png
    http://example.com/example.jpg
    http://example.com/example.jpeg
    http://example.com/example.gif
    http://example.com/example.zip
    http://example.com/example.lzh
    http://example.com/example.dmg
    http://example.com/example.pls
    http://example.com/example.swf
    http://example.com/example.gz
    http://example.com/example.tar.gz
);
foreach my $invalid_extension (@invalid_extension) {
    is(SayCheese::Utils::is_valid_extension($invalid_extension),
        0, 'is_valid_extension');
}
