#include "../inc/vga_interface.h"
#include "../inc/memory_map.h"

static volatile struct vga_interface* vga = (vga_interface*) VGA_AVL_INTERFACE_0_BASE;
static volatile alt_u8* mouseStatusPIO = (alt_u8*) MOUSE_STATUS_BASE;
static volatile alt_u16* mouseXPIO  = (alt_u16*) MOUSE_X_BASE;
static volatile alt_u16* mouseYPIO  = (alt_u16*) MOUSE_Y_BASE;

// Local Frame Buffer
static alt_u8 VRAM [WIDTH * HEIGHT];

#define PENCIL_SIZE		16U
#define ERASE_SIZE		4U

void VGAClear() {
	for (int i = 0; i < HEIGHT * WIDTH; ++i) {
		VRAM[i] = 0x00;
		vga->VRAM[i] = 0x00;
	}
}

void VGATest() {
	alt_u32 checksum = 0, readsum = 0;
    // R/W Memory Test: VRAM
	VGAClear();
	for (int i = 0; i < HEIGHT * WIDTH; ++i) {
		vga->VRAM[i] = 0x99;
		checksum += 0x99;
	}

	for (int i = 0; i < HEIGHT * WIDTH; ++i) {
		readsum += vga->VRAM[i];
	}

	if (checksum != readsum) {
		printf ("VRAM Checksum mismatch! Checksum: %x, Read-back Checksum: %x\n", checksum, readsum);
	}
	else {
		printf("VRAM passed! Checksum: %x, Read-back Checksum: %x\n", checksum, readsum);
	}

    // R/W Memory Test: Neural Network Register
    checksum = 0;
    for (int i = 0; i < NUM_CODES; i++) {
        vga->neuralNetRegs[i] = 0x66;
        checksum += 0x66;
    }

    readsum = 0;
    for (int i = 0; i < NUM_CODES; i++) {
		readsum += vga->neuralNetRegs[i];
    }

    if (checksum != readsum)
    {
    	printf("NN Checksum mismatch! Checksum: %x, Read-back Checksum: %x\n", checksum, readsum);
		while (1){};
    }
    else
    	printf("NN Checksum code passed! Checksum: %x, Read-back Checksum: %x\n", checksum, readsum);

    // R Memory Test: Status Register
    alt_u32 status = vga->statusReg;
    if (status == 0x00000000 || status == 0x00000001) {
    	printf ("Read status register passed!\n\r");
    }
    else {
    	printf ("Unable to Read Status Register!\n\r");
		while (1){};
    }

    return;
}

int isBlankInterval() {
	return (vga->statusReg & 0x00000001);
}

alt_u8 swaps(alt_u8 data) {
	alt_u8 top = (data & 0xF0) >> 4;
	alt_8 bottom = (data & 0x0F);
	switch (top)
	{
	case 0:
		data = 0x0F;
		break;
	case 1:
		data = 0x8F;
		break;
	case 2:
		data = 0x4F;
		break;
	case 3:
		data = 0xCF;
		break;
	case 4:
		data = 0x2F;
		break;
	case 5:
		data = 0xAF;
		break;
	case 6:
		data = 0x6F;
		break;
	case 7:
		data = 0xEF;
		break;
	case 8:
		data = 0x1F;
		break;
	case 9:
		data = 0x9F;
		break;
	case 10:
		data = 0x5F;
		break;
	case 11:
		data = 0xDF;
		break;
	case 12:
		data = 0x3F;
		break;
	case 13:
		data = 0xBF;
		break;
	case 14:
		data = 0x7F;
		break;
	case 15:
		data = 0xFF;
		break;
	default:
		break;
	}

	switch (bottom)
	{
	case 0:
		data &= 0xF0; 
		break;
	case 1:
		data &= 0xF8; 
		break;
	case 2:
		data &= 0xF4; 
		break;
	case 3:
		data &= 0xFC; 
		break;
	case 4:
		data &= 0xF2; 
		break;
	case 5:
		data &= 0xFA; 
		break;
	case 6:
		data &= 0xF6; 
		break;
	case 7:
		data &= 0xFE; 
		break;
	case 8:
		data &= 0xF1; 
		break;
	case 9:
		data &= 0xF9; 
		break;
	case 10:
		data &= 0xF5; 
		break;
	case 11:
		data &= 0xFD; 
		break;
	case 12:
		data &= 0xF3; 
		break;
	case 13:
		data &= 0xFB; 
		break;
	case 14:
		data &= 0xF7; 
		break;
	case 15:
		data &= 0xFF; 
		break;
	default:
		break;
	}
	return data;
}

alt_u8 rightCircular4(alt_u8 data) {
	alt_u8 temp = data;
	data = data >> 4 | 0xF0;
	data &= (temp << 4) | 0x0F;
	return data;
}

void getImageVRAMBlock(int index, alt_u32* buf) {
	alt_u32 data = 0;
	for (int i = 0; i < IMG_HEIGHT; ++i) {
		data = 0xFFFFFFFF;
		switch (index)
		{
		case 0:
			data &= (swaps(rightCircular4(VRAM[(START_HEIGHT + i) * WIDTH + 35]))) | 0xFFFFFF00;		// [280:283] -> VRAM[+35]
			data &= (swaps(rightCircular4(VRAM[(START_HEIGHT + i) * WIDTH + 34])) << 8) | 0xFFFF00FF;  	// [272:279] -> VRAM[+34]
			data &= (swaps(rightCircular4(VRAM[(START_HEIGHT + i) * WIDTH + 33])) << 16) | 0xFF00FFFF; 	// [264:271] -> VRAM[+33]
			data &=	(swaps(rightCircular4(VRAM[(START_HEIGHT + i) * WIDTH + 32])) << 24) | 0x00FFFFFF; 	// [256:263] -> VRAM[+32]
																										// [284:287] -> BORDER
			break;
		case 1:
			data &= (swaps(rightCircular4(VRAM[(START_HEIGHT + i) * WIDTH + 39]))) | 0xFFFFFF00; 		// [312:315] -> VRAM[+39]
			data &= (swaps(rightCircular4(VRAM[(START_HEIGHT + i) * WIDTH + 38])) << 8) | 0xFFFF00FF; 	// [304:311] -> VRAM[+38]
			data &= (swaps(rightCircular4(VRAM[(START_HEIGHT + i) * WIDTH + 37])) << 16) | 0xFF00FFFF;	// [296:303] -> VRAM[+37]
			data &=	(swaps(rightCircular4(VRAM[(START_HEIGHT + i) * WIDTH + 36])) << 24) | 0x00FFFFFF;	// [288:295] -> VRAM[+36]
																										// [316:319] -> BORDER
			break;
		case 2:
			data &= (swaps(rightCircular4(VRAM[(START_HEIGHT + i) * WIDTH + 43]))) | 0xFFFFFF00;		// [344:347] -> VRAM[+43]
			data &= (swaps(rightCircular4(VRAM[(START_HEIGHT + i) * WIDTH + 42])) << 8) | 0xFFFF00FF; 	// [336:343] -> VRAM[+42]
			data &= (swaps(rightCircular4(VRAM[(START_HEIGHT + i) * WIDTH + 41])) << 16) | 0xFF00FFFF;	// [328:335] -> VRAM[+41]
			data &=	(swaps(rightCircular4(VRAM[(START_HEIGHT + i) * WIDTH + 40])) << 24) | 0x00FFFFFF; 	// [320:327] -> VRAM[+40]
																										// [348:351] -> BORDER
			break;
		case 3:
			data &= (swaps(rightCircular4(VRAM[(START_HEIGHT + i) * WIDTH + 47]))) | 0xFFFFFF00;		// [376:379] -> VRAM[+47]
			data &= (swaps(rightCircular4(VRAM[(START_HEIGHT + i) * WIDTH + 46])) << 8) | 0xFFFF00FF;	// [368:375] -> VRAM[+46]
			data &= (swaps(rightCircular4(VRAM[(START_HEIGHT + i) * WIDTH + 45])) << 16) | 0xFF00FFFF;	// [360:367] -> VRAM[+45]
			data &=	(swaps(rightCircular4(VRAM[(START_HEIGHT + i) * WIDTH + 44])) << 24) | 0x00FFFFFF;	// [352:359] -> VRAM[+44]
																										// [380:383] -> BORDER
			break;
		case 4:
			data &= (swaps(rightCircular4(VRAM[(START_HEIGHT + i) * WIDTH + 51]))) | 0xFFFFFF00;		// [408:411] -> VRAM[+51]
			data &= (swaps(rightCircular4(VRAM[(START_HEIGHT + i) * WIDTH + 50])) << 8) | 0xFFFF00FF;	// [400:407] -> VRAM[+50]
			data &= (swaps(rightCircular4(VRAM[(START_HEIGHT + i) * WIDTH + 49])) << 16) | 0xFF00FFFF;	// [392:399] -> VRAM[+49]
			data &=	(swaps(rightCircular4(VRAM[(START_HEIGHT + i) * WIDTH + 48])) << 24) | 0x00FFFFFF;	// [384:391] -> VRAM[+48]
																										// [412:415] -> BORDER
			break;
		default:
			printf("Invalid Index for VRAM Block!");
			break;
		}

		data = data >> 4;
		buf[i] = data;
	}
}

// Set Character Register File
void setNeuralNetCharacterRegs(int index, alt_u32 character) {
	vga->neuralNetRegs[index] = character;
}

// Print Character Register File at Index
void printNeuralNetCharacterReg(int index) {
	printf("Character at Index: %d is %d\n", index, vga->neuralNetRegs[index]);
}

// Set Mouse Data to PIO connect to VGA Interface
void mouseTask(BOOT_MOUSE_REPORT* buf, alt_32* mouseX, alt_32* mouseY, alt_8* sensitivity) {
	// Adjust Mouse Position
	*mouseX += (signed char)buf->Xdispl / (*sensitivity & 0x0F);
	*mouseY += (signed char)buf->Ydispl / (*sensitivity & 0x0F);

	// Bounds Checking
	if (*mouseX < 0)
		*mouseX = 0;
	else if (*mouseX > 639 - PENCIL_SIZE)
		*mouseX = 639 - PENCIL_SIZE;

	if (*mouseY < PENCIL_SIZE)
		*mouseY = PENCIL_SIZE;
	else if (*mouseY > 478)
		*mouseY = 478;
	
	// Set X Position
	*mouseXPIO = *mouseX & 0x03FF;
	// Set Y Position
	*mouseYPIO = *mouseY & 0x03FF;
	
	// Mouse Status & Sensitivity:
	static int senseButtonPressed = 0;
	// 0x01 = Draw | 0x02 = Erase | 0x04 = Sensitivity
	if ((buf->button & 0x04)) {		// Middle Mouse Button Clicked
		if (senseButtonPressed == 0) {
			// Adjust Sensitivity
			if (*sensitivity == 0x08) {
				*sensitivity = 0x01;
			} else {
				*sensitivity = *sensitivity << 1;
			}
			senseButtonPressed = 1;
		}
	} else {
		senseButtonPressed = 0;
		*mouseStatusPIO = buf->button;
	}
	
	// Debug Messages
	// printf("Mouse X: %d\n", *mouseX);
	// printf("Mouse Y: %d\n", *mouseY);
	// printf("Sensitivity: %x\n", *sensitivity);

	// // Debug Messages
	// printf("X displacement: %d\n", (signed char) buf->Xdispl);
	// printf("Y displacement: %d\n", (signed char) buf->Ydispl);
	// printf("Buttons: %x\n", buf->button);
}

void VGATask(BOOT_MOUSE_REPORT buf, alt_32 mouseX, alt_32 mouseY) {
	// Write to Frame Buffer
	alt_u8 pixel_0 = VRAM[(mouseX >> 3) + 80 * (mouseY - 1)];
 	alt_u8 pixel_1 = VRAM[(mouseX >> 3) + 80 * mouseY];
	if (buf.button == 0x01) {
		switch (mouseX & 0x07) {
			case 0:
				pixel_0 |= 0x03;
				pixel_1 |= 0x03;
				break;
			case 1:
				pixel_0 |= 0x06;
				pixel_1 |= 0x06;
				break;
			case 2:
				pixel_0 |= 0x0C;
				pixel_1 |= 0x0C;
				break;
			case 3:
				pixel_0 |= 0x18;
				pixel_1 |= 0x18;
				break;
			case 4:
				pixel_0 |= 0x30;
				pixel_1 |= 0x30;
				break;
			case 5:
				pixel_0 |= 0x60;
				pixel_1 |= 0x60;
				break;
			case 6:
				pixel_0 |= 0xC0;
				pixel_1 |= 0xC0;
				break;
			case 7:
				pixel_0 |= 0xC0;
				pixel_1 |= 0xC0;
				break;
		}
	}
	else if (buf.button == 0x02) {
		pixel_0 &= 0x00;
		pixel_1 &= 0x00;
	}
	
	VRAM[(mouseX >> 3) + 80 * (mouseY - 1)] = pixel_0;
 	VRAM[(mouseX >> 3) + 80 * mouseY] = pixel_1;
	vga->VRAM[(mouseX >> 3) + 80 * (mouseY - 1)] = pixel_0;
	vga->VRAM[(mouseX >> 3) + 80 * mouseY] = pixel_1;
}
