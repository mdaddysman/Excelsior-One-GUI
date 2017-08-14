# Excelsior One GUI
A **Excelsior One GUI** is written in Matlab for controling four Spectra-Physics Excelsior One OEM lasers. The program is written to work with four (405, 488, 561, 640 nm) lasers. However, the application can be [easily modified](README.md#modifying-the-gui) to work with different wavelengths and number of lasers. The program supports both [direct diode](https://en.wikipedia.org/wiki/Laser_diode) and [diode-pumped solid state](https://en.wikipedia.org/wiki/Diode-pumped_solid-state_laser) laser settings of the [Excelsior One product line](http://www.spectra-physics.com/products/cw-lasers/excelsior-one).  

The code requires Windows (tested on Windows 7) with enough available RS-232 ports to connect the lasers. A 4 port RS-232 to USB 2.0 converter was used for this system.  

## Repository Contents
- `ExcelsiorOne.m` This file contains the code for running the GUI. No other files are neccessary if Matlab is install on the system.
- `ExcelsiorOne_Control.prj` Matlab project file for creating a executable version of the code for Windows computers without Matlab installed. The compiled excutable and installer is in the ExcelsiorOne_Control directory. Running the executable requires Matlab 2017a runtime to be installed. If it is not installed on the system the web installer package can be used to download and install the runtime (along with the GUI excutable).   

## Using the GUI
### Inital Configuration
Upon running the program for the first time, the window below displays asking which RS-232 (COM) ports correspond to each laser. 

![Port Selection](/Images/Ports.png)

Next to each laser is a list with the available RS-232 ports on the computer in order of the COM number. Selecting a COM port opens that port and communicates with the laser to retreive the laser's wavelength which is displayed on the right of the COM selection drop-down menu. In the above example, COM7 is the 405 nm laser port and is correctly selected. However, the 488 nm laser port is incorrectly selected as COM9. Notice that the selected COM port is interfacing with a laser of wavelength 561. Once all the COM ports are matched with correct wavelengths, press confirm. The COM settings will be save to the file `ports.mat` which is automatically loaded on subsequent runnings of the program. The COM ports can also be reassigned from the options menu of the GUI. 

### GUI Interface

### Options

## Modifying the GUI

## License
This software is made available under the [GPL-3.0](LICENSE). 
