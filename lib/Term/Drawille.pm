## no critic (RequireUseStrict)
package Term::Drawille;

## use critic (RequireUseStrict)
use strict;
use warnings;
use utf8;
use charnames ();

my %BRAILLE_MAPPING; # 12374568 => braille char
my $VERT_PIXELS_PER_CELL = 4;
my $HORZ_PIXELS_PER_CELL = 2;

$BRAILLE_MAPPING{'00000000'} = '⠀';
for my $value (1 .. 255) {
    $value     = sprintf('%08b', $value);
    my @values = unpack('A' x 8, $value);

    # the braille character names order the dots as such:
    #
    #   1 4
    #   2 5
    #   3 6
    #   7 8
    #

    my @indices = ( 1, 2, 3, 7, 4, 5, 6, 8 );
    my $char_name = 'BRAILLE PATTERN DOTS-' . join('', sort(map { $indices[$_] } grep {
        $values[$_]
    } ( 0 .. 7 )));

    $BRAILLE_MAPPING{$value} = charnames::string_vianame($char_name);
}

sub new {
    my ( $class, %params ) = @_;

    my ( $width, $height ) = @params{qw/width height/};
    # XXX detection
    # XXX rounding to nearest multiple of 2/4?

    my $grid = [ map { [ (0) x $width ] } ( 1 .. $height ) ];

    return bless {
        grid => $grid,
    }, $class;
}

sub _grid {
    my ( $self ) = @_;

    return $self->{'grid'};
}

sub _width {
    my ( $self ) = @_;

    return scalar(@{ $self->_grid->[0] });
}

sub _height {
    my ( $self ) = @_;

    return scalar(@{ $self->_grid });
}

sub set {
    my ( $self, $x, $y, $value );

    push @_, 1 if @_ == 3;
    ( $self, $x, $y, $value ) = @_;

    $self->_grid->[$y][$x] = $value ? 1 : 0;
}

sub _each_cell_row {
    my ( $self, $action ) = @_;

    for my $row_num (0 .. ($self->_height / $VERT_PIXELS_PER_CELL) - 1) {
        $action->($row_num);
    }
}

# $action is called with a sequence of $VERT_PIXELS_PER_CELL * $HORZ_PIXELS_PER_CELL
# values, going from left-to-right, top-to-bottom.
sub _each_cell_column {
    my ( $self, $row_num, $action ) = @_;

    my $grid = $self->_grid;
    for my $col_num (0 .. ($self->_width / $HORZ_PIXELS_PER_CELL) - 1) {
        my @values;

        for my $col_offset (0 .. $HORZ_PIXELS_PER_CELL - 1) {
            for my $row_offset (0 .. $VERT_PIXELS_PER_CELL - 1) {
                push @values, $grid->[$row_num * $VERT_PIXELS_PER_CELL + $row_offset][$col_num * $HORZ_PIXELS_PER_CELL + $col_offset];
            }
        }

        $action->(@values);
    }
}

sub as_string {
    my ( $self ) = @_;

    my $result = '';

    $self->_each_cell_row(sub {
        my ( $row_num ) = @_;

        $self->_each_cell_column($row_num, sub {
            my @values = @_;

            $result .= $BRAILLE_MAPPING{ join('', @values) };
        });

        $result .= "\n";
    });

    return $result;
}

1;

__END__

# ABSTRACT: Draw to your terminal using Braille characters

=head1 SYNOPSIS

  use Term::Drawille;

  my $canvas = Term::Drawille->new(
    width  => 400,
    height => 400,
  );

  print $canvas;

=head1 DESCRIPTION

=head1 METHODS

=head2 Term::Drawille->new(%params)

Creates a new canvas to draw on.

Valid key value pairs for C<%params> are:

=head3 width

Specify the width of the canvas in pixels.

=head3 height

Specify the height of the canvas in pixels.

=head2 $canvas->set($x, $y, [$value])

Sets the value of the pixel at (C<$x>, C<$y>) to C<$value>.  If
C<$value> is omitted, it defaults to C<1>.

XXX clarify what happens with different values

=head2 $canvas->as_string

Draws the canvas as a string of Braille characters and returns it.

XXX encoding

=head1 SEE ALSO

L<https://github.com/asciimoo/drawille>

=cut
