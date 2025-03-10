stats '.job.csv' using 1 prefix "R"

datafile = ".job.csv"

set datafile commentschar ""
set datafile separator ","

set timefmt "%Y-%m-%dT%H:%M:%S"
timefmt="%Y-%m-%dT%H:%M:%S"
set format x "%H:%M:%S"
set format y ""

set xdata time
set terminal svg size 800,400 fixed background rgb '#f6eee3'
set xtics rotate
set grid

T(N) = timecolumn(N,timefmt)

set title "Job chart"
set xlabel "Time (UTC)"
set ylabel "Job"
set yr [(R_max+1) * -1 : 1]
unset key

# columns
# rownum,number,name,started_at,completed_at,conclusion,status

set style arrow 1 nohead filled size screen 0.02, 15 fixed lt 3 lw 6

plot datafile using (T(4)) : ($1) * -1 : (T(5)-T(4)) : (0.0) : yticlabel(1) skip 1 with vector as 1, \
  datafile every ::::R_median-1 using (T(4)) : ($1) * -1 : ($3) skip 1 with labels left offset 0,0 font ",7", \
  datafile every ::R_median::R_max+5 using (T(5)) : ($1) * -1 : ($3) skip 1 with labels right offset 0,0 font ",7"