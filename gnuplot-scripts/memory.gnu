datafile = ".sar.csv"

set datafile commentschar ""
set datafile separator ";"
set timefmt "%Y-%m-%d %H:%M:%S"
set xdata time
set terminal svg size 800,400 fixed background rgb '#f6eee3'
set xtics rotate
set key left
set grid

set title "Memory Consumption"
set xlabel "Time (UTC)"
set ylabel "MB Memory used"

# -r columns
# hostname;interval;timestamp;kbmemfree;kbavail;kbmemused;%memused;kbbuffers;kbcached;kbcommit;%commit;kbactive;kbinact;kbdirty
plot for [i in "kbmemused kbmemfree kbavail kbbuffers kbcached"] \
    datafile using 3:(column(i) / 1024) \
    title i \
    with lines lw 2
