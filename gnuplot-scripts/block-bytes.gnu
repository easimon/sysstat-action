datafile = ".sar.csv"

set datafile commentschar ""
set datafile separator ";"
set timefmt "%Y-%m-%d %H:%M:%S"
set xdata time
set terminal svg size 800,400 fixed background rgb '#f6eee3'
set xtics rotate
set key left
set grid

set title "Block Device Bandwidth"
set xlabel "Time (UTC)"
set ylabel "MB / sec"

# -b columns
# # hostname;interval;timestamp;tps;rtps;wtps;dtps;bread/s;bwrtn/s;bdscd/s
plot for [i=8:9:1] \
    datafile using 3:(column(i) * 512 / 1024 / 1024) \
    title columnheader(i) \
    with lines lw 2
