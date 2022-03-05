// CSG.scad - Basic example of CSG usage


//    difference() {
//        cube([100, 100, 70]);
//        translate([2,2,2]) {
//            cube([96, 96, 66]);
//        }
//    }

wall_thickness = 1.4;

width = 110;
depth = 102 + wall_thickness*2;
card_depth = 80;
height = 80;
shelf_height = 15;

btn1_pos = 47 + wall_thickness;
btn2_pos = 58 + wall_thickness;

led1_pos = 26 + wall_thickness;

cyl_precision = 32;


module hexagonal_grid(box, holediameter, wallthickness){
    difference(){
        cube(box, center = true);
        hexgrid(box, holediameter, wallthickness + 0.001);
    }
}

module hex_hole(hexdiameter, height){
        translate([0, 0, 0]) rotate([0, 0, 0]) cylinder(d = hexdiameter, h = height + 0.001, center = true, $fn = 6);
}

module hexgrid(box, hexagon_diameter, hexagon_thickness) {
    a = (hexagon_diameter + hexagon_thickness)*sin(60);
    cos60 = cos(60);
    sin60 = sin(60);
    moduloX = (box[0] % hexagon_diameter);
    numX = (box[0] - moduloX) / hexagon_diameter;
    moduloY = (box[1] % hexagon_diameter);
    numY = (box[1] - moduloY) / hexagon_diameter;
    x0 = (numX + 2) * (hexagon_diameter + hexagon_thickness)/2;
    y0 = (numY + 2) * (hexagon_diameter + hexagon_thickness)*sqrt(3)/2/2;

    for(x = [-x0: 2*a*sin60: x0]) {
        for(y = [-y0 : a: y0]) {
            translate([x, y, 0]) hex_hole(hexdiameter = hexagon_diameter, height = box[2]);
           translate([x + a*sin60, y + a*cos60 , 0]) hex_hole(hexdiameter = hexagon_diameter, height = box[2]);
        }
    }
}

// first arg is vector that defines the bounding box, length, width, height
// second arg in the 'diameter' of the holes. In OpenScad, this refers to the corner-to-corner diameter, not flat-to-flat
// this diameter is 2/sqrt(3) times larger than flat to flat
// third arg is wall thickness.  This also is measured that the corners, not the flats. 



module shape() {
    translate([0,0,wall_thickness]) {
        difference() {
            

            rotate([90, 0, 0]) {
                linear_extrude(width) {
                    polygon(points=[[0,0],[depth,0],[depth,shelf_height],[card_depth+8,shelf_height+3], [card_depth+6, height], [0,height]]);
                }
            }

            translate([0,-wall_thickness, 0]) {
                rotate([90, 0, 0]) {
                    linear_extrude(width-wall_thickness*2) {
                        
                        polygon(points=[[wall_thickness,-10],[depth - wall_thickness,0],[depth-wall_thickness,shelf_height-wall_thickness],[card_depth+8 - wall_thickness,shelf_height+3-wall_thickness], [card_depth+6 - wall_thickness, height-wall_thickness], [wall_thickness,height-wall_thickness]]);
                    }
                }
            }
        }
    }
}

module back_hole() {
    translate([-50, -width+4, 12]) {
        cube([depth, width-8, height - 8*2]);
    }
}

module btm() {
    difference() {
        difference() {
            shape();
            translate([-20, -width *1.5, shelf_height*2]){ 
                cube(width * 2);
            }
        }
        translate([0, -width, shelf_height * 2-5]) {
            difference() {
                translate([-10, -10, 0]) {
                    
                cube([card_depth*2, width*2, 20]);
                }
                translate([wall_thickness/2,wall_thickness/2,-10]) {
                    cube([card_depth+7.5-wall_thickness, width-wall_thickness, 40]);
                }
            }
        }
    }
}

module screw_hole(pos) {
    translate([pos[0], pos[1], 0.2]) {
        cylinder(20, 1.5, 1.5, $fn=cyl_precision);
    }
}

module screw(pos) {

    difference() {
        translate([pos[0], pos[1], 0]) {
            cylinder(5, 4, 4, $fn=cyl_precision);
        }
        screw_hole(pos);
    }

}

module usb(){
    hull(){
        translate([85, -width+10, 6]){
            rotate([90, 0, 0]){
                cylinder(20, 1, 1, $fn=cyl_precision);
            }
        }

        translate([95, -width+10, 6]){
            rotate([90, 0, 0]){
                cylinder(20, 1, 1, $fn=cyl_precision);
            }
        }

        translate([85, -width+10, 11]){
            rotate([90, 0, 0]){
                cylinder(20, 1, 1, $fn=cyl_precision);
            }
        }

        translate([95, -width+10, 11]){
            rotate([90, 0, 0]){
                cylinder(20, 1, 1, $fn=cyl_precision);
            }
        }
    }
}


module plate() {
    
    translate([0, -width, 0]) {
        difference() {
            union(){
                cube([depth,width, wall_thickness]);
                screw([wall_thickness + 4.8, wall_thickness + 11.8]);
                screw([wall_thickness + 4.8, wall_thickness + 87.7]);
                screw([wall_thickness + 97, wall_thickness + 5]);
                screw([wall_thickness + 85, wall_thickness + 98]);
                difference() {
                    translate([wall_thickness/2, wall_thickness/2, 0]) {
                        cube([depth - wall_thickness,width - wall_thickness, wall_thickness+5]);
                    }
                    translate([wall_thickness, wall_thickness, -5]) {
                        cube([depth - wall_thickness*2,width - wall_thickness*2, wall_thickness+15]);
                    }
                }
            }
            union(){
                translate([0, width, 0]) {
                    usb();
                }
                screw_hole([wall_thickness + 4.8, wall_thickness + 11.8]);
                screw_hole([wall_thickness + 4.8, wall_thickness + 87.7]);
                screw_hole([wall_thickness + 97, wall_thickness + 5]);
                screw_hole([wall_thickness + 85, wall_thickness + 98]);
            }
        }
        
    }
}

module bottom_shape() {
    union() {
        button(btn1_pos);
        button(btn2_pos);
        difference(){
            btm();
            union() {
                usb();
                back_hole();
                translate([wall_thickness/2, -width+wall_thickness/2, wall_thickness]) { 
                    cube([depth-wall_thickness, width-wall_thickness, 5]);
                }
                button_hole(btn1_pos);
                button_hole(btn2_pos);
                translate([depth-13, -width+led1_pos, shelf_height]) {
                    cylinder(50, 2, 2, $fn=cyl_precision);
                }
                
                translate([40, 0, 5]) {
                    difference() {
                        rotate([90, 90, 0]) {
                            hexgrid([1,30,20], 10, 3);
                        }
                        translate([-50, -50, -16]) {
                            cube([100, 100, 20]);
                        }
                    }
                }
                translate([40, -width, 5]) {
                    difference() {
                        rotate([90, 90, 0]) {
                            hexgrid([1,30,20], 10, 3);
                        }
                        translate([-50, -50, -16]) {
                            cube([100, 100, 20]);
                        }
                    }
                }
            }
        }
    }


}



module led(pos) {
    translate([card_depth, -width + pos, shelf_height*2 + 5]) {
        rotate([0, 90, 0]) {
            cylinder(20, 2.5, 2.5, $fn=cyl_precision);
        }
    }
}

module top_shape() {
    difference() {
        difference() {
            shape();
            translate([-10, -width *1.5, -width * 2+shelf_height*2-5]){ 
                cube(width * 2);
            }
        }
        union() {
            led(40);
            led(48);
            led(56);
            led(64);
            translate([0, -width, shelf_height * 2-10]) {
                translate([wall_thickness/2,wall_thickness/2,-10]) {
                    cube([card_depth+7.5-wall_thickness, width-wall_thickness, 20]);
                
                }
            }
            back_hole();
            difference() {
                rotate([90, 60, 0]) {
                    translate([0, 50, 0]) {
                        hexgrid([50,50,5], 6, 3);
                    }
                }
            
                union() {
                    translate([0, -width, 0]) {
                        cube([300, 300, shelf_height * 2 +7]);
                    }
                    translate([0, -width, height -5]) {
                        cube([300, 300, 50]);
                    }
                    translate([-depth+8, -width, 0]) {
                        cube([depth, width, height]);
                    }
                }
            }
            translate([0, -width, 0]) {
                difference() {
                    rotate([90, 60, 0]) {
                        translate([0, 50, 0]) {
                            hexgrid([50,50,5], 6, 3);
                        }
                    }
                
                    union() {
                        translate([0, 0, 0]) {
                            cube([300, 300, shelf_height * 2 +7]);
                        }
                        translate([0, 0, height -5]) {
                            cube([300, 300, 50]);
                        }
                        translate([-depth+8, 0, 0]) {
                            cube([depth, width, height]);
                        }
                    }
                }
            }
        }
    
    }
}


module button_hole(pos) {
    translate([depth - 7 - wall_thickness, -width+pos, shelf_height-5]) {
        translate([0,0,-15]) {
            cylinder(30, 3, 3);
        }
    }
}


module button(pos) {
    translate([depth - 7 - wall_thickness, -width+pos, shelf_height]) {
        union() {
            translate([0, 0, -8]) {
                difference() {
                
                    cylinder(12, 4, 4);
                    translate([0,0,-5]) {
                        cylinder(20, 3, 3);
                    }
                } 
            }
            translate([0,0,-14]) {
                cylinder(20, 2.8, 2.8);
            }
        }
    }
}

module print_top_shape() {
    translate([0, 0, height+wall_thickness]){
        rotate([0,180,0]) {
            top_shape();
        }
    }
}

module print_bottom_shape() {
    translate([0,0,-wall_thickness]) {
        bottom_shape();
    }
}

print_top_shape();

//top_shape();

//bottom_shape();

//plate();

echo(version=version());
// Written by Marius Kintel <marius@kintel.net>
//
// To the extent possible under law, the author(s) have dedicated all
// copyright and related and neighboring rights to this software to the
// public domain worldwide. This software is distributed without any
// warranty.
//
// You should have received a copy of the CC0 Public Domain
// Dedication along with this software.
// If not, see <http://creativecommons.org/publicdomain/zero/1.0/>.
