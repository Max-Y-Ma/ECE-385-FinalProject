#ifndef __VGA_INTERFACE_H
#define __VGA_INTERFACE_H

#include <stdio.h>
#include "memory_map.h"
#include "datatypes.h"
#include "../src/usb_kb/HID.h"

void VGAClear();
void VGATest();
int isBlankInterval();
alt_u8 swaps(alt_u8 data);
alt_u8 rightCircular4(alt_u8 data);
void getImageVRAMBlock(int index, alt_u32* buf);
void setNeuralNetCharacterRegs(int index, alt_u32 character);
void printNeuralNetCharacterReg(int index);
void mouseTask(BOOT_MOUSE_REPORT* buf, alt_32* mouseX, alt_32* mouseY, alt_8* sensitivity);
void VGATask(BOOT_MOUSE_REPORT buf, alt_32 mouseX, alt_32 mouseY);

#endif /* __VGA_INTERFACE_H */
