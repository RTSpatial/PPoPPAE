import matplotlib
import matplotlib.pyplot as plt
import math
import os
import numpy as np
# import comm_settings
from common import datasets_pip, dataset_labels_pip, hatches, markers, linestyles
import sys
import re
import pandas as pd

def scale_size(size_list, k_scale=1000):
    return tuple(str(int(kb)) + "K" if kb < k_scale else str(int(kb / k_scale)) + "M" for kb in
                 np.asarray(size_list) / k_scale)


def get_time(prefix, datasets):
    loading_time = []
    query_time = []
    for dataset in datasets:
        path = os.path.join(prefix, dataset)
        with open(path, 'r') as fi:
            for line in fi:
                m = re.search(r"Loading Time (.*) ms$", line)
                if m is not None:
                    loading_time.append(float(m.groups()[0]))
                m = re.search(r"Query Time (.*) ms$", line)
                if m is not None:
                    query_time.append(float(m.groups()[0]))

    return np.asarray(loading_time), np.asarray(query_time)


def get_time_rayjoin(prefix, datasets):
    ag_time = []
    loading_time = []
    query_time = []
    for dataset in datasets:
        path = os.path.join(prefix, dataset)
        with open(path, 'r') as fi:
            for line in fi:
                m = re.search(r"Adaptive Grouping: (.*?) ms$", line)
                if m is not None:
                    ag_time.append(float(m.groups()[0]))
                m = re.search(r"Build Index: (.*?) ms$", line)
                if m is not None:
                    loading_time.append(float(m.groups()[0]))
                m = re.search(r"Query: (.*?) ms$", line)
                if m is not None:
                    query_time.append(float(m.groups()[0]))

    return np.asarray(loading_time) + np.asarray(ag_time), np.asarray(query_time)


def draw_query_time(prefix):
    index_types = ("cuspatial", "rayjoin", "rtspatial")
    index_labels = ("cuSpatial", "RayJoin", "RTSpatial")

    plt.rcParams.update({'font.size': 14})
    loc = [x for x in range(len(dataset_labels_pip))]
    fig, ax = plt.subplots(nrows=1, ncols=1, figsize=(6, 4))
    parse_functions = (get_time, get_time_rayjoin, get_time)

    pip_time = {}

    for i, index_type in enumerate(index_types):
        loading_time, query_time = parse_functions[i](os.path.join(prefix, index_type), datasets_pip)
        pip_time[index_type] = loading_time + query_time
        print("Building percent", loading_time / pip_time[index_type])

    pip_time = pd.DataFrame.from_dict(pip_time, )

    for i in range(len(datasets_pip)):
        rayjoin_time = pip_time.iloc[i]['rayjoin']
        rtspatial_time = pip_time.iloc[i]['rtspatial']
        print("Dataset", datasets_pip[i])
        print("Speedup over RayJoin", rayjoin_time / rtspatial_time)
        print()

    # 1. Choose your desired colormap
    cmap = plt.get_cmap('gist_gray')

    # 2. Segmenting the whole range (from 0 to 1) of the color map into multiple segments
    slicedCM = cmap(np.linspace(0, 1, len(index_types) + 2))
    slicedCM = list(slicedCM[::-1])
    del slicedCM[-3:-1]

    pip_time.columns = index_labels
    pip_time.plot(kind="bar", width=0.7, ax=ax, color=slicedCM, edgecolor='black', )

    ax.set_xticks(loc, dataset_labels_pip, rotation=0)
    ax.set_xlabel(xlabel="Datasets")
    ax.set_ylabel(ylabel='Time (ms)', labelpad=1)
    ax.legend(loc='upper left', ncol=3, handletextpad=0.3,
              borderaxespad=0.2, frameon=False, columnspacing=1,
              )
    ax.set_yscale('log')

    x0, x1 = ax.get_xlim()
    ax.set_xlim(x0 + 0.15, x1 - 0.15)  # x-margins does not work with pandas
    ax.margins(y=0.33)
    fig.tight_layout(pad=0.1)

    fig.savefig('pip_time.pdf', format='pdf', bbox_inches='tight')
    # plt.show()


if __name__ == '__main__':
    dir = sys.argv[1]
    draw_query_time(os.path.join(dir, "pip_queries_100000"))
