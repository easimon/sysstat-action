datafile = ".sar.csv"

set datafile commentschar ""
set datafile separator ";"
set timefmt "%Y-%m-%d %H:%M:%S"
set xdata time
set terminal svg size 800,400 fixed background rgb 'white'
set xtics rotate
set key right
set grid

set title "Memory consumption"
set xlabel "Time"
set ylabel "MB Memory used"

# -r columns
# hostname;interval;timestamp;kbmemfree;kbavail;kbmemused;%memused;kbbuffers;kbcached;kbcommit;%commit;kbactive;kbinact;kbdirty
plot for [i=4:6:1] \
    datafile using 3:(sum [col=i:i] column(col) / 1024) \
    title columnheader(i) \
    with lines lw 2
