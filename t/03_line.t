#!/usr/bin/env perl -w
# Draw lines and fix points.
use strict;
use Test;
BEGIN { plan tests => 1 }

use GD;
use GD::XYScale;
my $image = GD::Image->new(800,600) or die "I can not create an image!";
my $scale = GD::XYScale->new($image);
my $white = $image->colorAllocate(255,255,255); # set background
my $black = $image->colorAllocate(0,0,0);
my $red   = $image->colorAllocate(255,0,0);
my $some_color = $image->colorAllocate(100,60,220);

   $scale->origin(400,300);
   $scale->draw(1.5 ,$image->colorAllocate(0,0,255));
   $scale->name('up','X-Scale','Y-Scale',$red,undef,'show_zoom');

   # The point values (X,Y) needs to be fixed, to display 
   # them corrrectly on the scale.
   # Fix points (X and Y)
   $image->line($scale->fixp2o(15, 56),$scale->fixp2o(44, 365),$red);
   $image->line($scale->fixp2o(15,-56),$scale->fixp2o(44,-365),$red);

   # Fix them individually. Separate fix methods for X and for Y values.
   $image->line($scale->fix_vx2o(30),  $scale->fix_vy2o(30),
                $scale->fix_vx2o(100), $scale->fix_vy2o(150),
                $black);

   # The methods fixp2o(),fix_vx2o() and fix_vy2o()
   # also have "long" aliases:
   # fixp2o()   alias is fix_point_to_origin()
   # fix_vx2o() alias is fix_value_x_to_origin()
   # fix_vy2o() alias is fix_value_y_to_origin()
   # However, I suggest using the original "short" ones...
   # Usage of aliases
   $image->line($scale->fix_point_to_origin(15, 56),
                $scale->fix_point_to_origin(44, 365),
                $red);

   $image->line($scale->fix_value_x_to_origin(10),  $scale->fix_value_y_to_origin(55),
                $scale->fix_value_x_to_origin(256), $scale->fix_value_y_to_origin(189.56),
                $some_color);

   # The last one's coordinates will be wrong
   $image->line(10,55, 256,189.56, $some_color);

chdir;

my $type = $image->can('gif') ? 'gif' : 'png';

open IMAGE, "> 03_line.$type" or die $!;
binmode IMAGE;
print IMAGE $image->$type();

ok(1);

exit;

__END__
