# Makefile for UVM (PCIe Data Link Layer)
LD_LIBRARY_PATH = /media/2/LogicLibraries

test = pcie_tl_test
program_path = .
PROGRAM_TOP = ${program_path}/testbench.sv
package_path = ./packages
PACKAGES = ${package_path}/pcie_tl_stimulus_pkg.sv ${package_path}/pcie_tl_env_pkg.sv ${package_path}/pcie_tl_test_pkg.sv
TEST_TOP = ${PACKAGES} ${PROGRAM_TOP}
rtl_path = ../rtl
DUT = $(rtl_path)/PCIe_PKG.svh $(rtl_path)/AXI_INIF.sv $(rtl_path)/PCIe_FIFO.sv $(rtl_path)/PCIe_arbiter.sv $(rtl_path)/PCIe_TL_RX.sv $(rtl_path)/pcie_tl_if.sv
# HARNESS_TOP = $(rtl_path)/router_test_top.sv
TOP = ${TEST_TOP}

log = simv.log
verbosity = UVM_MEDIUM
uvm_ver = ../uvm-1.2
seed = 1
defines =
uvm_defines = UVM_VERDI_COMPWAVE+UVM_NO_DEPRECATED+UVM_OBJECT_MUST_HAVE_CONSTRUCTOR
plus = 
option = UVM_VERDI_TRACE="UVM_AWARE+RAL+TLM+IMP+HIER" +UVM_VERDI_TRACE=COMPWAVE +UVM_TR_RECORD +UVM_LOG_RECORD 
trace =
#trace = UVM_OBJECTION_TRACE

# compile_switches = -sverilog -lca -debug_access+all+reverse -kdb +vcs+vcdpluson -timescale="1ns/100ps" -l comp.log -ntb_opts ${uvm_ver} ${DUT} ${TOP} +define+${uvm_defines}+${defines}
compile_switches = -sverilog -debug_access+all -timescale="1ns/100ps" -kdb -LDFLAGS -Wl,--no-as-needed -ntb_opts ${uvm_ver} ${DUT} ${TOP} +define+${uvm_defines}+${defines}
runtime_switches = -l ${log} +UVM_TESTNAME=${test} +UVM_VERBOSITY=${verbosity} +${plus} +${trace} +${option}

# tcl = packet.tcl
# tr = packet_tr.tcl
cmd = cxl.cmd

all: simv run


simv compile: *.sv ${DUT} ${TOP}
	vcs -full64 ${compile_switches} -lca -debug_access+all 
	@echo "Compiled in 32-bit mode"

run:
	./simv +ntb_random_seed=${seed} ${runtime_switches}

random: simv
	./simv +ntb_random_seed_automatic ${runtime_switches}

verdi:
	verdi -play debug_files/${cmd} &

verdi_tr:
	./simv +ntb_random_seed=$(seed) ${runtime_switches} +UVM_TR_RECORD +UVM_LOG_RECORD +UVM_VERDI_TRACE
	verdi -play debug_files/${cmd} -nologo & 

verdi_i: simv
	./simv -gui=verdi +ntb_random_seed=$(seed) ${runtime_switches} +UVM_VERDI_TRACE &

clean:
	rm -rf simv* csrc* *.tmp *.vpd *.key log *.h temp *.log .vcs* *.txt DVE* *.hvp urg* .inter.vpd.uvm .restart* .synopsys* novas.* *.dat *.fsdb verdi* work* vlog*

nuke: clean
	rm -rf *.sv *.tcl packages debug_files
