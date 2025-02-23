datafile = ".sar.csv"

set datafile commentschar ""
set datafile separator ";"
set timefmt "%Y-%m-%d %H:%M:%S"
set xdata time
set terminal svg size 800,400 fixed background rgb '#f6eee3'
set xtics rotate
set key left
set grid

set title "System Load"
set xlabel "Time (UTC)"
set ylabel "Load average"

# -q LOAD columns
# hostname;interval;timestamp;runq-sz;plist-sz;ldavg-1;ldavg-5;ldavg-15;blocked
plot for [i=6:8:1] \
    datafile using 3:i \
    title columnheader(i) \
    with lines lw 2
