radius = 20;
thickness = 2;
height = 50;
detail = 100;

count_x = 1;
count_y = 1;

generate_support = true;
support_distance = 0.3;
support_height = 10;

module ambicylinder(radius, thickness, h, n) {
    m = n/2;
    r = radius - thickness;
    R = radius;
    
    function x(t) = t;
    function y(t) = (1 - abs(t) + sqrt(1 - t*t))/2;
    function z(t) = (sqrt(1-t*t) - 1 + abs(t))/2;
    function t(i) = -1 + 2*i/m;
    function inc(i) = (i+1)%n;
    
    inner_top = concat(
        [for (i=[0:m-1]) [r *  x(t(i)), r *  y(t(i)), h + r *  z(t(i))]],
        [for (i=[0:m-1]) [r * -x(t(i)), r * -y(t(i)), h + r * -z(t(i))]]
    );
    inner_bottom = concat(
        [for (i=[0:m-1]) [r *  x(t(i)), r *  y(t(i)), r *  z(t(i))]],
        [for (i=[0:m-1]) [r * -x(t(i)), r * -y(t(i)), r * -z(t(i))]]
    );
    outer_top = concat(
        [for (i=[0:m-1]) [R *  x(t(i)), R *  y(t(i)), h + R *  z(t(i))]],
        [for (i=[0:m-1]) [R * -x(t(i)), R * -y(t(i)), h + R * -z(t(i))]]
    );
    outer_bottom = concat(
        [for (i=[0:m-1]) [R * x(t(i)),  R *  y(t(i)), R *  z(t(i))]],
        [for (i=[0:m-1]) [R * -x(t(i)), R * -y(t(i)), R * -z(t(i))]]
    );
    points = concat(inner_top, inner_bottom, outer_bottom, outer_top);
    faces = concat(
        [for (i=[0:n-1]) [i, inc(i), n+inc(i), n+i]], // inner
        [for (i=[0:n-1]) [n+i, n+inc(i), 2*n+inc(i), 2*n+i]], // bottom
        [for (i=[0:n-1]) [2*n+i, 2*n+inc(i), 3*n+inc(i), 3*n+i]], // outer
        [for (i=[0:n-1]) [3*n+i, 3*n+inc(i), inc(i), i]] // top
    );
    triangles = concat(
        [for (i=[0:n-1]) [i, inc(i), n+inc(i)]], // inner 1
        [for (i=[0:n-1]) [i, n+i, n+inc(i)]], // inner 2
        [for (i=[0:n-1]) [n+i, n+inc(i), 2*n+inc(i)]], // bottom 1
        [for (i=[0:n-1]) [n+i, 2*n+i, 2*n+inc(i)]], // bottom 2
        [for (i=[0:n-1]) [2*n+i, 2*n+inc(i), 3*n+inc(i)]], // outer 1
        [for (i=[0:n-1]) [2*n+i, 3*n+i, 3*n+inc(i)]], // outer 2
        [for (i=[0:n-1]) [3*n+i, 3*n+inc(i), inc(i)]], // top 1
        [for (i=[0:n-1]) [3*n+i, i, inc(i)]] // top 2
    );
    triangles2 = concat(
        [for (i=[0:n-1]) [i, inc(i), n+inc(i), n+i]], // inner
        [for (i=[0:n-1]) [n+i, n+inc(i), 2*n+inc(i)]], // bottom 1
        [for (i=[0:n-1]) [n+i, 2*n+i, 2*n+inc(i)]], // bottom 2
        [for (i=[0:n-1]) [2*n+i, 2*n+inc(i), 3*n+inc(i), 3*n+i]], // outer
        [for (i=[0:n-1]) [3*n+i, 3*n+inc(i), inc(i)]], // top 1
        [for (i=[0:n-1]) [3*n+i, i, inc(i)]] // top 2
    );
    
    polyhedron(points=points, faces=triangles2);
}

module ambicylinder_with_support(radius, thickness, height, n, gen_support, s_distance, s_height) {
    ambicylinder(radius, thickness, height, n);
    
    if (gen_support) {
        difference() {
            translate([0, 0, -height - support_distance]) {
                ambicylinder(radius=radius, thickness=thickness, h=height, n=detail);
            }
            translate([0, 0, -support_distance - support_height - (height + radius) / 2]) {
                cube([2 * radius, 2 * radius, height + radius], true);
            }
        }
    }
}

// ambicylinder_with_support(radius, thickness, height, detail, generate_support, support_distance, support_height);


module ambicylinder_array(radius, thickness, height, n, count_x, count_y) {
    off = 2 * radius - thickness;
    for (i=[0:count_x-1]) {
        for (j=[0:count_y-1]) {
            translate([i * off, j * off, 0]) {
                ambicylinder(radius, thickness, height, n);
            }
        }
    }
}

module ambicylinder_array_support(radius, thickness, height, n, count_x, count_y, support_distance, support_height) {
    
    difference() {
        difference() {
            //translate([0, 0, -height]) {
            //    ambicylinder_array(radius, thickness, height, n, count_x, count_y);
            //}
            translate([0, 0, -support_height - (height + radius) / 2]) {
                cube([2 * radius * 2 * count_x + 1, 2 * radius * 2 * count_y + 1, height + radius], true);
            }
        }/*
        minkowski() {
            ambicylinder_array(radius, thickness, height, n, count_x, count_y);
            sphere(support_distance);
        }*/
    }
}

$fn=10;
//ambicylinder_array(radius, thickness, height, detail, count_x, count_y);
ambicylinder_array_support(radius, thickness, height, detail, count_x, count_y, support_distance, support_height);

