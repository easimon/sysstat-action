datafile = ".sar.csv"

set datafile commentschar ""
set datafile separator ";"
set timefmt "%Y-%m-%d %H:%M:%S"
set xdata time
set terminal svg size 800,400 fixed background rgb '#f6eee3'
set xtics rotate
set key left
set grid

set title "IPv4 Network Traffic"
set xlabel "Time (UTC)"
set ylabel "Packets / sec"

# -n IP columns
# hostname;interval;timestamp;irec/s;fwddgm/s;idel/s;orq/s;asmrq/s;asmok/s;fragok/s;fragcrt/s
plot for [i=4:7:1] \
    datafile using 3:i \
    title columnheader(i) \
    with lines lw 2
