#!/usr/bin/env perl -w
# Draw circle and fix points
use strict;
use Test;
BEGIN { plan tests => 1 }

use GD;
use GD::XYScale;
use GD::Polyline;

my $image = GD::Image->new(800,600) or die "I can not create an image!";
my $white = $image->colorAllocate(255,255,255); # set background
my $black = $image->colorAllocate(0,0,0);
my $red   = $image->colorAllocate(255,0,0);
my $some_color = $image->colorAllocate(100,60,220);

   $image->origin(75,89.4,3.2);
   $image->draw_xyscale(1.5 ,$image->colorAllocate(0,0,255));
   $image->name_xyscale('up',"sigma","tau",$image->colorAllocate(255,0,0),undef,'show_zoom');

   $image->arc($image->fix_vx2o(124),
               $image->fix_vy2o(0),
               $image->zs(78),
               $image->zs(78),
               180,
               0,
               $black);

chdir;

my $type = $image->can('gif') ? 'gif' : 'png';

open IMAGE, "> 05_circle.$type" or die $!;
binmode IMAGE;
print IMAGE $image->$type();

ok(1);

exit;

__END__
