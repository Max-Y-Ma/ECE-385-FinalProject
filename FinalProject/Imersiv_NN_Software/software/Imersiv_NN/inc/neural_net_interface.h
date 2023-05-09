#ifndef __NEURAL_NET_INTERFACE_H
#define __NEURAL_NET_INTERFACE_H

#include <stdio.h>
#include "system.h"
#include "memory_map.h"
#include "datatypes.h"
#include "vga_interface.h"
#include "altera_avalon_pio_regs.h"
#include "alt_types.h"
#include "sys/alt_irq.h"

// Declare a global variable to hold the edge capture value
volatile int edge_capture;

// Global Status Variable
int doneNeuralNetCompute;

// Interrupt Handler
#ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
static void handle_neural_network_interrupt(void* context)
#else
static void handle_neural_network_interrupt(void* context, alt_u32 id)
#endif
{
    // printf("Interrupt Handling!\n");
    // Cast context to edge_capture's type
    volatile int* edge_capture_ptr = (volatile int*) context;
    // Read the edge capture register on the button PIO.
    *edge_capture_ptr = IORD_ALTERA_AVALON_PIO_EDGE_CAP(CHARARCTER_IRQ_BASE);
    // Write to the edge capture register to reset it.
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(CHARARCTER_IRQ_BASE, 0x0);
    // Read the PIO to delay ISR exit
    IORD_ALTERA_AVALON_PIO_EDGE_CAP(CHARARCTER_IRQ_BASE);

    // Neural Network Done Computation
    doneNeuralNetCompute = TRUE;
}

/* Initialize the button_pio. */
static void init_neural_network_interrupt()
{
    printf("Initializing Neural Network Interrupt!\n");
    // Recast the edge_capture pointer
    void* edge_capture_ptr = (void*) &edge_capture;
    // Enable Neural Network Interrupt
    IOWR_ALTERA_AVALON_PIO_IRQ_MASK(CHARARCTER_IRQ_BASE, 0x1);
    // Reset the edge capture register
    IOWR_ALTERA_AVALON_PIO_EDGE_CAP(CHARARCTER_IRQ_BASE, 0x0);
    // Register the IRQ
    #ifdef ALT_ENHANCED_INTERRUPT_API_PRESENT
    alt_ic_isr_register(CHARARCTER_IRQ_IRQ_INTERRUPT_CONTROLLER_ID,
    CHARARCTER_IRQ_IRQ,
    handle_neural_network_interrupt,
    edge_capture_ptr, 0x0);
    #else
    alt_irq_register( BUTTON_PIO_IRQ,
    edge_capture_ptr,
    handle_button_interrupts );
    #endif
}

void NNTest();
void neuralNetTask();
void characterTest();
void loadImage(int index);
void transferCharacter(int index);

#endif /* __NEURAL_NET_INTERFACE_H */
