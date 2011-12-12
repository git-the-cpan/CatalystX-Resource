
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Provide CRUD functionality to your Controllers",
  "AUTHOR" => "David Schmidt <davewood\@cpan.org>",
  "BUILD_REQUIRES" => {
    "Catalyst" => 0,
    "Catalyst::Model::DBIC::Schema" => 0,
    "Catalyst::ScriptRunner" => 0,
    "Catalyst::Test" => 0,
    "Catalyst::View::TT" => 0,
    "DBIx::Class" => 0,
    "DBIx::Class::Schema" => 0,
    "FindBin" => 0,
    "HTML::FormHandler::Model::DBIC" => 0,
    "HTML::FormHandler::Moose" => 0,
    "HTTP::Request::Common" => 0,
    "Test::Exception" => 0,
    "Test::Moose" => 0,
    "Test::More" => 0,
    "Test::UseAllModules" => 0,
    "URI" => 0,
    "base" => 0,
    "strict" => 0,
    "warnings" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "CatalystX-Resource",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "CatalystX::Resource",
  "PREREQ_PM" => {
    "Catalyst::Controller" => 0,
    "Catalyst::Plugin::Session" => 0,
    "Catalyst::Plugin::Session::State::Cookie" => 0,
    "Catalyst::Plugin::Session::Store::FastMmap" => 0,
    "CatalystX::Component::Traits" => 0,
    "CatalystX::InjectComponent" => 0,
    "Moose" => 0,
    "Moose::Role" => 0,
    "MooseX::MethodAttributes::Role" => 0,
    "MooseX::Types::Common::String" => 0,
    "MooseX::Types::LoadableClass" => 0,
    "MooseX::Types::Moose" => 0,
    "namespace::autoclean" => 0
  },
  "VERSION" => "0.02",
  "test" => {
    "TESTS" => "t/*.t"
  }
);


unless ( eval { ExtUtils::MakeMaker->VERSION(6.56) } ) {
  my $br = delete $WriteMakefileArgs{BUILD_REQUIRES};
  my $pp = $WriteMakefileArgs{PREREQ_PM};
  for my $mod ( keys %$br ) {
    if ( exists $pp->{$mod} ) {
      $pp->{$mod} = $br->{$mod} if $br->{$mod} > $pp->{$mod};
    }
    else {
      $pp->{$mod} = $br->{$mod};
    }
  }
}

delete $WriteMakefileArgs{CONFIGURE_REQUIRES}
  unless eval { ExtUtils::MakeMaker->VERSION(6.52) };

WriteMakefile(%WriteMakefileArgs);



