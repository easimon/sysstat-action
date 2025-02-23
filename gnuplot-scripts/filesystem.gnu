datafile = ".sar.csv"

set datafile commentschar ""
set datafile separator ";"
set timefmt "%Y-%m-%d %H:%M:%S"
set xdata time
set terminal svg size 800,400 fixed background rgb '#f6eee3'
set xtics rotate
set key left
set grid

filesystem = system("tail -1 .sar.csv | cut -f 4 -d';'")

set title "Filesystem usage " . filesystem
set xlabel "Time (UTC)"
set ylabel "GB"

# -F columns
# # hostname;interval;timestamp;FILESYSTEM;MBfsfree;MBfsused;%fsused;%ufsused;Ifree;Iused;%Iused
plot for [i=6:5:-1] \
    datafile using 3:(sum [col=i:6] column(col) / 1024) \
    title columnheader(i) \
    with lines lw 2
