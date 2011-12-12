package CatalystX::Resource;
{
    $CatalystX::Resource::VERSION = '0.02';    # TRIAL
}
use Moose::Role;
use CatalystX::InjectComponent;
use namespace::autoclean;

# ABSTRACT: Provide CRUD functionality to your Controllers

after 'setup_components' => sub {
    my $class       = shift;
    my $controllers = $class->config->{'CatalystX::Resource'}{'controllers'};
    for my $controller (@$controllers) {
        CatalystX::InjectComponent->inject(
            into      => $class,
            component => 'CatalystX::Resource::Controller::Resource',
            as        => 'Controller::Resource::' . $controller,
        );
    }
};

1;

__END__

=pod

=head1 NAME

CatalystX::Resource - Provide CRUD functionality to your Controllers

=head1 VERSION

version 0.02

=head1 SYNOPSIS

    use Catalyst qw/
        +CatalystX::Resource
    /;

    __PACKAGE__->config(
        'Controller::Resource::Artist' => {
            resultset_key => 'artists_rs',
            resources_key => 'artists',
            resource_key => 'artist',
            form_class => 'TestApp::Form::Resource::Artist',
            model => 'DB::Resource::Artist',
            actions => {
                base => {
                    PathPart => 'artists',
                },
            },
        },
        'CatalystX::Resource' => {
            controllers => [ qw/ Artist / ],
         },
     );

=head1 DESCRIPTION

CatalystX::Resource enhances your App with CRUD functionality.

After creating files for HTML::FormHandler, DBIx::Class
and Template Toolkit templates you get create/edit/delete/show/list
actions for free.

Resources can be nested.
(e.g.: Artist has_many Albums)

You can remove actions if you don't need them.

Example, you don't need the edit action:
    'Controller::Resource::Artist' => {
        ...,
        traits => ['-Edit'],
    },

Using the Sortable trait your resources are sortable:
    'Controller::Resource::Artist' => {
        ...,
        traits => ['Sortable'],
    },

=head1 AUTHOR

David Schmidt <davewood@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by David Schmidt.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut
