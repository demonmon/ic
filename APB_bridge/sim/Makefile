all: clean vcs sim 

# compiling, corresponding to run_vcs.sh
vcs:
	vcs  \
              -f filelist.f  \
              -timescale=1ns/1ps \
              -fsdb  -full64  -R  +vc  +v2k  -sverilog  -debug_acc+all  \
              -P ${LD_LIBRARY_PATH}/novas.tab  ${LD_LIBRARY_PATH}/pli.a  \
              -l compile.log              

# simulation, corresponding to run_simv.sh
sim:
	./simv -gui -l sim.log
# start verdi, corresponding to run_verdi.sh
verdi:
	verdi -sv -f filelist.f  \
  	 -ssf test.fsdb  &

# delete useless files
clean:
	rm -rf simv* *.log *.fsdb novas* *.key csrc verdiLog
