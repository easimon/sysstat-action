datafile = ".sar.csv"

set datafile commentschar ""
set datafile separator ";"
set timefmt "%Y-%m-%d %H:%M:%S"
set xdata time
set terminal svg size 800,400 fixed background rgb '#f6eee3'
set xtics rotate
set key left
set grid

device = system("tail -1 .sar.csv | cut -f 4 -d';'")

set title "Network traffic " . device
set xlabel "Time (UTC)"
set ylabel "kBytes / sec"

# -n DEV columns
# hostname;interval;timestamp;IFACE;rxpck/s;txpck/s;rxkB/s;txkB/s;rxcmp/s;txcmp/s;rxmcst/s;%ifutil
plot for [i=7:8:1] \
    datafile using 3:i \
    title columnheader(i) \
    with lines lw 2
