package GD::XYScale;
use strict;
use vars qw[$VERSION];

$VERSION = "1.2";

sub new {
   my $class = shift;
   $_[0] and ref $_[0] eq 'GD::Image' or die "I need a GD::Image object to operate!";
   my $self  = { 
                'GD::Image' => undef, # The GD::Image object
                DEFAULT     => 50,    # Default coordinate of the origin.
                OX          => undef, # X-Value of the origin
                OY          => undef, # Y-Value of the origin
                ZOOM        => undef, # Zoom value (as a key of this hash, because I do
                                      # not want to add another global to this package)
   };
   bless $self, $class;
   $self->{'GD::Image'} = shift;
   return $self;
}

# Aliases
sub fix_point_to_origin   { shift->fixp2o(@_)          }
sub fix_value_x_to_origin { shift->fix_vx2o(@_)        }
sub fix_value_y_to_origin { shift->fix_vy2o(@_)        }
sub zoom_scale            { shift->zs(@_)              }
sub draw_xyscale          { shift->draw(@_)            }
sub name_xyscale          { shift->name(@_)            }

# Shortcuts
sub fix_vx2o              {(shift->fixp2o(shift,0))[0] }
sub fix_vy2o              {(shift->fixp2o(0,shift))[1] }

# Main method for fixing points.
sub fixp2o {
   my $self = shift;
   my $Px   = shift;
   my $Py   = shift;
   unless(defined $Px and defined $Py) {
      my $error = "You must pass the x and y value of the point to ";
      if (my $sub = (caller 1)[3]) {
         $error  = ($sub =~ m,_v(x|y),i) ? "You must pass the $1 value to $sub()" : $error.$sub.'()';
      } else {
         $error .= ref($self).'::fixp2o()';
      }
      die $error;
   }
   my($width,$height) = $self->{'GD::Image'}->getBounds;
   my($ox,$oy) = $self->origin;
   return $self->zs($Px) + $ox, $height - ($self->zs($Py) + $oy);
}

sub zoom_value { shift->{ZOOM} }

sub zs {
   my $self = shift;
   my $num  = shift;
   my $zoom = $self->zoom_value || 1;
   return $num * $zoom;
}

sub origin {
   # Origin coordinates set/read
   my $self = shift;
   my ($width,$height) = $self->{'GD::Image'}->getBounds;
   my($ox,$oy);
   if (@_ >= 2) {
      $ox = $self->{OX}   = shift;
      $oy = $self->{OY}   = shift;
            $self->{ZOOM} = shift if @_;
   } else {
      if(defined $self->{OX} and defined $self->{OY}) {
         return($self->{OX},$self->{OY});
      }
      $ox = $oy = $self->{DEFAULT};
   }
   return $ox,$oy;
}

sub draw {
   # $image->draw(PIPE_LENGTH,SCALE_COLOR)
   # $image->draw([PIPE_LENGTH,PIPE_WIDTH,PIPE_COLOR],SCALE_COLOR)
   # Draws a 2D (x-y) scale
   my $self    = shift;
   my $length  = shift;
      $length  = 1 unless defined $length;   # length of the scale pipes
   my $color   = shift || $self->{'GD::Image'}->colorAllocate(255,200,185); # default is blue
   my($ox,$oy) = $self->origin;
   my ($width,$height) = $self->{'GD::Image'}->getBounds;
   my $zoom    = $self->zoom_value || 1;
   my $pipe_width = 10;
   my $pipe_color = $color;

   # OK... We want an array ref with at least 3 elements in it
   # for an extended interface to the pipes:
   if (ref($length) and ref($length) eq 'ARRAY' and $#{$length} >= 2) {
      $pipe_width = $length->[1] if $length->[1]; # override the default value "10"
      $pipe_color = $length->[2] if $length->[2]; # override scale's base color
      $length     = $length->[0] || 1; # Finally, convert arrayref to a numeric value :]
   }

   # Calculate the factor and last number of the pipes.
   my $f    = $pipe_width * $zoom;
   my $last = $zoom >= 1 ? int($width/$pipe_width)+1 : int($width/$zoom)+1;

   # draw these things I call "pipes" :)
   $self->{'GD::Image'}->line($_*$f        , $height-($oy+$length), $_*$f        , $height-($oy - $length), $pipe_color) for (1..$last); # x
   $self->{'GD::Image'}->line($ox + $length, $_*$f                , $ox - $length, $_*$f                  , $pipe_color) for (1..$last); # y

   # And finally, create a x-y scale
   $self->{'GD::Image'}->line(0  , $height-$oy, $width, $height-$oy, $color); # x
   $self->{'GD::Image'}->line($ox, 0          , $ox   , $height    , $color); # y
}

sub name {
   # $image->name(UPWARDS,Y_NAME,X_NAME,COLOR,FONT,SHOW_ZOOM_STRING,ZOOM_STRING_COLOR);
   my $self     = shift;
   my $up       = shift || '';
   my $xname    = shift || 'x scale';
   my $yname    = shift || 'y scale';
   my $color    = shift || $self->{'GD::Image'}->colorAllocate(0,0,255);
   my $font     = shift || GD::Font->Small;
   my $show_zs  = shift;
   my $zoom_col = shift || $color;
   my($ox,$oy)  = $self->origin;
   my ($width,$height) = $self->{'GD::Image'}->getBounds;

   # Font dimensions. We need these to write the text to the correct place
   my ($fw,$fh) = ($font->width,$font->height); 
   my $half     = int($fw/3);

   # X scale name
   $self->{'GD::Image'}->string($font, $width - (length($xname)+1)*$fw, $oy ? $height-($oy-$fh*.5) : $height - 2*$fh,$xname,$color);

   # Y scale name
   if ($up eq 'up') { 
      $self->{'GD::Image'}->stringUp($font, $ox ? $ox - $fh*1.5 : $half, (length($yname)+1)*$fw,$yname,$color);
   } else {
      my $xval = (length($yname)+1)*$fw;
         $xval = $ox ? ($xval > $ox ? $half : $xval) : $half;
      $self->{'GD::Image'}->string(  $font, $xval , $half,$yname,$color);
   }

   # If zoom ratio is not 1:1 and we want to see the zoom value...
   if($show_zs and $self->zoom_value and $self->zoom_value != 1){
      $show_zs = "Zoom: ".$self->zoom_value."x"; #.", Font: ${fw}x${fh}";
      $self->{'GD::Image'}->string($font, $width - (length($show_zs)+1)*$fw, 2,$show_zs,$zoom_col); 
   }
}

1;

__END__;

=head1 NAME

GD::XYScale - Draw a 2D X-Y scale and use it.

=head1 SYNOPSIS

   use GD;
   use GD::XYScale;

   $image = GD::Image->new($width,$height);
   $white = $image->colorAllocate(255,255,255);
   $black = $image->colorAllocate(0,0,0);
   $blue  = $image->colorAllocate(0,0,255);
   # continue using your GD image object.

   $scale = GD::XYScale->new($image);

   # put the origin at x=50, y=80 and zoom-out with .5
   $scale->origin(50,80,.5); 
   $scale->draw(1.5,$black);
   $scale->name('up',
                'x scale',
                'y scale',
                $blue,
                gdSmallFont,
                'show_zoom',
                $blue);

   # draw some geomethric objects, curves, 
   # plot something... etc...

=head1 DESCRIPTION

This module adds a 2D scale to your GD image. It needs a C<GD::Image>
object to work. 

First versions were modifying C<GD::Image> namespace and I then 
realized that this is not a good thing. In this version and future 
versions, the module will use it's own namespace, so check your codes 
if you tried this module before version C<1.2>

=head1 METHODS

There are three main methods that you can use to control & 
draw the scale:

=head2 origin

Sets the origin to the point P(X,Y). And zoom in/out option 
of the graphic.

   $scale->origin(POINT_X, POINT_Y, ZOOM);
   $scale->origin(50, 218, .2);

You must set the origin coordinates before drawing the scale.
Or the origin will be at point C<(50,50)>. If your graphic/plot 
is too big, or too small, you can pass a C<ZOOM> parameter. All
the values will be multiplied with that zoom parameter, if you pass
it. For example; you can pass C<.2> to zoom-out and C<2> to zoom-in.

Note that, any other module/code that uses I<this> module, must use 
this module's origin and zoom values/calculations to get the correct 
result(s).

If you call this method without parameters, it returns the 
B<x> and B<y> values of the origin:

   ($ox,$oy) = $scale->origin;

This may be necessary. And, if you want to put I<something>
on the scale (why do you use this module, if you dont't want to?)
you created, you have to B<fix> the point to the origin with
C<$ox,$oy> values and the dimension values you get with:

   ($width,$height) = $image->getBounds;

The module also uses these, to correct/fix the coordinates.

However, you can use the C<fix()> methods listed in the 
L</"fix() METHODS"> part to get the correct point values.

=head2 draw

Draws the x-y scale with the scale pipes:

   $scale->draw(PIPE_HEIGHT,SCALE_COLOR);

   $scale->draw(1.5,$pink);

The so called I<pipes>' mediation is 10 pixels for each (with 1:1 
zoom ratio). If you don't want to see them, just set the height to zero:

   $scale->draw(0,$pink);

Also, there is an extended interface. If you pass an array reference
as the first parameter, you can control all the behaviour of the pipes:

   $scale->draw([PIPE_LENGTH,PIPE_WIDTH,PIPE_COLOR],SCALE_COLOR);

   $scale->draw([800,50,$gray],$black);

None of the parameters are mandatory. Alias is C<draw_xyscale>.

=head2 name

Puts a name to X scale and Y scale. Also, you can select the Y-Scale name
to be horizontal or vertical. If the first parameter is set to "C<up>",
it'll be vertical. Second and third are the names of the X and Y scales 
respectively. Fourth parameter is the color of the scale names, fifth is the 
font of the scale names. If you set zoom to a value other than C<1> and 
pass a true value as the sixth parameter, you'll see the zoom ratio 
on the graphic's upper right corner. If you pass the last value, it'll be 
the color of the zoom text.

   $scale->name(UPWARDS, Y_NAME, X_NAME, COLOR, FONT, SHOW_ZOOM_STRING,
                ZOOM_STRING_COLOR);

   $scale->name('up', 'X-Scale', 'Y-Scale', $red, undef, 'show_zoom', undef);

None of the parameters are mandatory. Alias is C<name_xyscale>.

=head2 fix() METHODS

The coordinate system of the scale is a little different than the GD's 
coordinate system. Normally, the point (0,0) is at the upper left corner 
of the image, while this module's scale puts the origin to the lower left. 
So, if you set origin' s coordinate to (0,0), the point (0,0) will be at 
the lower corner of the left side. To display the B<correct> points on 
the x-y scale, we need to fix/correct them to the origin of the scale. 
You may do that manually yourself, with the help of GD's standard 
C<getBounds()> method and this module's C<origin()> method, but this module 
also has several methods to use on this job.

=head3 fixp2o()

Will I<fix> the C<X> and C<Y> values of a point.
I<Long> alias is: C<fix_point_to_origin()>

   $scale->fixp2o(X, Y);

   $scale->fixp2o(15, 56);

So, if you want to draw a line:

   $image->line($scale->fixp2o(15, 56),
                $scale->fixp2o(44, 365),
                $blue);

=head3 fix_vx2o()

Will I<fix> the C<X> value of a point.
I<Long> alias is: C<fix_value_x_to_origin()>

   $scale->fix_vx2o(X);

=head3 fix_vy2o()

Will I<fix> the C<Y> value of a point.
I<Long> alias is: C<fix_value_y_to_origin()>

   $scale->fix_vy2o(Y);

So, if you want to draw a line:

   $scale->line($scale->fix_vx2o(30),  $scale->fix_vy2o(30),
                $scale->fix_vx2o(100), $scale->fix_vy2o(150),
                $black);

=head3 zs()

Alias: C<zoom_scale()>

Re-calculates the numbers to match the current zoom value. You have 
to fix the C<X> and C<Y> values seperately with this method.

   $image->arc($scale->fix_vx2o(124),
               $scale->fix_vy2o(0),
               $scale->zs(78),
               $scale->zs(78),
               180,
               0,
               $black);

=head3 zoom_value()

Returns the current zoom value. Does not accept any arguments and 
you can not I<set> zoom value with this  method. 

=head1 EXAMPLES

See the tests in C<./t> directory in the distribution. Download 
the distribution from CPAN, if you don't have the files on your 
computer.

=head1 BUGS

Contact the author, if you find any. If you have suggestions for 
this module, you can also send them to the author.

=head1 SEE ALSO

L<GD>.

=head1 AUTHOR

Burak Gürsoy, E<lt>burakE<64>cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2003 Burak Gürsoy. All rights reserved.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
