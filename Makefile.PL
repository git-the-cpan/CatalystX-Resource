
use strict;
use warnings;



use ExtUtils::MakeMaker 6.30;



my %WriteMakefileArgs = (
  "ABSTRACT" => "Provide CRUD functionality to your Controllers",
  "AUTHOR" => "David Schmidt <davewood\@cpan.org>",
  "BUILD_REQUIRES" => {
    "Catalyst::Action::RenderView" => 0,
    "Catalyst::Plugin::Session::State::Cookie" => 0,
    "Catalyst::Plugin::Session::Store::File" => 0,
    "Catalyst::View::TT" => 0,
    "File::Temp" => 0,
    "FindBin" => 0,
    "HTTP::Message" => 0,
    "Test::Exception" => 0,
    "Test::More" => "0.88",
    "Test::UseAllModules" => 0,
    "URI" => 0
  },
  "CONFIGURE_REQUIRES" => {
    "ExtUtils::MakeMaker" => "6.30"
  },
  "DISTNAME" => "CatalystX-Resource",
  "EXE_FILES" => [],
  "LICENSE" => "perl",
  "NAME" => "CatalystX::Resource",
  "PREREQ_PM" => {
    "Catalyst::ActionRole::MatchRequestMethod" => 0,
    "Catalyst::Controller::ActionRole" => 0,
    "Catalyst::Model::DBIC::Schema" => 0,
    "Catalyst::Plugin::Session" => "0.27",
    "Catalyst::Runtime" => "5.80013",
    "CatalystX::InjectComponent" => 0,
    "DBIx::Class" => 0,
    "HTML::FormHandler" => 0,
    "HTML::FormHandler::Model::DBIC" => 0,
    "Moose" => 0,
    "MooseX::MethodAttributes" => 0,
    "MooseX::Types" => 0,
    "MooseX::Types::Common" => 0,
    "MooseX::Types::LoadableClass" => 0,
    "namespace::autoclean" => 0
  },
  "VERSION" => "0.003_001",
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



