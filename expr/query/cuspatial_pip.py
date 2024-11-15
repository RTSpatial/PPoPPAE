# Modified from https://gist.github.com/trxcllnt/38e44bc86cabff23352f3541add6228f
import cudf
import cupy
import cuspatial
import geopandas as gpd
import pandas as pd
import os.path
import pyarrow
import rmm
import shapely
import sys


def read_wkt(path):
    geoms = []

    with open(path, 'r') as fi:
        for line in fi:
            line = line.strip()
            if len(line) > 0:
                geom = shapely.from_wkt(line)
                geoms.append(geom)
    df = pd.DataFrame({'geometry': geoms})
    return gpd.GeoDataFrame(df, geometry='geometry')


rmm.mr.set_current_device_resource(
    rmm.mr.PoolMemoryResource(rmm.mr.get_current_device_resource())
)


def preprocess_polys(recreate=False):
    file_path = geom_path + ".polys.arrow"
    # Create parquet file if it doesn't exist yet
    if recreate or not os.path.exists(file_path):
        # Preprocess and save polys.arrow
        df = read_wkt(geom_path)
        df = df.geometry.explode(ignore_index=True)
        coords = cudf.DataFrame(df.geometry.get_coordinates(ignore_index=True)).interleave_columns()
        rings = cudf.Series(df.geometry.apply(lambda p: [len(x.coords) for x in shapely.get_rings(p)]))
        ring_offset = cudf.concat([cudf.Series([0], dtype="int32"), rings.explode().astype("int32")]).cumsum()
        part_offset = cudf.concat([cudf.Series([0], dtype="int32"), rings.list.len().astype("int32")]).cumsum()
        tbl = cudf.DataFrame({
            "polys": cuspatial.GeoSeries.from_polygons_xy(
                coords, ring_offset, part_offset, cupy.arange(len(df) + 1)
            ).polygons.column()
        }).to_arrow()
        with pyarrow.ipc.new_file(file_path, tbl.schema) as file:
            file.write_table(tbl)
    return file_path


def preprocess_points(recreate=False):
    file_path = query_path + ".points.arrow"
    # Create parquet file if it doesn't exist yet
    if recreate or not os.path.exists(file_path):
        # Preprocess and save points.arrow
        df = read_wkt(query_path)
        tbl = cudf.DataFrame(df.geometry.get_coordinates(ignore_index=True)).to_arrow()
        print("Queries", len(df))
        with pyarrow.ipc.new_file(file_path, tbl.schema) as file:
            file.write_table(tbl)
    return file_path


def get_polys(dtype="float64", recreate=False):
    polys = cudf.read_feather(preprocess_polys(recreate))["polys"]
    parts = cudf.Series(polys._column.elements)
    rings = cudf.Series(parts._column.elements)
    coords = cudf.Series(rings._column.elements)
    xs = coords.list.get(0).astype(dtype)
    ys = coords.list.get(1).astype(dtype)
    return (
        cuspatial.GeoSeries.from_polygons_xy(
            coords._column.elements.astype(dtype),
            rings._column.offsets,
            parts._column.offsets,
            polys._column.offsets
        ),
        (xs.min(), ys.min(), xs.max(), ys.max())
    )


def get_points(dtype="float64", recreate=False):
    df = cudf.read_feather(preprocess_points(recreate)).astype(dtype)
    return (
        cuspatial.GeoSeries.from_points_xy(df.interleave_columns()),
        (df["x"].min(), df["y"].min(), df["x"].max(), df["y"].max())
    )


def read_polys_and_points(dtype="float64", recreate=False):
    (polys, polys_bbox) = get_polys(dtype, recreate)
    (points, points_bbox) = get_points(dtype, recreate)
    min_x = min(polys_bbox[0], points_bbox[0])
    min_y = min(polys_bbox[1], points_bbox[1])
    max_x = max(polys_bbox[2], points_bbox[2])
    max_y = max(polys_bbox[3], points_bbox[3])

    return polys, points, min_x, min_y, max_x, max_y, dtype


def run_benchmark(polys, points, min_x, min_y, max_x, max_y, dtype):
    import time

    def trunc(n, m):
        return int(n * m) / m

    def ftime(start, n_repeat):
        return f"{trunc((time.time() - start) * 1000 / n_repeat, 1000)} ms"

    threshold = 15

    max_size = 0
    max_depth = 16
    while max_size <= threshold:
        max_depth -= 1
        max_size = len(points) / pow(4, max_depth) / 4

    scale = max(max_x - min_x, max_y - min_y) / (1 << max_depth)

    # print("  params:", {"max_depth": max_depth, "max_size": max_size, "scale": scale})
    n_repeat = 5

    build_start = time.time()
    for _ in range(n_repeat):
        point_indices, quadtree = cuspatial.quadtree_on_points(points, min_x, max_x, min_y, max_y, scale, max_depth,
                                                               max_size)
    print(f"Loading Time {ftime(build_start, n_repeat)}")

    query_start = time.time()
    for _ in range(n_repeat):
        poly_bboxes = cuspatial.polygon_bounding_boxes(polys)
        poly_quad_pairs = cuspatial.join_quadtree_and_bounding_boxes(quadtree, poly_bboxes, min_x, max_x, min_y, max_y,
                                                                     scale, max_depth)
        polygons_and_points = cuspatial.quadtree_point_in_polygon(poly_quad_pairs, quadtree, point_indices, points,
                                                                  polys)
    print(f"Query Time {ftime(query_start, n_repeat)}")
    print(f"Results {len(polygons_and_points)}")


if __name__ == '__main__':
    import warnings

    warnings.filterwarnings("ignore")
    geom_path = sys.argv[1]
    query_path = sys.argv[2]
    run_benchmark(*read_polys_and_points("float32", False))
