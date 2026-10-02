#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")"
if [[ -n "${DISPLAY:-}" ]]; then
  verdi -nologo -dbdir simv.daidir -ssf ondas.fsdb -play capturas.tcl
else
  # En el servidor se extrajo el RPM oficial de Rocky Linux aquí, sin sudo.
  virtual_display="${XVFB_BIN:-$PWD/graphics_runtime/usr/bin/Xvfb}"
  if [[ ! -x "$virtual_display" ]]; then
    echo 'Ejecuta desde una sesión gráfica o define XVFB_BIN con un Xvfb funcional.' >&2
    exit 1
  fi
  # -displayfd elige un número de pantalla libre; no comparte otras sesiones.
  screen_file=$(mktemp)
  "$virtual_display" -displayfd 3 -screen 0 1600x1100x24 -nolisten tcp 3>"$screen_file" >xvfb.log 2>&1 &
  screen_pid=$!
  trap 'kill "$screen_pid" 2>/dev/null || true; rm -f "$screen_file"' EXIT
  for attempt in {1..20}; do
    [[ -s "$screen_file" ]] && break
    sleep 0.2
  done
  [[ -s "$screen_file" ]] || { cat xvfb.log >&2; exit 1; }
  export DISPLAY=":$(cat "$screen_file")"
  verdi -nologo -dbdir simv.daidir -ssf ondas.fsdb -play capturas.tcl
fi
