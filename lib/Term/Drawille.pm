package Term::Drawille;

use strict;use warnings;
use utf8;
use open ":std", ":encoding(UTF-8)";
use integer;
use Algorithm::Line::Bresenham;

sub new{
    my ( $class, %params ) = @_;     #  params are width and height in pixels
    my $self={width=>$params{width},height=>$params{height}};
                                     # grid of blank braille characters made of the size specified
    $self->{grid}=[map {[('⠀')x ($params{width}/2+($params{width}%2?1:0))]}(0..($params{height}/4+($params{height}%4?1:0)))];
                  # arrays containing Braille characters to bitwise OR or AND to set or unset individual pixels
    $self->{setPix}=[['⡀','⠄','⠂','⠁'],['⢀','⠠','⠐','⠈']];
    $self->{unsetPix}=[['⢿','⣻','⣽','⣾'],['⡿','⣟','⣯','⣷']];
    bless $self,$class;
    return $self;
}

sub draw{
	my $self=shift;
	print $self->as_string();
}


sub as_string{
	my $self=shift;
	my $str="";
	$str.=join("",@$_)."\n" foreach (reverse @{$self->{grid}});
	return $str;
}

sub set{
    push @_, 1 if @_ == 3;
	my ($self,$x,$y,$value)=@_;
	
	#exit if out of bounds
	return unless(($x<$self->{width})&&($x>=0)&&($y<$self->{height})&&($x>=0));
	
	#convert coordinates to character / pixel offset position
	my $chrX=$x/2;my $xOffset=$x- $chrX*2; (
	my $chrY=$y/4;my $yOffset=$y- $chrY*4;
	$self->{grid}->[$chrY]->[$chrX]=$value?         # in $value is false, unset, or else set pixel
	   chr( ord($self->{setPix}  -> [$xOffset]->[$yOffset]) | ord($self->{grid}->[$chrY]->[$chrX]) ) :
	   chr( ord($self->{unsetPix}-> [$xOffset]->[$yOffset]) & ord($self->{grid}->[$chrY]->[$chrX])
	);
}

sub unset{
	my ($self,$point)=@_;
	$self->set($point,0);
}

sub pixel{
	
	
}

sub line{
	my ($self,$x1,$y1,$x2,$y2,$value)=@_;
	my @points=Algorithm::Line::Bresenham::line($x1,$y1,$x2,$y2);
	$self->set(@$_) foreach (@points);
}

sub circle{
	my ($self,$x1,$y1,$radius,$value)=@_;
	my @points=Algorithm::Line::Bresenham::circle($x1,$y1,$radius);
	$self->set(@$_,$value) foreach (@points);
}

1;


__END__

# ABSTRACT: Draw to your terminal using Braille characters

=head1 SYNOPSIS

  use Term::Drawille;

  binmode STDOUT, ':encoding(utf8)';
  my $canvas = Term::Drawille->new(
    width  => 400,
    height => 400,
  );

  for(my $i = 0; $i < 400; $i++) {
    $canvas->set($i, $i, 1);
  }

  $canvas->draw();

=head1 DESCRIPTION

L<Text::Drawille> makes use of Braille characters to allow you to draw
lines, circles, pictures, etc, to your terminal with a surprising amount
of precision.  It's inspired by a  Python library (L<https://github.com/asciimoo/drawille>);
its page has some screenshots that demonstrate what it and this module can accomplish.

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
C<$value> is omitted, it defaults to C<1>. The $value is interpreted
as a boolean: whether or not to draw the pixel at the given position.

=head2 $canvas->unset($x, $y)

unSets the value of the pixel at (C<$x>, C<$y>).  uses the function
above passing $value as 0.

=head2 $canvas->as_string

Draws the canvas as a string of Braille characters and returns it.
Note that the string consists of Unicode B<characters> and not raw bytes;
this means you'll likely have to encode it before sending it to the terminal.
This may change in future releases.

=head2 $canvas->draw

Draws directly to console. UTF8  Encoding is already handled by
the module so not required.





=head1 SEE ALSO

L<https://github.com/asciimoo/drawille>

=cut
