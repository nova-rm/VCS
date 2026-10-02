# Laboratorio VCS / Verdi / SAIF

Diseño adaptado de `Parcial_1_fixed_finalisimo.circ`. Ejecutado en la cuenta `rrivera` del servidor universitario el 1 de octubre de 2026.

## Ejecutar

En una terminal del servidor, dentro de la carpeta de este paquete:

```bash
bash run.sh
```

Se requieren VCS, Verdi (para el volcado FSDB) y URG configurados en el entorno. La compilación incluye `-lca` porque VCS requiere esa opción para el monitoreo SAIF de tipos SystemVerilog. El testbench usa `$set_gate_level_monitoring("rtl_on", "sv")` antes de las cuatro llamadas de actividad indicadas en la guía.

Resultado obtenido: `PASS: 9671 checks, 4541 cycles; waiting-state input cases 512/512`. La cobertura del DUT fue 100% en línea, condición, toggle, FSM y rama. Consultar `coverage_report/dashboard.html` o `dashboard.txt`. `top_tb` está excluido de la instrumentación mediante `coverage.hier`; no se excluyen ramas del DUT. La métrica FSM corresponde a Moore: 5 estados y 8 transiciones detectadas. Mealy está expresada como acumulador aritmético y no fue reconocida por la herramienta como una FSM independiente.

## Abrir en Verdi

Desde una sesión gráfica del servidor:

```bash
verdi -dbdir simv.daidir -ssf ondas.fsdb
```

Agregar las señales de `top_tb`: CLK, Reset, SEL15, SEL25, B20, B10, B5, C, P, MODE15, MODE25, COMPLETE, IMPRIME15, IMPRIME25, C5, C10 y C15. Examinar 0 a 160 ns para las dos primeras transacciones. Abrir el esquemático de `top_tb.dut`.

`capturas.tcl` reproduce las exportaciones nativas. `ondas.fsdb` y `ondas.vcd` contienen la simulación completa. `fsm.saif` contiene la actividad medida entre 20 ns y 57190 ns.

## Comportamiento preservado

- Moore: 000 reposo, 001 pago15, 010 pago25, 011 imprime15, 100 imprime25. Ambas selecciones activas en reposo no seleccionan un ticket.
- Mealy: P representa el saldo en unidades de 5; B20/B10/B5 aportan 4/2/1 unidades. Entradas simultáneas se suman.
- Ambos modos completan cuando el total alcanza o supera 40. No se implementó un precio diferente según el nombre del ticket.
- C5 y C10 reflejan B5 y B10 con modo activo; C15 refleja B20 con modo activo. No son un cálculo del vuelto.
- Al completar, P vuelve a cero; el excedente no se conserva. Si una entrada de dinero permanece alta, se contabiliza en cada flanco de reloj durante el modo de pago.
- Reset es asíncrono y activo en alto. La copia `Parcial_1_reset_corregido.circ` agrega exclusivamente el segmento (480,285)-(480,290) que faltaba en el reset de C2 del bloque Moore. El archivo original no se modificó.

## Verificación

`referencia.mem` se obtuvo de las compuertas y túneles del XML, no del RTL aritmético. Hay 2048 combinaciones de estado e inputs; el testbench consulta esta tabla antes y después de cada flanco. Esto comprueba equivalencia combinacional con el circuito fuente, con el reset conectado en la adaptación. No equivale a una simulación completa del archivo Logisim original.

Para regenerarla con Python 3 (sin dependencias):

```bash
python3 extraer_referencia.py /ruta/al/Parcial_1_fixed_finalisimo.circ referencia_nueva.mem
cmp referencia.mem referencia_nueva.mem
```

El extractor está especializado en los dos subcircuitos de este archivo y sus compuertas clásicas de dos entradas. No es un conversor general de Logisim.

## Archivos

- `moore.sv`, `mealy.sv`, `sistema.sv`: diseño sintetizable.
- `top_tb.sv`: estímulos y comprobaciones automáticas.
- `run.sh`, `coverage.hier`: ejecución y alcance de cobertura.
- `simulation.log`, `compile.log`, `urg.log`: evidencia de ejecución.
- `coverage_report/`: reporte original de Synopsys URG.
- `fsm.saif`, `ondas.fsdb`, `ondas.vcd`: actividad y ondas originales.
- `trazabilidad.txt`: huella del circuito fuente y formato de la referencia.

Una cobertura del 100% corresponde a las métricas y estímulos descritos; no demuestra ausencia de todos los errores. La actividad SAIF proviene de pruebas intensivas con resets y entradas simultáneas, no de un perfil representativo de uso para estimar potencia de un producto.

La ejecución queda en `/home/rrivera/laboratorio_fsm_codex_20261001` del servidor. El paquete no contiene credenciales ni configuraciones VPN.
