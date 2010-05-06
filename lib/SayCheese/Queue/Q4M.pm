package SayCheese::Queue::Q4M;

use Moose;
use Carp::Clan ();
use Queue::Q4M;
use namespace::autoclean;

has 'connect_info' => (
    is       => 'ro',
    isa      => 'ArrayRef',
    required => 0,
);

has 'tables' => (
    traits   => ['Array'],
    is       => 'rw',
    isa      => 'ArrayRef',
    required => 0,
    handles  => { add_tables => 'push' }
);

has 'columns' => (
    traits   => ['Array'],
    is       => 'rw',
    isa      => 'ArrayRef',
    required => 0,
    handles  => { add_columns => 'push' },
);

has 'q4m' => (
    is         => 'rw',
    lazy_build => 1,
);

has 'timeout' => (
    is       => 'rw',
    isa      => 'Int',
    default  => 300,
    required => 0,
);

sub _build_q4m { Queue::Q4M->connect( connect_info => shift->connect_info ) }

around 'enqueue' => sub {
    my ( $orig, $self, $table, $fields ) = @_;

    $fields ||= {};
    $table  ||= $self->tables->[0];
    $self->$orig( $table, $fields );
};

around 'dequeue' => sub {
    my ( $orig, $self, $table, $columns ) = @_;

    $columns ||= $self->columns;
    $self->$orig($table, $columns);
};

around 'dequeue_array' => sub {
    my ( $orig, $self, $table, $columns ) = @_;

    $columns ||= $self->columns;
    $self->$orig($table, $columns);
};

around 'dequeue_arrayref' => sub {
    my ( $orig, $self, $table, $columns ) = @_;

    $columns ||= $self->columns;
    $self->$orig($table, $columns);
};

around 'dequeue_hashref' => sub {
    my ( $orig, $self, $table, $columns ) = @_;

    $columns ||= $self->columns;
    $self->$orig($table, $columns);
};

__PACKAGE__->meta->make_immutable;

sub enqueue { $_[0]->q4m->insert( $_[1], $_[2] ) }

sub next {
    my ( $self, $conds, $timeout ) = @_;

    $conds   ||= [];
    $timeout ||= $self->timeout;

    my @tables = ();
    for ( my $i = 0; $i < @{$conds}; $i++ ) {
        next if !$conds->[$i];
        push @tables, sprintf '%s:%s', $self->tables->[$i], $conds->[$i];
    }
    @tables = @tables ? @tables : @{ $self->tables };

    return $self->q4m->next( @tables, $timeout );
}

sub dequeue { $_[0]->q4m->fetch( $_[1], $_[2] ) }
sub dequeue_array { $_[0]->q4m->fetch_array( $_[1], $_[2] ) }
sub dequeue_arrayref { $_[0]->q4m->fetch_arrayref( $_[1], $_[2] ) }
sub dequeue_hashref { $_[0]->q4m->fetch_hashref( $_[1], $_[2] ) }

sub end {
    my $self = shift;

    $self->q4m->owner_mode(0);
    $self->q4m->dbh->do('SELECT queue_end()')
        || Carp::Clan::croak( $self->q4m->dbh->errstr );
}

sub abort {
    my $self = shift;

    if ($self->q4m->owner_mode) {
        $self->q4m->dbh->do('SELECT queue_abort()')
            || Carp::Clan::croak( $self->q4m->dbh->errstr );
    }
    $self->q4m->owner_mode(0);
}

1;
