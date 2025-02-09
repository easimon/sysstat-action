datafile = ".sar.csv"

set datafile commentschar ""
set datafile separator ";"
set timefmt "%Y-%m-%d %H:%M:%S"
set xdata time
set terminal svg size 800,400 fixed background rgb 'white'
set xtics rotate
set key right
set grid

set title "IPv6 Network traffic"
set xlabel "Time"
set ylabel "Packets/sec"

# -n IP6 columns
# hostname;interval;timestamp;irec6/s;fwddgm6/s;idel6/s;orq6/s;asmrq6/s;asmok6/s;imcpck6/s;omcpck6/s;fragok6/s;fragcr6/s
plot for [i=4:7:1] \
    datafile using 3:i \
    title columnheader(i) \
    with lines lw 2
