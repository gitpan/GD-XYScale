package GD::XYScale;
use strict;
use vars qw[$VERSION];

$VERSION = "1.01";

# The code actually starts here :)
package GD::Image;
use strict;
use vars qw[%ORIGIN];

# Defaults
%ORIGIN  = (DEFAULT => 50,    # Default coordinate of the origin.
            X       => undef, # X-Value of the origin
            Y       => undef, # Y-Value of the origin
            ZOOM    => undef, # Zoom value (as a key of this hash, because I do
                              # not want to add another global to this package)
            );

# Aliases/shortcuts
sub fix_point_to_origin   { shift->fixp2o(@_)         }
sub fix_value_x_to_origin { shift->fix_vx2o(@_)       }
sub fix_value_y_to_origin { shift->fix_vy2o(@_)       }
sub fix_vx2o              {(shift->fixp2o(shift,0))[0]}
sub fix_vy2o              {(shift->fixp2o(0,shift))[1]}

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
   my($width,$height) = $self->getBounds;
   my($ox,$oy) = $self->origin;
   return $self->zs($Px) + $ox, $height - ($self->zs($Py) + $oy);
}

sub zoom_scale {shift->zs(@_)}
sub zs {
   my $self = shift;
   my $num  = shift;
   my $zoom = $self->zoom_value || 1;
   return $num * $zoom;
}

sub zoom_value { $ORIGIN{ZOOM} }

sub origin {
   # Origin coordinates set/read
   my $self            = shift;
   my ($width,$height) = $self->getBounds;
   my($ox,$oy);
   if (@_ >= 2) {
      $ox = $ORIGIN{X}    = shift;
      $oy = $ORIGIN{Y}    = shift;
            $ORIGIN{ZOOM} = shift if @_;
   } else {
      if(defined $ORIGIN{X} and defined $ORIGIN{Y}) {
         return($ORIGIN{X},$ORIGIN{Y});
      }
      $ox = $oy = $ORIGIN{DEFAULT};
   }
   return $ox,$oy;
}

sub draw_xyscale {
   # $image->xyscale([LENGTH,COLOR])
   # Draws a 2D (x-y) scale
   my $self    = shift;
   my $length  = shift;
      $length  = 1 unless defined $length;   # length of the scale pipes
   my $color   = shift || $self->colorAllocate(255,200,185); # default is blue
   my($ox,$oy) = $self->origin;
   my ($width,$height) = $self->getBounds;
   my $zoom    = $self->zoom_value || 1;
   # create a x-y scale
   my $f = 10 * $zoom;
   my $last = $zoom >= 1 ? int($width/10)+1 : int($width/$zoom)+1;

      $self->line(0            , $height-$oy          , $width       , $height-$oy            , $color); # x
      $self->line($ox          , 0                    , $ox          , $height                , $color); # y
      $self->line($_*$f        , $height-($oy+$length), $_*$f        , $height-($oy - $length), $color) for (1..$last); # x
      $self->line($ox + $length, $_*$f                , $ox - $length, $_*$f                  , $color) for (1..$last); # y
}

sub name_xyscale {
   # $image->name_xyscale([UPWARDS,Y_NAME,X_NAME,COLOR,FONT,SHOW_ZOOM_STRING,ZOOM_STRING_COLOR]);
   my $self     = shift;
   my $up       = shift || '';
   my $xname    = shift || 'x scale';
   my $yname    = shift || 'y scale';
   my $color    = shift || $self->colorAllocate(0,0,255);
   my $font     = shift || GD::Font->Small;
   my $show_zs  = shift;
   my $zoom_col = shift || $color;
   my($ox,$oy)  = $self->origin;
   my ($width,$height) = $self->getBounds;
   # Font dimensions. We need these to write the text to the correct place
   my ($fw,$fh) = ($font->width,$font->height); 
   my $half     = int($fw/3);

   # X scale name
   $self->string($font, $width - (length($xname)+1)*$fw, $oy ? $height-($oy-$fh*.5) : $height - 4*$fh,$xname,$color);

   # Y scale name
   if ($up eq 'up') { 
      $self->stringUp($font, $ox ? $ox - $fh*1.5 : $half, (length($yname)+1)*$fw,$yname,$color);
   } else {
      my $xval = (length($yname)+1)*$fw;
         $xval = $ox ? ($xval > $ox ? $half : $xval) : $half;
      $self->string(  $font, $xval , $half,$yname,$color);
   }

   # If zoom ratio is not 1:1 and we want to see the zoom value...
   if($show_zs and $self->zoom_value and $self->zoom_value != 1){
      $show_zs = "Zoom: ".$self->zoom_value."x"; #.", Font: ${fw}x${fh}";
      $self->string($font, $width - (length($show_zs)+1)*$fw, 2,$show_zs,$zoom_col); 
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
   # continue using your GD image object.

   # put the origin at x=50, y=80 and zoom-out with .5
   $image->origin(50,80,.5); 
   $image->draw_xyscale(1.5,$image->colorAllocate(0,0,0));
   $image->name_xyscale('up','x scale','y scale',
                        $image->colorAllocate(0,0,255),
                        gdSmallFont,'show_zoom',
                        $image->colorAllocate(0,0,255));

   # draw some geomethric objects, curves, 
   # plot something... etc...

=head1 DESCRIPTION

This module adds some extra methods to the GD::Image class. 
Which means; this module I<extends> the GD interface to use 
a 2D scale. You can call these methods via your GD::Image 
object. It also adds C<%ORIGIN> class variable, 
accessible via C<%GD::Image::ORIGIN>.
However, you I<really> don't need to access this. It works 
transparently and you can use the object methods to modify/get
its value(s) (that means: don't touch/modify that global from 
your code).

=head1 METHODS

There are three main methods that you can use to control & 
draw the scale:

=head2 origin

Sets the origin to the point P(X,Y). And zoom in/out option 
of the graphic.

   $image->origin(POINT_X, POINT_Y, ZOOM);
   $image->origin(50, 218, .2);

You must set the origin coordinates before drawing the scale.
Or the origin will be at point C<(50,50)>. If your graphic/plot 
is too big, or too small, you can pass a C<ZOOM> parameter. All
the values will be multiplied with that zoom parameter, if you pass
it. For example; you can pass C<.2> to zoom-out and C<2> to zoom-in.

Note that, any other module that uses I<this> module, must use 
this module's origin and zoom values/calculations to get the correct 
result(s).

If you call this method without parameters, it returns the 
B<x> and B<y> values of the origin:

   ($ox,$oy) = $image->origin;

This may be necessary. And, if you want to put I<something>
on the scale (why do you use this module, if you dont't want to?)
you created, you have to B<fix> the point to the origin with
C<$ox,$oy> values and the dimension values you get with:

   ($width,$height) = $image->getBounds;

The module also uses these, to correct/fix the coordinates.

However, you can use the C<fix()> methods listed in the 
L</"fix() METHODS"> part to get the correct point values.

=head2 draw_xyscale

Draws the x-y scale with the scale pipes:

   $image->draw_xyscale(PIPE_HEIGHT,SCALE_COLOR);
   $image->draw_xyscale(1.5,$image->colorAllocate(255,200,185));

The so called I<pipes>' mediation is 10 pixels for each (with 1:1 
zoom ratio). Currently, you can not modify the behaviour of the 
I<pipes>, but you can set their heights. If you don't want to 
see them, just set the height to zero:

   $image->draw_xyscale(0,$image->colorAllocate(255,200,185));

None of the parameters are mandatory.

=head2 name_xyscale

Puts a name to X scale and Y scale. Also, you can select the Y-Scale name
to be horizontal or vertical. If the first parameter is set to "C<up>",
it'll be vertical. Second and third are the names of the X and Y scales 
respectively. Fourth parameter is the color of the scale names, fifth is the 
font of the scale names. If you set zoom to a value other than C<1> and 
pass a true value as the sixth parameter, you'll see the zoom ratio 
on the graphic's upper right corner. If you pass the last value, it'll be 
the color of the zoom text.

   $image->name_xyscale(UPWARDS,Y_NAME,X_NAME,COLOR,FONT,
                        SHOW_ZOOM_STRING,ZOOM_STRING_COLOR);
   $image->name_xyscale('up','X-Scale','Y-Scale',
                        $image->colorAllocate(255,0,0),
                        undef,'show_zoom',undef);

None of the parameters are mandatory.

=head2 fix() METHODS

The coordinate system of the scale is a little different
than the GD's coordinate system. Normally, the point (0,0) 
is at the upper left corner of the image, while this module's 
scale puts the origin to the lower left. So, if you set 
origin to (0,0), the point (0,0) will be at the lower corner of 
the left side. To display the B<correct> points on the x-y
scale, we need to fix/correct them to the origin of the scale.
You may do that manually yourself, with the help of GD's standard 
C<getBounds()> method and this module's origin() method, but
this module also has several methods to use on this job.

=head3 fixp2o()

Will I<fix> the C<X> and C<Y> values of a point.
I<Long> alias is: C<fix_point_to_origin()>

   $image->fixp2o(X, Y);
   $image->fixp2o(15, 56);

So, if you want to draw a line:

   $image->line($image->fixp2o(15, 56),
                $image->fixp2o(44, 365),
                $image->colorAllocate(255,0,0));

=head3 fix_vx2o()

Will I<fix> the C<X> value of a point.
I<Long> alias is: C<fix_value_x_to_origin()>

   $image->fix_vx2o(X);

=head3 fix_vy2o()

Will I<fix> the C<Y> value of a point.
I<Long> alias is: C<fix_value_y_to_origin()>

   $image->fix_vy2o(Y);

So, if you want to draw a line:

   $image->line($image->fix_vx2o(30),  $image->fix_vy2o(30),
                $image->fix_vx2o(100), $image->fix_vy2o(150),
                $image->colorAllocate(0,0,0));

=head3 zs()

Alias: C<zoom_scale()>

Re-calculates the numbers to match the current zoom value. You have 
to fix the C<X> and C<Y> values seperately with this method.

=head3 zoom_value()

Returns the current zoom value. Does not accept any arguments and 
you can not I<set> zoom value with this  method.

=head1 EXAMPLES

See the tests in C<./t> directory in the distribution. Download 
the distribution from CPAN, if you don't have the files on your 
computer.

=head1 TODO

=over 4

=item *

More control on the I<pipes>.

=item *

Add some (all?) of the values of the formulas (to the X and Y 
scale lines) used to draw lines, curves, shapes etc... 
(Maybe -- I think that you can do this yourself :))

=back

=head1 BUGS

Contact the author, if you find any.

=head1 SEE ALSO

L<GD>

=head1 AUTHOR

Burak Gürsoy, E<lt>burakE<64>cpan.orgE<gt>

=head1 COPYRIGHT

Copyright 2003 Burak Gürsoy. All rights reserved.

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself. 

=cut
