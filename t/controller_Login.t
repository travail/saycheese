use strict;
use warnings;
use Test::More tests => 3;

BEGIN { use_ok 'Catalyst::Test', 'SayCheese' }
BEGIN { use_ok 'SayCheese::Controller::Login' }

ok( request('/login')->is_success, 'Request should succeed' );


