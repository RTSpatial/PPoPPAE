import matplotlib
import matplotlib.pyplot as plt
import math
import os
import numpy as np
# import comm_settings
from common import datasets, dataset_labels, hatches, markers, linestyles
import sys
import re
import pandas as pd


def scale_size(size_list, k_scale=1000):
    return tuple(str(int(kb)) + "K" if kb < k_scale else str(int(kb / k_scale)) + "M" for kb in
                 np.asarray(size_list) / k_scale)


def get_running_time(prefix, size_list, dist, query_type):
    loading_time = []
    query_time = []
    for size in size_list:
        path = os.path.join(prefix, "scalability_{size}_{query}".format(size=size, query=query_type),
                            "{dist}_n_{size}.wkt.log".format(dist=dist, size=size))
        with open(path, 'r') as fi:
            for line in fi:
                m = re.search(r"Loading Time (.*) ms$", line)
                if m is not None:
                    loading_time.append(float(m.groups()[0]))
                m = re.search(r"Query Time (.*) ms$", line)
                if m is not None:
                    query_time.append(float(m.groups()[0]))

    return np.asarray(query_time)


def draw_query(prefix, ):
    geom_sizes = ("10000000", "20000000", "30000000", "40000000", "50000000")
    geom_sizes_labels = scale_size([int(s) for s in geom_sizes])
    plt.rcParams.update({'font.size': 13})
    fig, axes = plt.subplots(nrows=1, ncols=2, figsize=(8, 3.,))

    ax1 = axes[0]
    # ax2 = axes[1]
    ax3 = axes[1]

    query_time_uniform = get_running_time(prefix, geom_sizes, "uniform", "point-contains")
    query_time_gaussian = get_running_time(prefix, geom_sizes, "gaussian", "point-contains")
    df = pd.DataFrame.from_dict({"Uniform": query_time_uniform, "Gaussian": query_time_gaussian})
    df.index = geom_sizes_labels

    print("Point Contains, Uniform", query_time_uniform)

    df.plot(kind="line", ax=ax1)

    # query_time_uniform = get_running_time(prefix, geom_sizes, "uniform", "range-contains")
    # query_time_gaussian = get_running_time(prefix, geom_sizes, "gaussian", "range-contains")
    # df = pd.DataFrame.from_dict({"Uniform": query_time_uniform, "Gaussian": query_time_gaussian})
    # df.index = geom_sizes_labels
    # df.plot(kind="line", ax=ax2)

    # print("Range Contains, Uniform", query_time_uniform)

    query_time_uniform = get_running_time(prefix, geom_sizes, "uniform", "range-intersects")
    query_time_gaussian = get_running_time(prefix, geom_sizes, "gaussian", "range-intersects")
    df = pd.DataFrame.from_dict({"Uniform": query_time_uniform, "Gaussian": query_time_gaussian})
    df.index = geom_sizes_labels
    df.plot(kind="line", ax=ax3)

    print("Range Intersects, Uniform", query_time_uniform)

    titles = ("(a) Point queries scalability",
              "(c) Range-intersects queries scalability",)

    for i, ax in enumerate(axes):
        for j, line in enumerate(ax.get_lines()):
            line.set_marker(markers[j])
            line.set_color('black')

        ax.set_xlabel(titles[i])
        ax.set_ylabel(ylabel='Query Time (ms)', labelpad=1)
        ax.margins(x=0.05, y=0.25)
        ax.set_ylim(bottom=0)
        ax.legend(loc='upper left', ncol=3, handletextpad=0.3,
                  fontsize=11, borderaxespad=0.2, frameon=False)

    fig.tight_layout(pad=0.1)

    fig.savefig("fig11.pdf", format='pdf', bbox_inches='tight')
    # plt.show()


if __name__ == '__main__':
    draw_query(sys.argv[1])
