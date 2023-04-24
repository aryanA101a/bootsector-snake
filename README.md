# bootsector-snake

![image](https://user-images.githubusercontent.com/23309033/234036727-60b5f6c9-311c-4e63-af09-8e6e061e6583.png)

## What exactly is being achieved here?
This snake game runs independently without any dependency on an operating system. This has been achieved by programming the game on the bootsector, which is the first 512 bytes of a bootable drive. The bootsector contains instructions that allow the loading of the operating system onto the disk's RAM. During startup, the BIOS reads instructions from the bootsector to initiate the loading process of the operating system. Since we are using bios to run our game, we are constrained on graphics front. Although we have some graphic modes to choose from, we are using VGA Text Mode 3 here.



## Run
`qemu-system-x86_64 -drive format=raw,file=snake.bin`  
Alternatively, flash the bin file on a pendrive and boot your system from it.

## Reference
https://www.youtube.com/watch?v=wQfOYeZDKWk
