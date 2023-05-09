#ifndef __DATATYPES_
#define __DATATYPES_

# pragma once

#include "alt_types.h"

#define WIDTH           80U
#define HEIGHT          480U

#define EMPTY_SPACE     10752U

#define NUM_CODES       5U

#define IMG_WIDTH       28U
#define IMG_HEIGHT      28U

// 	Word Addresses  | Byte Addressses | Purpose
// 	------------------------------------------------------------
// 	0x0000 - 0x257F | 0x0000 - 0x95FF | B&W VRAM
// 	0x3000 - 0x3004 | 0xC000 - 0xC013 | x5 NN Codes
// 	0x3005          | 0xC014 - 0xC017 | Status Register (Read-Only)          
typedef struct vga_interface {
    alt_u8 VRAM [WIDTH * HEIGHT];
    alt_u8 empty [EMPTY_SPACE];
    alt_u32 neuralNetRegs [NUM_CODES];
    alt_u32 statusReg;  // [0] = Blanking Signal
} vga_interface;

// 	Word Addresses   | Byte Addressses | Purpose
// 	------------------------------------------------------------
// 	0x0000 - 0x001B  | 0x0000 - 0x006F | 28 x 28 Image File
// 	0x001C			 | 0x0070 - 0x0073 | Character Register (Read-Only)
typedef struct NN_interface {
    alt_u32 imgRegFile [IMG_HEIGHT];    // 28 Pixel in Upper 28 Bits
    alt_u32 charReg;
} NN_interface;

typedef enum imgFile {
    START_HEIGHT=225,
    IMAGE_0_START=256, IMAGE_0_END=283,
    IMAGE_1_START=284, IMAGE_1_END=311,
    IMAGE_2_START=312, IMAGE_2_END=339,
    IMAGE_3_START=340, IMAGE_3_END=367,
    IMAGE_4_START=368, IMAGE_4_END=395,
} imgFile;

#endif /* __DATATYPES_ */
