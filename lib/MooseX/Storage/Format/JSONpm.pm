package MooseX::Storage::Format::JSONpm;
use MooseX::Role::Parameterized;
# ABSTRACT: a format role for MooseX::Storage using JSON.pm

=head1 SYNOPSIS

  package Point;
  use Moose;
  use MooseX::Storage;

  with Storage(format => 'JSONpm');

  has 'x' => (is => 'rw', isa => 'Int');
  has 'y' => (is => 'rw', isa => 'Int');

  1;

  my $p = Point->new(x => 10, y => 10);

  # pack the class into a JSON string
  my $json = $p->freeze(); # { "__CLASS__" : "Point", "x" : 10, "y" : 10 }

  # unpack the JSON string into an object
  my $p2 = Point->thaw($json);

=cut

use namespace::autoclean;

use JSON;

parameter json_opts => (
  isa => 'HashRef',
  default => sub { return { } },
  initializer => sub {
    my ($self, $value, $set) = @_;

    %$value = (ascii => 1, %$value);
    $set->($value);
  }
);

role {
  my $p = shift;

  requires 'pack';
  requires 'unpack';

=method freeze

  my $json = $obj->freeze;

=cut

  method freeze => sub {
    my ($self, @args) = @_;

    my $json = to_json($self->pack(@args), $p->json_opts);
    return $json;
  };

=method thaw

  my $obj = Class->thaw($json)

=cut

  method thaw => sub {
    my ($class, $json, @args) = @_;

    $class->unpack( from_json($json, $p->json_opts), @args);
  };

};

1;

=head1 THANKS

Thanks to Stevan Little, Chris Prather, and Yuval Kogman, from whom I cribbed
this code -- from MooseX::Storage::Format::JSON.
