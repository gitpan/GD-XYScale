#!/usr/bin/env perl -w
# Draw circle and fix points
use strict;
use Test;
BEGIN { plan tests => 1 }

use GD;
use GD::XYScale;
use GD::Polyline;

my $image = GD::Image->new(800,600) or die "I can not create an image!";
my $scale = GD::XYScale->new($image);
my $white = $image->colorAllocate(255,255,255); # set background
my $black = $image->colorAllocate(0,0,0);
my $red   = $image->colorAllocate(255,0,0);
my $some_color = $image->colorAllocate(100,60,220);

   $scale->origin(75,89.4,3.2);
   $scale->draw(1.5 ,$image->colorAllocate(0,0,255));
   $scale->name('up',"sigma","tau",$image->colorAllocate(255,0,0),undef,'show_zoom');

   $image->arc($scale->fix_vx2o(124),
               $scale->fix_vy2o(0),
               $scale->zs(78),
               $scale->zs(78),
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
