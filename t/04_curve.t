#!/usr/bin/env perl -w
# Draw curves and fix points
use strict;
use Test;
BEGIN { plan tests => 1 }

use GD;
use GD::XYScale;
use GD::Polyline;
use Math::Trig;

my $image = GD::Image->new(800,600) or die "I can not create an image!";
my $scale = GD::XYScale->new($image);
my $white = $image->colorAllocate(255,255,255); # set background
my $black = $image->colorAllocate(0,0,0);
my $red   = $image->colorAllocate(255,0,0);
my $some_color = $image->colorAllocate(100,60,220);

   $scale->origin(400,200,.8);
   $scale->draw(1.5 ,$image->colorAllocate(0,0,255));
   $scale->name('up',"This is the 'X' scale","HEY! This is the 'Y' scale",$image->colorAllocate(255,0,0),undef,'show_zoom');

# Some curves for testing... I dont have if the last one has any meaning :)
curve([  0..16 ]    ,sub{ $_, $_**2                }, $red  ); #  y =  x**2
curve([  0..16 ]    ,sub{ $_,-$_**2                }, $red  ); #  y = -x**2
curve([-16..0  ]    ,sub{ $_, $_**2                }, $red  ); # -y =  x**2
curve([-16..0  ]    ,sub{ $_,-$_**2                }, $red  ); # -y = -x**2
curve([  1..100]    ,sub{ $_, sqrt($_)             }, $black); #  y = x**1/2
curve([0,90,270,360],sub{ $_, sin(deg2rad($_))*100 }, $black); #  y = sin(x)*100

sub curve {
   my $array = shift;
   my $func  = shift;
   my $color = shift || $red;
   my $p = GD::Polyline->new;
   foreach (@{$array}) {
      $p->addPt($scale->fixp2o($func->()) );
   }
   $image->polydraw($p->addControlPoints->toSpline,$color);
   undef $p;
}

chdir;

my $type = $image->can('gif') ? 'gif' : 'png';

open IMAGE, "> 04_curve.$type" or die $!;
binmode IMAGE;
print IMAGE $image->$type();

ok(1);

exit;

__END__
