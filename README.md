# Logo-Detection
In this project I used HDL (VHDL) to describe a hardware for vehicle logo detection using template matching.
I had used Quaturs II v12.0, so contained here are vhdl files only.
Pardon my use of VHDL rather than Verilog, this was my first HDL language

You can create a new project on your development tool and import these files.
Top module is CorrMatching.
You should add all the vhdl files to your project and set 'CorrMatching' as Top module

To run, you should load data to SRAM
To do that:
you might use Altera De2 control panel or similar application for data loading.
and load *.dat at address 0.

I also added matlab script to make *.dat
You can input one of generated data in GEN_DAT folder 

logo_lexus.dat
logo_honda.dat
logo_toyota.dat
