set w [wvCreateWindow]
verdiWindowBeWindow -win $w
wvOpenFile -win $w ondas.fsdb
wvResizeWindow -win $w 0 0 1200 650
update
wvSetPreference -autoScrollToFirstSignalWhenAddOrExpand on
wvAddSignal -win $w /top_tb/CLK /top_tb/Reset /top_tb/SEL15 /top_tb/SEL25 /top_tb/B20 /top_tb/B10 /top_tb/B5 /top_tb/C /top_tb/P /top_tb/MODE15 /top_tb/MODE25 /top_tb/COMPLETE /top_tb/IMPRIME15 /top_tb/IMPRIME25 /top_tb/C5 /top_tb/C10 /top_tb/C15
wvSetWindowTimeUnit -win $w 1 ns
wvZoom -win $w 0 160
wvScrollUp -win $w 100
update
wvCapture -win $w -file ondas_verdi.png -footer "VCS + Verdi: ticket15 (20+20) y ticket25 (5+10+5+20)"
schSetPreference -instName on -moduleName on -portName on -modulePortName on
set s [schCreateWindow -delim . -scope top_tb.dut]
verdiWindowBeWindow -win $s
schResizeWindow 0 0 1200 760 -win $s
update
schFit -win $s
update
schCapture -win $s -file esquema_verdi.png -footer "Sistema unificado: Moore y Mealy"
exit
