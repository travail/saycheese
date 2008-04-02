#!/usr/bin/perl

use strict;
use warnings;
use FindBin qw/ $Bin /;
use lib "$Bin/../lib";
use lib '/home/public/cgi/lib';
use SayCheese;
use Digest::MD5 qw/ md5_hex /;
use Getopt::Long;
use Pod::Usage;

my $exec  = '';
my $debug = '';
my $help  = '';
Getopt::Long::Configure('bundling');
GetOptions(
    'e|exec'  => \$exec,
    'd|debug' => \$debug,
    'h|help'  => \$help,
);
pod2usage( 1 ) if $help;

my $config = SayCheese->config;
my $schema = SayCheese::Schema->connect( @{$config->{'Model::SayCheese'}->{connect_info}} );
$schema->storage->debug( 1 ) if $debug;

$schema->storage->txn_begin;
my $itr_thumbnail = $schema->resultset('SayCheese::Schema::Thumbnail')->search;
my $coderef = sub {
    while ( my $thumbnail = $itr_thumbnail->next ) {
        $thumbnail->digest( md5_hex( $thumbnail->url ) );
        $thumbnail->update;
    }
};
$schema->txn_do( $coderef );
if ( $@ ) {
    $schema->storage->txn_rollback;
} else {
    $exec ? $schema->storage->txn_commit : $schema->storage->txn_rollback;
}

exit;

__END__

=head1 NAME

create_digest.pl - Create digest from url.

=head1 SYNOPSIS

create_digest.pl [options]

=head1 OPTIONS

=over 8

=item B<-h, --help>
Print a brief help message and exits.

=item B<-e, --exec>
Execute SQL and COMMIT, otherwise ROLLBACK.

=item B<-d, --debug>
Print SQL.

=back

=head1 DESCRIPTION

B<This program> will read the given input file(s) and do something
useful with the contents thereof.

=cut
