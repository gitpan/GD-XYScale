#!/usr/bin/env perl -w
# Use "long" pipes to give an effect.
use strict;
use Test;
BEGIN { plan tests => 1 }

use GD;
use GD::XYScale;
use GD::Polyline;
use Math::Trig;

my($width,$height) = (700,500);

my $image = GD::Image->new($width,$height) or die "I can not create an image!";
my $white = $image->colorAllocate(255,255,255); # set background
my $black = $image->colorAllocate(  0,  0,  0);
my $red   = $image->colorAllocate(255,  0,  0);
my $blue  = $image->colorAllocate(  0,  0,255);
my $green = $image->colorAllocate(  0,255,  0);
my $gray  = $image->colorAllocate(222,222,222);

   $image->origin(100,150,1);
   $image->draw_xyscale([800,50,$gray], $black);
   $image->name_xyscale('up','X-Scale','Y-Scale',$image->colorAllocate(255,0,0),undef,'show_zoom');

   # Put a black frame around it:
   $image->rectangle(0,0,$width-1,$height-1,$black);

curve([  0..16 ]    ,sub{ $_, $_**2               }, $blue ); #  y =  x**2
curve([  1..100]    ,sub{ $_, sqrt($_)            }, $black); #  y = x**1/2
curve([0,90,270,360],sub{ $_, sin(deg2rad $_)*100 }, $black); #  y = sin(x)*100

   $image->line($image->fixp2o(0,0),$image->fixp2o(250,250),$red);

sub curve {
   my $array = shift;
   my $func  = shift;
   my $color = shift || $red;
   my $p = GD::Polyline->new;
   foreach (@{$array}) {
      $p->addPt($image->fixp2o($func->()) );
   }
   $image->polydraw($p->addControlPoints->toSpline,$color);
   undef $p;
}

chdir;

my $type = $image->can('gif') ? 'gif' : 'png';

open IMAGE, "> 07_xpipes.$type" or die $!;
binmode IMAGE;
print IMAGE $image->$type();

ok(1);

exit;

__END__
