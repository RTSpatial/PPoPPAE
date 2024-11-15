import os
import sys
import bz2
from shapely.wkt import loads
from shapely import to_wkt
from shapely.geometry import box

if len(sys.argv) != 3:
    print("Invalid args")
    exit(1)

bz2_path = sys.argv[1]
shape_column = int(sys.argv[2])

out_path = bz2_path + ".wkt"

if os.path.exists(bz2_path):
    print("Cannot open", bz2_path)

print("Reading", bz2_path, " shape column", shape_column)

geom_id = 0
n_discarded = 0
with bz2.open(bz2_path, "rt") as bz_file:
    with open(out_path, 'w') as f_out:
        for line in bz_file:
            arr = line.rstrip('\n').split('\t')
            shape_txt = arr[shape_column].strip('"')
            if geom_id % 10000 == 0:
                print("Writing,", geom_id)
            geom_id += 1
            try:
                shape = loads(shape_txt)
                min_x, min_y, max_x, max_y = shape.bounds
                if min_x > max_x or min_y > max_y:
                    print(shape.bounds)
                if shape.geom_type == "Polygon" and shape.is_valid:
                    b = box(min_x, min_y, max_x, max_y)

                    f_out.write(to_wkt(shape) + "\n")
                elif shape.geom_type == "GeometryCollection":
                    for sub_shape in shape.geoms:
                        if sub_shape.geom_type == "Polygon" and sub_shape.is_valid:
                            min_x, min_y, max_x, max_y = sub_shape.bounds
                            if min_x > max_x or min_y > max_y:
                                print(shape.bounds)
                            b = box(min_x, min_y, max_x, max_y)
                            f_out.write(to_wkt(sub_shape) + "\n")
                else:
                    n_discarded += 1
            except Exception:
                n_discarded += 1
print("Discarded", n_discarded, "geometries, rate: ",
      1.0 * n_discarded / geom_id)
