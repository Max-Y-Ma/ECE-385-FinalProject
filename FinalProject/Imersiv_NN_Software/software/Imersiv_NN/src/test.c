#include "../inc/test.h"

int initTest() {
    printf("Running Declared Tests...\n");
    VGATest();
    NNTest();

    return 0;
}

void blink(int duration) {
    volatile unsigned int* leds = (unsigned int*)LEDS_BASE;
    *leds = 0;

    *leds |= 0x01;
    usleep(duration);
    *leds &= ~0x01;
    usleep(duration);
}
