#!/usr/bin/env perl -w
# Simple test. Just draw the scale.
use strict;
use Test;
BEGIN { plan tests => 1 }

use GD;
use GD::XYScale;
my $image = GD::Image->new(400,300) or die "I can not create an image!";
my $white = $image->colorAllocate(255,255,255); # set background

   $image->origin(200,150);
   $image->draw_xyscale(1.5 ,$image->colorAllocate(0,0,255));
   $image->name_xyscale('up','X-Scale','Y-Scale',$image->colorAllocate(255,0,0),undef,'show_zoom');

chdir;

my $type = $image->can('gif') ? 'gif' : 'png';

open IMAGE, "> 02_simple.$type" or die $!;
binmode IMAGE;
print IMAGE $image->$type();

ok(1);

exit;

__END__
