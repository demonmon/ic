
vlog -O0 -vlog01compat -f flist.f
vsim -c +nowarnTSCALE -L ./work -novopt -l load.log tb

add log -r /tb/*

##do ./wave.do
run -all