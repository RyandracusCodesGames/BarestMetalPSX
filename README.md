# BarestMetalPSX
A collection of PlayStation Bare Metal MIPS assembly programs
## About
BarestMetalPSX is a comprehensive collection of bare-metal programs for the original Sony PlayStation 
written entirely in MIPS assembly with no reliance on any external SDKS, toolchains, or proprietary software.

## Bare-Metal Example 

https://github.com/user-attachments/assets/5ab7c284-241a-49d3-b0d7-128fe0e64cff

## Programs
In the root directory of the repository, I've included three ports of classic arcade games that helped redefine the 
arcade and video gaming industry. These serve as practical demonstrations of BareMetalPSX's capabilities, showcasing 
how it can be used to build complete games on the original PlayStation.

The core of the collection is housed in the tutorial directory, where the bulk of the programs are contained. These cover 
a wide variety of foundational topics, such as initializing and sending rasterization commands to the GPU, performing matrix and 
vector math to draw 3D objects, and send audio data to the sound processor to play music.

## Bare-Metal Arcade Demos
https://github.com/user-attachments/assets/000cb663-7cc7-45da-9097-d41d9a57c44e

https://github.com/user-attachments/assets/887c179b-31bd-4243-9e4a-83d3b8e7581d

## Building
All the demo programs are assembled utilizing my own custom assembler 
that can be downloaded and compiled from here https://github.com/RyandracusCodesGames/vsasm

Each demo program comes bundled with a batch file for Windows and an equivalent bash script file for Linux
to automate the building process of the final PlayStation executables. 

For Windows run: build.bat 
For Linux run: build.sh 

To manually build the programs from the command line of the assembler simply follow the instructions below 

```c
	vsasm -oexe example.asm -o example.exe 
```

## Writing Your Own Bare-Metal Programs
Wait...what??? You actually...want to do bare-metal programming? Well, enlightened one, you've come to the right place. In the 
template directory, you'll find a generic assembler file that will initialize the graphics hardware of the 
PlayStation and set up a double buffer strategy, initializes the controller driver of the PlayStation through the BIOS 
with blank sections for empty input handling, adds a font rasterizer, and a string drawer. All of this links to the code in the lib directory, 
which contains everything I’ve built so far. With this setup, you’ve got everything you need to start tinkering with your own bare-metal homebrew programs 
for the PlayStation!

## Huge Shoutout
I want to personally thank and give a huge shoutout to the following people and resources. They proved invaluable in the development of this series, and 
I wouldn't have managed to do anything without them.

* Martin Korth's PSX-SPX documentation
https://problemkaputt.de/psxspx-contents.htm

* Peter Lemon's PlayStation Bare Metal MIPS Assembly Programming repository
https://github.com/PeterLemon/PSX/
* spicyjpeg's ps1-bare-metal repository
 https://github.com/spicyjpeg/ps1-bare-metal
* stenzek's PlayStation emulator, **DuckStation**, that can be found here https://github.com/stenzek/duckstation

This is by far the most resourceful emulator that I've utilized while testing out the programs of this series. The debug menus
for the CPU, SPU, GPU, and VRAM were instrumental in my experimentation phase, and no emulator has come close to the smooth controller 
input provided from DuckStation.
