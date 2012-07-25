package CatalystX::Resource::Controller::Resource;
{
    $CatalystX::Resource::Controller::Resource::VERSION = '0.002003';
}
use Moose;
use namespace::autoclean;

# ABSTRACT: Base Controller for Resources

BEGIN { extends 'Catalyst::Controller::ActionRole'; }

use MooseX::Types::Moose qw/ ArrayRef /;
use MooseX::Types::Common::String qw/ NonEmptySimpleStr /;

with qw/
    CatalystX::Component::Traits
    /;

# merge traits from app config with local traits
has '+_trait_merge' => ( default => 1 );

__PACKAGE__->config(
    traits => [
        qw/
            List
            Show
            Delete
            Form
            Create
            Edit
            /
    ],
    action_roles => ['MatchRequestMethod'],
);

has 'model' => (
    is       => 'ro',
    isa      => NonEmptySimpleStr,
    required => 1,
);

has 'identifier_columns' => (
    is      => 'ro',
    isa     => 'ArrayRef',
    default => sub { [qw/ name title /] },
);

has 'resultset_key' => (
    is       => 'ro',
    isa      => NonEmptySimpleStr,
    required => 1,
);

has 'resources_key' => (
    is       => 'ro',
    isa      => NonEmptySimpleStr,
    required => 1,
);

has 'resource_key' => (
    is       => 'ro',
    isa      => NonEmptySimpleStr,
    required => 1,
);

has 'parent_key' => (
    is        => 'ro',
    isa       => NonEmptySimpleStr,
    predicate => 'has_parent',
);

has 'parents_accessor' => (
    is  => 'ro',
    isa => NonEmptySimpleStr,
);

has 'redirect_mode' => (
    is      => 'rw',
    isa     => NonEmptySimpleStr,
    default => 'list',
);

has 'error_path' => (
    is      => 'ro',
    isa     => NonEmptySimpleStr,
    default => '/default',
);

sub _redirect {
    my ( $self, $c ) = @_;

    my $path;
    my $mode     = $self->redirect_mode;
    my @captures = @{ $c->request->captures };
    my $action   = $c->action->name;

    ##############################
    # move_next || move_previous #
    ##############################
# path: /parents/1/resources/1/move_next        => redirect_path: /parents/1/resources/list
# path: /parents/1/resources/1/move_previous    => redirect_path: /parents/1/resources/list
# path: /resources/1/move_next                  => redirect_path: /resources/list
# path: /resources/1/move_previous              => redirect_path: /resources/list
    if ( $action eq 'move_next' || $action eq 'move_previous' ) {
        pop(@captures);
        $path = $c->uri_for_action( $self->action_for('list'), \@captures );
    }

    ########################
    # redirect_mode 'list' #
    ########################
# path: /parents/1/resources/create   => redirect_path: /parents/1/resources/list
# path: /parents/1/resources/3/edit   => redirect_path: /parents/1/resources/list
# path: /parents/1/resources/3/delete => redirect_path: /parents/1/resources/list
    elsif ( $mode eq 'list' ) {
        pop(@captures)
            unless $action eq 'create';
        $path = $c->uri_for_action( $self->action_for('list'), \@captures );
    }

    ########################
    # redirect_mode 'show' #
    ########################
# path: /parents/1/resources/create   => redirect_path: /parents/1/resources/<id>/show
# path: /parents/1/resources/3/edit   => redirect_path: /parents/1/resources/3/show
# path: /parents/1/resources/3/delete => redirect_path: /parents/1/resources/list
    elsif ( $mode eq 'show' ) {
        if ( $action eq 'create' ) {
            my $id_of_created_resource
                = $c->stash->{ $self->resource_key }->id;
            push @captures, $id_of_created_resource;
            $path
                = $c->uri_for_action( $self->action_for('show'), \@captures );
        }
        elsif ( $action eq 'edit' ) {
            $path
                = $c->uri_for_action( $self->action_for('show'), \@captures );
        }
        elsif ( $action eq 'delete' ) {
            pop(@captures);
            $path
                = $c->uri_for_action( $self->action_for('list'), \@captures );
        }
    }

    ###############################
    # redirect_mode 'show_parent' #
    ###############################
    # path: /parents/1/resources/create   => redirect_path: /parents/1/show
    # path: /resources/create             => redirect_path: /resources/list
    # path: /parents/1/resources/3/edit   => redirect_path: /parents/1/show
    # path: /resources/3/edit             => redirect_path: /resources/list
    # path: /parents/1/resources/3/delete => redirect_path: /parents/1/show
    # path: /resources/3/delete           => redirect_path: /resources/list
    elsif ( $mode eq 'show_parent' ) {
        if ( $self->has_parent ) {
            my @chain
                = @{ $c->dispatcher->expand_action( $c->action )->{chain} };

            # base_with_id action of parent
            my $parent_base_with_id_action;
            if ( $action eq 'create' ) {
                $parent_base_with_id_action = $chain[-3];
            }
            elsif ( $action eq 'edit' || $action eq 'delete' ) {
                $parent_base_with_id_action = $chain[-4];
                pop @captures;
            }

            # parent namespace
            my $parent_namespace = $parent_base_with_id_action->{namespace};

            # private path of show action of parent
            my $parent_show_action_private_path = "$parent_namespace/show";
            $path = $c->uri_for_action( $parent_show_action_private_path,
                \@captures );
        }
        else {
            $path = $c->uri_for_action( $self->action_for('list') );
        }
    }

    $c->res->redirect($path);
}

sub _msg {
    my ( $self, $c, $action, $id ) = @_;

    if ( $action eq 'not_found' ) {
        return $c->can('loc')
            ? $c->loc( 'error.resource_not_found', $id )
            : "No such resource: $id";
    }
    elsif ( $action eq 'create' ) {
        return $c->can('loc')
            ? $c->loc( 'resources.created', $self->_identifier($c) )
            : $self->_identifier($c) . " created.";
    }
    elsif ( $action eq 'update' ) {
        return $c->can('loc')
            ? $c->loc( 'resources.updated', $self->_identifier($c) )
            : $self->_identifier($c) . " updated.";
    }
    elsif ( $action eq 'delete' ) {
        return $c->can('loc')
            ? $c->loc( 'resources.deleted', $self->_identifier($c) )
            : $self->_identifier($c) . " deleted.";
    }
    elsif ( $action eq 'move_next' ) {
        return $c->can('loc')
            ? $c->loc( 'resources.moved_next', $self->_identifier($c) )
            : $self->_identifier($c) . " moved next.";
    }
    elsif ( $action eq 'move_previous' ) {
        return $c->can('loc')
            ? $c->loc( 'resources.moved_previous', $self->_identifier($c) )
            : $self->_identifier($c) . " moved previous.";
    }
}

sub _identifier {
    my ( $self, $c ) = @_;
    my $resource = $c->stash->{ $self->resource_key };

    for my $col ( @{ $self->identifier_columns } ) {
        if (   $resource->result_source->has_column($col)
            && defined $resource->$col
            && $resource->$col )
        {
            return $resource->$col;
        }
    }

    return ucfirst( $self->resource_key );
}

sub base : Chained('') PathPart('') CaptureArgs(0) {
    my ( $self, $c ) = @_;

    # Store the ResultSet in stash so it's available for other methods
    # get the model from the controllers config that consumes this role
    my $resultset;
    if ( $self->has_parent ) {
        $resultset = $c->stash->{ $self->parent_key }
            ->related_resultset( $self->parents_accessor );
    }
    else {
        $resultset = $c->model( $self->model );
    }
    $c->stash( $self->resultset_key => $resultset );
}

sub base_with_id : Chained('base') PathPart('') CaptureArgs(1) {
    my ( $self, $c, $id ) = @_;
    my $resource = $c->stash->{ $self->resultset_key }->find($id);
    if ($resource) {
        $c->stash->{ $self->resource_key } = $resource;
    }
    else {
        $c->stash( error_msg => $self->_msg( $c, 'not_found', $id ) );
        $c->detach( $self->error_path );
    }
}

__PACKAGE__->meta->make_immutable();
1;

__END__
=pod

=head1 NAME

CatalystX::Resource::Controller::Resource - Base Controller for Resources

=head1 VERSION

version 0.002003

=head1 ATTRIBUTES

=head2 model

required, the DBIC model associated with this resource. (e.g.: 'DB::CDs')

=head2 identifier_columns

ArrayRef of column names used as name in messages.

if you edit, delete, ... a resource a msg is stored in the stash.
the first defined value of the provided columns will be used.

example: "Resource 'Michael Jackson' has been deleted."

default: [ 'name', 'title' ]

if no identifier is found the resource_key is used

=head2 resultset_key

stash key used to store the resultset of this resource. (e.g.: 'cds_rs')

=head2 resources_key

stash key used to store all results of this resource. (e.g.: 'tracks')
You will need this to access a list of your resources in your template.

=head2 resource_key

stash key used to store specific result of this resource. (e.g.: 'track')
You will need this to access your resource in your template.

=head2 parent_key

for a nested resource 'parent_key' is used as stash key to store the parent item
(e.g.: 'cd')
this is required if parent_key is set

=head2 parents_accessor

the accessor on the parent resource to get a resultset
of this resource (accessor in DBIC has_many)
(e.g.: 'tracks')
this is required if parent_key is set

=head2 redirect_mode list|show|show_parent

After a created/edit/delete action a redirect takes place.
The redirect behavior can be controlled with the redirect_mode attribute.

default = 'list'

=head2 error_path

documented in L<CatalystX::Resource>

=head1 METHODS

=head2 _redirect

redirect request after create/edit/delete/move_next/move_previous

=head2 _msg

returns notification msg to be displayed

=head2 _identifier

return an identifier for the resource

=head1 ACTIONS

the following actions will be loaded

=head2 base

Starts a chain and puts resultset into stash

For nested resources chain childrens 'base' action
to parents 'base_with_id' action

=head2 base_with_id

chains to 'base' and puts resource with id into stash

=head1 AUTHOR

David Schmidt <davewood@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by David Schmidt.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

