import matplotlib
import matplotlib.pyplot as plt
import math
import os
import numpy as np
# import comm_settings
from common import hatches, markers, linestyles
from common import datasets, dataset_labels
import sys
import re
import pandas as pd


def scale_size(size_list, k_scale=1000):
    return tuple(str(int(kb)) + "K" if kb < k_scale else str(int(kb / k_scale)) + "M" for kb in
                 np.asarray(size_list) / k_scale)


def get_running_time(prefix, datasets):
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


def get_update_time(prefix, op, dataset):
    inserted_list = []
    time_list = []
    path = os.path.join(prefix, op, dataset)
    with open(path, 'r') as fi:
        for line in fi:
            m = re.search(r"Geoms (\d+) .*? Time (.*?) ms", line)
            if m is not None:
                n_geoms = int(m.groups()[0]) / 1000 / 1000
                inserted_list.append(n_geoms)
                time_list.append(float(m.groups()[1]))

    return np.asarray(inserted_list), np.asarray(time_list)


def get_update_throughput(prefix, op, dataset, batch_sizes):
    throughput_list = []
    for batch in batch_sizes:
        path = os.path.join(prefix, op + "_batch_" + batch, dataset)
        with open(path, 'r') as fi:
            for line in fi:
                m = re.search(r"Throughput (.*?) ge", line)
                if m is not None:
                    throughput = float(m.groups()[0]) / 1000 / 1000
                    throughput_list.append(throughput)

    return np.asarray(throughput_list)


def get_query_performance_slowdown(prefix, op, dataset, query_size, update_ratios):
    slowdown_list = []
    for ratio in update_ratios:
        path = os.path.join(prefix, op + "_update_" + ratio + "_queries_" + query_size, dataset)
        with open(path, 'r') as fi:
            query_time = None
            query_time_updated = None
            for line in fi:
                m = re.search(r"Query Time (\d.*?) ms", line)
                if m is not None:
                    query_time = float(m.groups()[0])
                m = re.search(r"Query Time After Updates (.*?) ms", line)
                if m is not None:
                    query_time_updated = float(m.groups()[0])
            slowdown_list.append(query_time_updated / query_time)
    return np.asarray(slowdown_list)


patterns = ['', '\\\\', '\\\\--', '..', '..--']
light_colors = ['#6C87EA', 'lightcoral', '#FF3333', 'lemonchiffon', '#FFDF33', 'powderblue', '#33FFFF', ]
series_id = 1


def scale_size(size_list, k_scale=1000):
    return tuple(str(int(kb)) + "K" if kb < k_scale else str(int(kb / k_scale)) + "M" for kb in
                 np.asarray(size_list) / k_scale)


def draw_build_time(prefix, ):
    index_types = ("rtree", "glin", "lbvh", "rtspatial")
    index_labels = ("Boost", "GLIN", "LBVH", "RTSpatial")
    plt.rcParams.update({'font.size': 12})
    loc = [x for x in range(len(dataset_labels))]
    fig, ax = plt.subplots(nrows=1, ncols=1, figsize=(5, 4))

    # Varying datasets

    index_loading_time = {}
    index_query_time = {}
    query_size = 100000

    for index_type in index_types:
        loading_time, query_time = get_running_time(
            os.path.join(prefix + "/range-contains_queries_" + str(query_size), index_type), datasets)
        index_loading_time[index_type] = loading_time
        index_query_time[index_type] = query_time
    index_loading_time = pd.DataFrame.from_dict(index_loading_time, )
    # 1. Choose your desired colormap
    cmap = plt.get_cmap('gist_gray')

    # 2. Segmenting the whole range (from 0 to 1) of the color map into multiple segments
    slicedCM = cmap(np.linspace(0, 1, len(index_types)))
    slicedCM = slicedCM[::-1]

    index_loading_time.columns = index_labels
    bars = index_loading_time.plot(kind="bar", width=0.7, ax=ax, color=slicedCM, edgecolor='black', )

    all_hatches = []
    for i in range(len(index_types)):
        all_hatches += [hatches[i] for _ in range(len(index_loading_time))]

    all_hatches.reverse()
    for idx, patch in enumerate(bars.patches):
        patch.set_hatch(all_hatches[idx])

    ax.set_xticks(loc, dataset_labels, rotation=0)
    ax.set_xlabel("Index construction time")
    ax.set_ylabel(ylabel='Time (ms)', labelpad=1)
    ax.set_yscale('log')
    ax.margins(x=0.01, y=0.1)

    ax.legend(loc='upper left', ncol=2, handletextpad=0.3,
              borderaxespad=0.2, frameon=False)
    fig.tight_layout(pad=0.)
    fig.savefig("index_construction.pdf", format='pdf', bbox_inches='tight')
    plt.show()


def draw_bulk_time(prefix):
    plt.rcParams.update({'font.size': 13})
    fig, ax = plt.subplots(nrows=1, ncols=1, figsize=(5, 4.5))
    cmap = plt.get_cmap('gist_gray')
    slicedCM = cmap(np.linspace(0, 1, 5))

    inserted_list, time_list = get_update_time(prefix, "insertion", "uniform_n_50000000.wkt.log")

    ax.plot(inserted_list, time_list, label="Insertion", color=slicedCM[3], )

    deleted_list, time_list = get_update_time(prefix, "deletion", "uniform_n_50000000.wkt.log")
    ax.plot(deleted_list, time_list, label="Deletion", color=slicedCM[0])

    ax.set_xlabel(xlabel="Millions of Geometries")
    ax.set_ylabel(ylabel='Time (ms)', labelpad=1)
    ax.legend(loc='upper left',
              ncol=1, handletextpad=0.3,
              fontsize=15, borderaxespad=0.2, frameon=False)

    fig.tight_layout()
    fig.savefig('ins_del.pdf', format='pdf', bbox_inches='tight')
    plt.show()


def draw_batch_throughput(prefix):
    plt.rcParams.update({'font.size': 13})
    fig, ax = plt.subplots(nrows=1, ncols=1, figsize=(5, 4))
    cmap = plt.get_cmap('gist_gray')
    batch_sizes = ("1000", "10000", "100000", "1000000",)

    insert_tp = get_update_throughput(prefix, "insertion", "uniform_n_50000000.wkt.log", batch_sizes)
    delete_tp = get_update_throughput(prefix, "deletion", "uniform_n_50000000.wkt.log", batch_sizes)

    df = pd.DataFrame.from_dict({"Insertion": insert_tp, "Deletion": delete_tp}, )
    df.index = scale_size([int(n) for n in np.asarray(batch_sizes, dtype=int)])

    slicedCM = cmap(np.linspace(0, 1, 2))
    slicedCM = slicedCM[::-1]
    df.plot(kind="bar", ax=ax, rot=0, color=slicedCM, edgecolor='black', )

    ax.set_xlabel(xlabel="Batch size")
    ax.set_ylabel(ylabel='Throughput (M geometries/sec)', labelpad=1)
    ax.set_yscale('log')
    ax.legend(loc='upper left',
              ncol=1, handletextpad=0.3,
              fontsize=11, borderaxespad=0.2, frameon=False)

    fig.tight_layout()
    fig.savefig('ins_del_tp.pdf', format='pdf', bbox_inches='tight')
    # plt.show()


def draw_update_query(prefix):
    plt.rcParams.update({'font.size': 13})
    fig, ax = plt.subplots(nrows=1, ncols=1, figsize=(5, 4.5))
    cmap = plt.get_cmap('gist_gray')
    dataset = "parks_Europe.wkt.log"
    update_ratios = ("0.0002", "0.002", "0.02", "0.2",)

    point_contains_slowdown = get_query_performance_slowdown(prefix, "point-contains", dataset, "100000", update_ratios)
    range_contains_slowdown = get_query_performance_slowdown(prefix, "range-contains", dataset, "100000", update_ratios)
    range_intersects_slowdown = get_query_performance_slowdown(prefix, "range-intersects", dataset, "10000",
                                                               update_ratios)

    df = pd.DataFrame.from_dict(
        {"Point Query": point_contains_slowdown, "Range Contains Query": range_contains_slowdown,
         "Range Intersects Query": range_intersects_slowdown}, )
    df.index = [str(float(r) * 100) + "%" for r in update_ratios]

    slicedCM = cmap(np.linspace(0, 1, 3))
    slicedCM = slicedCM[::-1]
    df.plot(kind="bar", ax=ax, rot=0, color=slicedCM, edgecolor='black', )

    ax.margins(x=0.05, y=0.38)
    ax.set_xlabel(xlabel="Update ratio")
    ax.set_ylabel(ylabel='Query Performance Slowdown', labelpad=1)
    ax.legend(loc='upper left',
              ncol=1, handletextpad=0.3,
              fontsize=11, borderaxespad=0.2, frameon=False)

    fig.tight_layout()
    fig.savefig('update_query.pdf', format='pdf', bbox_inches='tight')
    # plt.show()


def draw_all(prefix):
    plt.rcParams.update({'font.size': 12.})
    plt.rcParams['hatch.linewidth'] = 2
    fig, axes = plt.subplots(nrows=1, ncols=3, figsize=(12.5, 3.7))
    fig.subplots_adjust(wspace=-0.2)  # Adjust the width space between axes

    ax1, ax2, ax3, = axes

    # inserted_list, time_list = get_update_time(prefix, "insertion", "uniform_n_50000000.wkt.log")

    # ax1.plot(inserted_list, time_list, label="Insertion", color=slicedCM[3], )
    #
    # deleted_list, time_list = get_update_time(prefix, "deletion", "uniform_n_50000000.wkt.log")
    # ax1.plot(deleted_list, time_list, label="Deletion", color=slicedCM[0])
    #
    # ax1.set_xlabel(xlabel="(a) Millions of bounding boxes")
    # ax1.set_ylabel(ylabel='Time (ms)', labelpad=1)
    # ax1.legend(loc='upper left',
    #            ncol=1, handletextpad=0.3,
    #            borderaxespad=0.2, frameon=False)

    index_loading_time = {}
    index_query_time = {}
    index_types = ("rtree", "glin", "lbvh", "rtspatial")
    index_labels = ("Boost", "GLIN", "LBVH", "RTSpatial")
    query_size = 100000

    for index_type in index_types:
        loading_time, query_time = get_running_time(
            os.path.join(prefix + "/range-contains_queries_" + str(query_size), index_type), datasets)
        index_loading_time[index_type] = loading_time
        index_query_time[index_type] = query_time
    index_loading_time = pd.DataFrame.from_dict(index_loading_time, )
    # 1. Choose your desired colormap
    cmap = plt.get_cmap('gist_gray')

    # 2. Segmenting the whole range (from 0 to 1) of the color map into multiple segments
    slicedCM = cmap(np.linspace(0, 1, len(index_types) + 2))
    slicedCM = list(slicedCM[::-1])
    del slicedCM[-3:-1]

    index_loading_time.columns = index_labels
    loc = [x for x in range(len(dataset_labels))]
    index_loading_time.plot(kind="bar", width=0.8, ax=ax1, color=slicedCM, edgecolor='black', )

    bars = [thing for thing in ax1.containers if isinstance(thing, matplotlib.container.BarContainer)]
    for i, bar in zip(range(len(bars)), bars):
        for patch in bar:
            patch.set_hatch(hatches[i])

    ax1.set_xticks(loc, dataset_labels, rotation=0)
    ax1.set_xlabel("(a) Index construction time")
    ax1.set_ylabel(ylabel='Time (ms)', labelpad=1)
    ax1.set_yscale('log')
    # x0, x1 = ax1.get_xlim()
    # ax1.set_xlim(x0 + 0.15, x1 - 0.15)  # x-margins does not work with pandas
    ax1.margins(y=0.35)
    ax1.legend(loc='upper left', ncol=2, handletextpad=0.3,
               borderaxespad=0.2, frameon=False)

    batch_sizes = ("1000", "10000", "100000", "1000000",)

    insert_tp = get_update_throughput(prefix, "insertion", "uniform_n_50000000.wkt.log", batch_sizes)
    delete_tp = get_update_throughput(prefix, "deletion", "uniform_n_50000000.wkt.log", batch_sizes)

    df = pd.DataFrame.from_dict({"Insertion": insert_tp, "Deletion": delete_tp}, )
    df.index = scale_size([int(n) for n in np.asarray(batch_sizes, dtype=int)])

    slicedCM = cmap(np.linspace(0, 1, 2))
    slicedCM = slicedCM[::-1]
    df.plot(kind="bar", ax=ax2, rot=0, width=0.6, color=slicedCM, edgecolor='black', )

    ax2.set_xlabel(xlabel="(b) Batch size")
    ax2.set_ylabel(ylabel='Throughput (M rectangles/sec)', labelpad=1)
    ax2.set_yscale('log')
    ax2.legend(loc='upper left',
               ncol=1, handletextpad=0.3,
               borderaxespad=0.2, frameon=False)

    dataset = "parks_Europe.wkt.log"
    update_ratios = ("0.0002", "0.002", "0.02", "0.2",)

    point_contains_slowdown = get_query_performance_slowdown(prefix, "point-contains", dataset, "100000", update_ratios)
    range_contains_slowdown = get_query_performance_slowdown(prefix, "range-contains", dataset, "100000", update_ratios)
    range_intersects_slowdown = get_query_performance_slowdown(prefix, "range-intersects", dataset, "10000",
                                                               update_ratios)

    df = pd.DataFrame.from_dict(
        {"Point Query": point_contains_slowdown, "Range Contains Query": range_contains_slowdown,
         "Range Intersects Query": range_intersects_slowdown}, )
    df.index = [str(float(r) * 100) + "%" for r in update_ratios]

    slicedCM = cmap(np.linspace(0, 1, 3))
    slicedCM = slicedCM[::-1]
    df.plot(kind="bar", ax=ax3, rot=0, width=0.7, color=slicedCM, edgecolor='black', )

    ax3.margins(x=0.05, y=0.5)
    ax3.set_xlabel(xlabel="(c) Update ratio")
    ax3.set_ylabel(ylabel='Query Performance Slowdown', labelpad=1)
    ax3.legend(loc='upper left',
               ncol=1, handletextpad=0.3,
               borderaxespad=0.2, frameon=False)

    for ax in axes:
        x0, x1 = ax.get_xlim()
        ax.set_xlim(x0 + 0.15, x1 - 0.15)  # x-margins does not work with pandas

    fig.tight_layout(pad=0.)
    fig.savefig('fig12.pdf', format='pdf', bbox_inches='tight')
    # plt.show()


if __name__ == '__main__':
    draw_all(sys.argv[1])
