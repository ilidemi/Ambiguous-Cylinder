radius = 20;
thickness = 3;
height = 50;
detail = 500;

count_x = 3;
count_y = 2;

generate_support = true;
support_distance = 0.3;
support_height = 10;

ambicylinder_array(radius, thickness, height, detail, false, 0, count_x, count_y);
if (generate_support) {
    ambicylinder_array_support(radius, thickness, height, detail, count_x, count_y, support_distance, support_height);
}

module ambicylinder(radius, thickness, h, n, flat_bottom) {
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
        [for (i=[0:m-1]) [r *  x(t(i)), r *  y(t(i)), flat_bottom ? 0 : r *  z(t(i))]],
        [for (i=[0:m-1]) [r * -x(t(i)), r * -y(t(i)), flat_bottom ? 0 : r * -z(t(i))]]
    );
    outer_top = concat(
        [for (i=[0:m-1]) [R *  x(t(i)), R *  y(t(i)), h + R *  z(t(i))]],
        [for (i=[0:m-1]) [R * -x(t(i)), R * -y(t(i)), h + R * -z(t(i))]]
    );
    outer_bottom = concat(
        [for (i=[0:m-1]) [R * x(t(i)),  R *  y(t(i)), flat_bottom ? 0 : R *  z(t(i))]],
        [for (i=[0:m-1]) [R * -x(t(i)), R * -y(t(i)), flat_bottom ? 0 : R * -z(t(i))]]
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
        [for (i=[0:n-1]) [n+i, 2*n+inc(i), 2*n+i]], // bottom 2
        [for (i=[0:n-1]) [2*n+i, 2*n+inc(i), 3*n+inc(i), 3*n+i]], // outer
        [for (i=[0:n-1]) [3*n+i, 3*n+inc(i), inc(i)]], // top 1
        [for (i=[0:n-1]) [3*n+i, inc(i), i]] // top 2
    );
    
    polyhedron(points=points, faces=triangles2);
}

module ambicylinder_array(radius, thickness, height, n, flat_bottom, swelling, count_x, count_y) {
    off = 2 * radius - thickness;
    for (i=[0:count_x-1]) {
        for (j=[0:count_y-1]) {
            translate([i * off, j * off, -swelling]) {
                ambicylinder(radius + swelling, thickness + 2 * swelling, height + 2 * swelling, n, flat_bottom);
            }
        }
    }
}

module ambicylinder_array_support(radius, thickness, height, n, count_x, count_y, support_distance, support_height) {
    
    difference() {
        translate([0, 0, -support_height]) {
            ambicylinder_array(radius, thickness, support_height, n, true, 0, count_x, count_y);
        }
        ambicylinder_array(radius, thickness, height, n, false, support_distance, count_x, count_y);
    }
}
