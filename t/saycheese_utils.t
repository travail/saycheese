use strict;
use warnings;
use Test::More tests => 41;
use SayCheese::Config;
use Data::Dumper;

BEGIN { use_ok 'SayCheese::Utils' }

my $config = SayCheese::Config->instance->config;

my @invalid_ext = @{$config->{invalid_extension}};
foreach my $invalid_ext (@invalid_ext) {
    my $url = 'http://example.com/file.' . $invalid_ext;
    is(SayCheese::Utils::is_valid_extension($url),
        0, 'is_valid_extension');
}

my @invalid_uri = @{$config->{invalid_uri}};
foreach my $invalid_uri (@invalid_uri) {
    is(SayCheese::Utils::is_valid_uri($invalid_uri),
        0, 'invalid_uri');
}

my @invalid_content_type = @{$config->{invalid_content_type}};
foreach my $invalid_content_type (@invalid_content_type) {
    is(SayCheese::Utils::is_valid_content_type($invalid_content_type),
        0, 'is_valid_content_type');
}
