from SpatialQueryBenchmark.expr.draw.common import linestyles

datasets = ("dtl_cnty.wkt.log", "USACensusBlockGroupBoundaries.wkt.log", "USADetailedWaterBodies.wkt.log",
            "parks_Europe.wkt.log", "lakes.bz2.wkt.log", "parks.bz2.wkt.log")
dataset_labels = ("USCounty", "USCensus", "USWater", "EUParks", "OSMLakes", "OSMParks")

datasets_pip = ("dtl_cnty.wkt.log", "USACensusBlockGroupBoundaries.wkt.log", "USADetailedWaterBodies.wkt.log",
                "parks_Europe.wkt.log",)
dataset_labels_pip = ("USCounty", "USCensus", "USWater", "EUParks",)
# datasets = ("lakes.bz2.wkt.log", "parks.bz2.wkt.log")
# dataset_labels = ("OSMLakes", "OSMParks")

hatches = ['\\\\', '..', '**', '//', 'xx', '']
markers = ['*', "o", '^', 's', 'x', '']
linestyle_tuple = {
    'solid': 'solid',
    'loosely dotted': (0, (1, 10)),
    'dotted': (0, (1, 1)),
    'densely dotted': (0, (1, 1)),
    'long dash with offset': (5, (10, 3)),
    'loosely dashed': (0, (5, 10)),
    'dashed': (0, (5, 5)),
    'densely dashed': (0, (5, 1)),

    'loosely dashdotted': (0, (3, 10, 1, 10)),
    'dashdotted': (0, (3, 5, 1, 5)),
    'densely dashdotted': (0, (3, 1, 1, 1)),

    'dashdotdotted': (0, (3, 5, 1, 5, 1, 5)),
    'loosely dashdotdotted': (0, (3, 10, 1, 10, 1, 10)),
    'densely dashdotdotted': (0, (3, 1, 1, 1, 1, 1))}
linestyles_names = ['loosely dotted', 'dotted', 'long dash with offset', 'dashdotted', 'loosely dashdotdotted', 'solid']
linestyles = []
for name in linestyles_names:
    linestyles.append(linestyle_tuple[name])
