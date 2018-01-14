# cs330-labs
The labs for my Computer Organization and Assembly course. The code is written in NASM for x86-based linux systems.

## Installation
Ensure that you have the `nasm`, `gcc`, and `g++-multilib` packages installed. If you are running Debian or a derivative, run
```
sudo apt install nasm gcc g++-multilib
```

## Usage
Ensure that the asm32 script is executable with `chmod +x asm32`
To assemble and link `ass1.asm`, run the following in the root of the project
```
./asm32 ass1
```
That will make an `ass1` executable in the current directory and execute it.
