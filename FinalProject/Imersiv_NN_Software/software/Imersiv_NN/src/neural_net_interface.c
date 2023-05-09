#include "../inc/neural_net_interface.h"

static volatile struct NN_interface* neuralNet = (NN_interface*)IMERSIV_NET_AVL_INTERFACE_0_BASE;

#define DEBUG 0
#define NN_REFRESH_RATE 100

// 00000000000000000000000000000000 1
// 00000000000000000000000000000000 2 
// 00000000000000000000000000000000 3
// 00000000000000000000000000000000 4
// 00000000000000000000000000000000 5
// 00000000000000000000000000000000 6
// 00000000000000000000000000000000 7
// 00000000000000000000000000000000 8
// 00000000000111111000000000000000 9
// 00000000000000001111111111000000 10
// 00000000000000000000000011000000 11
// 00000000000000000000000011000000 12
// 00000000000000000000000110000000 13
// 00000000000000000000000110000000 14
// 00000000000000000000001100000000 15
// 00000000000000000000001000000000 16
// 00000000000000000000011000000000 17
// 00000000000000000000010000000000 18
// 00000000000000000000110000000000 19
// 00000000000000000001100000000000 20
// 00000000000000000001100000000000 21
// 00000000000000000011000000000000 22
// 00000000000000000110000000000000 23
// 00000000000000000110000000000000 24
// 00000000000000001110000000000000 25
// 00000000000000001110000000000000 26
// 00000000000000001100000000000000 27
// 00000000000000000000000000000000 28
static alt_u32 image7[IMG_HEIGHT] = {
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x003F0000,
        0x0001FF80,
        0x00000180,
        0x00000180,
        0x00000300,
        0x00000300,
        0x00000600,
        0x00000400,
        0x00000C00,
        0x00000800,
        0x00001800,
        0x00003000,
        0x00003000,
        0x00006000,
        0x0000C000,
        0x0000C000,
        0x0001C000,
        0x0001C000,
        0x00018000,
        0x00000000
};

// 00000000000000000000000000000000 1
// 00000000000000000000000000000000 2
// 00000000000000000000000000000000 3
// 00000000000000000110000000000000 4
// 00000000000000111111100000000000 5
// 00000000000001111001100000000000 6
// 00000000000011100001100000000000 7
// 00000000000011000001100000000000 8
// 00000000000000000011100000000000 9
// 00000000000000000011000000000000 10
// 00000000000000000111000000000000 11
// 00000000000000000110000000000000 12
// 00000000000000001100000000000000 13
// 00000000000000011100000000000000 14
// 00000000000000011000000000000000 15
// 00000000000000110000000000000000 16
// 00000000000000110000000000000000 17
// 00000000000001100000000000000000 18
// 00000000000011100000000000000000 19
// 00000000000011100000000000000000 20
// 00000000000011111111000111111100 21
// 00000000000001111111111111100000 22
// 00000000000000000011100000000000 23
// 00000000000000000000000000000000 24
// 00000000000000000000000000000000 25
// 00000000000000000000000000000000 26
// 00000000000000000000000000000000 27
// 00000000000000000000000000000000 28
static alt_u32 image2[IMG_HEIGHT] = {
        0x00000000,
        0x00000000,
        0x00000000,
        0x00006000,
        0x0003F800,
        0x00079800,
        0x000E1800,
        0x000C1800,
        0x00003800,
        0x00003000,
        0x00007000,
        0x00006000,
        0x0000C000,
        0x0001C000,
        0x00018000,
        0x00030000,
        0x00030000,
        0x00060000,
        0x000E0000,
        0x000E0000,
        0x000FF1FC,
        0x0007FFE0,
        0x00003800,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000
};

static alt_u32 image[IMG_HEIGHT] = {
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x00000000,
        0x0000F000,
        0x0003F800,
        0x0007FC00,
        0x000F0C00,
        0x001C0E00,
        0x00180700,
        0x00180F00,
        0x00180F80,
        0x00181F00,
        0x001C7F00,
        0x000FFE00,
        0x0003C600,
        0x00000600,
        0x00000600,
        0x00000400,
        0x00000400,
        0x00000600,
        0x00000600,
        0x00000600,
        0x00000600,
        0x00000000,
        0x00000000
};

// Test Memory R/W for Neural Net IP
void NNTest() {
    // R/W Memory Test: Image Register File
    alt_u32 checksum = 0, readsum = 0;

    for (int i = 0; i < IMG_HEIGHT; i++) {
        neuralNet->imgRegFile[i] = i + 1;
        checksum += i + 1;
    }

    for (int i = 0; i < IMG_HEIGHT; i++) {
        readsum += neuralNet->imgRegFile[i];
    }

    if (checksum != readsum) {
        printf ("Image Register File Checksum mismatch! Checksum: %x, Read-back Checksum: %x\n", checksum, readsum);
        while (1){};
    }
    else {
        printf ("Image Register File Checksum code passed! Checksum: %x, Read-back Checksum: %x\n", checksum, readsum);
    }

    // R Memory Test: Character Register
    alt_u32 character = neuralNet->charReg;
    printf("Character Register: %x\n", character);
    if (character > 0x09 || character < 0x00) {
        printf ("Invalid Character Register!\n\r");
        while (1){};
    }
    else {
        printf ("Valid Character Register!\n\r");
    }
}

// Test Specific Character in Neural Network
void characterTest() {
    if (doneNeuralNetCompute) {
        transferCharacter(0);
        printNeuralNetCharacterReg(0);
        doneNeuralNetCompute = FALSE;
    } 
    else {
        // Load 28x28 Test Image : Set Image Buffer
        for (int i = 0; i < IMG_HEIGHT; ++i) {
            neuralNet->imgRegFile[i] = image[i];
        }
    }
}

// Feed Data to the Neural Network Once per Frame (Adjust to per xxx amount of Frames?)
void neuralNetTask() {
#if DEBUG
    // characterTest();
#else
    static int numRun = 0;
    printf("Neural Network Task! Run: %d\n", numRun);
    int index = 0;
    while (index < NUM_CODES) {
        if (doneNeuralNetCompute) {
            // Next Image
            transferCharacter(index);
            printNeuralNetCharacterReg(index);
            doneNeuralNetCompute = FALSE;
            index++;
        } 
        else {
            // Load 28x28 Pixel Image
            loadImage(index);        
        }
    }
    numRun++;
#endif
}

// Set the Indexed 28x28 Pixel Character into the Image Buffer for Neural Network to Compute
void loadImage(int index) {
    // printf("Loading Image: %d\n", index);
    alt_u32 buf[IMG_HEIGHT];
    getImageVRAMBlock(index, buf);

    // Set Image Buffer
    for (int i = 0; i < IMG_HEIGHT; ++i) {
        neuralNet->imgRegFile[i] = buf[i];
    }
}

// Loads Character into VGA IP to Display
void transferCharacter(int index) {
    // printf("Transfer Character: %d\n", index);
    setNeuralNetCharacterRegs(index, neuralNet->charReg);
}
