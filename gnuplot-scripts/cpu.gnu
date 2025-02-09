datafile = ".sar.csv"

set datafile commentschar ""
set datafile separator ";"
set timefmt "%Y-%m-%d %H:%M:%S"
set xdata time
set terminal svg size 800,400 fixed background rgb 'white'
set xtics rotate
set key right
set grid

set title "CPU Utilization"
set xlabel "Time"
set ylabel "% Utilization"
plot for [i=5:13:1] \
    datafile using 3:(sum [col=i:13] column(col)) \
    title columnheader(i) \
    with lines lw 2
