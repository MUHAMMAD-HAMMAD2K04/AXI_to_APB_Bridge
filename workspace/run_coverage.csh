#!/bin/csh -f
clear

# Clean up old coverage data (ignore if not exists)
rm -rf cov_work

# Run simulation using the run.f file
# -gui: Opens the simulator GUI (waveform viewer)
# -access +rwc: Grants read/write/connect access for debugging
# -sv: Enables SystemVerilog features
# -f run.f: Reads all compile options and files from run.f

#with gui
#xrun -gui -access +rwc -timescale 1ns/1ns -sv -f file.f -coverage U -covoverwrite

#without gui
xrun -access +rwc -timescale 1ns/1ns -sv -f file.f -coverage all

# Check if simulation succeeded
if ($status == 0) then
    echo "Simulation finished successfully!"
    imc &
else
    echo "Simulation failed (error code $status)."
    echo "Check compilation errors above."
endif
