The PiDP is typically used with a USB hub as its 'PiDP Universal Storage Device'.

Image files (disk images, paper tape images, DECtape images) are then stored on a USB stick,
and when inserted to the USB hub the first image file can be mounted into the emulated device.

The image files in this directory are typical candidates to put on USB sticks.

Mounting works as follows:

1. Select the device you want to mount on by setting the Data Field switches

   Switch Settings                                                   File Extension
   --------------------------------------------------------------------------------
        000 - mount USB paper tape on the high-speed paper tape reader   .pt
        001 - mount USB paper tape on the paper tape punch               .pt
        010 - mount DECtape on DT0 (TU55)                                .dt
        011 - mount DECtape on DT1 (TU55)                                .dt
        100 - mount 8" floppy disk on RX0 (RX01/02)                      .rx
        101 - mount 8" floppy disk on RX1 (RX01/02)                      .rx
        110 - mount 10MB removable disk cartridge on RL0 (RL8A)          .rl
        111 - mount 10MB removable disk cartridge on RL1 (RL8A)          .rl

2. Toggle Sing_Step and Sing_Inst switches together

3. The PiDP will scan all inserted USB sticks and mount the first unmounted image file for that device.
   Scanning requires the image file to have the extension as per the above table.
   This is equivalent to using the attach command from the simh command line.

Notes:

- Multiple image files can reside on one USB stick, as long as they do not have the same extension 
  (and your USB stick is large enough).

- You can put any other files on the sticks too, the PiDP will just ignore them.

- You can, of course, also just use the simh attach command to mount any image files on the SD card,
  and ignore the "PiDP Universal USB Storage Device" altogether.
