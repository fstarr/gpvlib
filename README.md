	                    .__  ._____.    
	   ____ _________  _|  | |__\_ |__  
	  / ___\\____ \  \/ /  | |  || __ \ 
	 / /_/  >  |_> >   /|  |_|  || \_\ \
	 \___  /|   __/ \_/ |____/__||___  /
	/_____/ |__|                     \/ 

	            (personal)
	    General purpose VHDL library.


# README

## Table of Contents

  1. Module overview
  A. Directory structure/Module organization


## 1. Module overview

freqDiv		Frequency divider that generates a clock signal by dividing
		the input clock frequency by a user definable sampling factor.

spi2par		Data collector that transforms serial input into parallel
		output using a SPI-like input interface.


## A. Directory structure/Module organization

For VHDL module width name "<module>" (in src/ directory)
place documentation/testbench files with filename prefix "<module>_"
in the corresponding directories!

	example:
		src/spi2par.vhd		VHDL module
	
	->	doc/spi2par_ctrlfsm.png
		tb/spi2par_tb.vhd
		tb/spi2par_tb.wcfg
