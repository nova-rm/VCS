#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
vcs -full64 -lca -sverilog -kdb -debug_access+all +define+SAIF+FSDB \
  -cm line+cond+branch+tgl+fsm -cm_hier coverage.hier \
  moore.sv mealy.sv sistema.sv top_tb.sv -top top_tb -o simv -l compile.log
./simv -cm line+cond+branch+tgl+fsm -l simulation.log
urg -full64 -dir simv.vdb -report coverage_report -format both -log urg.log
