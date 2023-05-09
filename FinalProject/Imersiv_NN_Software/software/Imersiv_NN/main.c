// Imersiv Net 
// Author : Max Ma
// Contact : maxma2@illinois.edu
// Date : 4/19/2023

#include <stdio.h>
#include "altera_avalon_spi.h"
#include "altera_avalon_spi_regs.h"
#include "altera_avalon_pio_regs.h"
#include "sys/alt_irq.h"
#include "inc/memory_map.h"
#include "inc/test.h"
#include "inc/neural_net_interface.h"
#include "src/usb_kb/GenericMacros.h"
#include "src/usb_kb/GenericTypeDefs.h"
#include "src/usb_kb/HID.h"
#include "src/usb_kb/MAX3421E.h"
#include "src/usb_kb/transfer.h"
#include "src/usb_kb/usb_ch9.h"
#include "src/usb_kb/USB.h"

extern HID_DEVICE hid_device;

static BYTE addr = 1;
const char* const devclasses[] = { " Uninitialized", " HID Keyboard", " HID Mouse", " Mass storage" };

static alt_u8* keys = (alt_u8*)KEY_BASE;

// Function Prototypes
BYTE GetDriverandReport();

int main() {
	BYTE rcode;
	BOOT_MOUSE_REPORT buf;		//USB mouse report

	BYTE runningdebugflag = 0; 	//flag to dump out a bunch of information when we first get to USB_STATE_RUNNING
	BYTE errorflag = 0; 		//flag once we get an error device so we don't keep dumping out state info
	BYTE device;

	alt_32 mouseX = 0;
	alt_32 mouseY = 0;
	alt_8 sensitvity = 1;

	initTest();
	VGAClear();
	printf("Initializing MAX3421E...\n");
	MAX3421E_init();
	printf("Initializing USB...\n");
	USB_init();
	init_neural_network_interrupt();
	while (1) {
		/// Neural Net Tasks ///
		if (*keys == 0x02) {
			neuralNetTask();
		}

		if (*keys == 0x01) {
			VGAClear();
		}

		/// USB Tasks ///
		VGATask(buf, mouseX, mouseY);
		MAX3421E_Task();
		// usleep(1000);
		USB_Task();
		if (GetUsbTaskState() == USB_STATE_RUNNING) {
			if (!runningdebugflag) {
				runningdebugflag = 1;
				device = GetDriverandReport();
			} else if (device == 2) {
				// Check more mouse data
				rcode = mousePoll(&buf);
				if (rcode == hrNAK) {
				 	//NAK means no new data
				 	continue;
				} else if (rcode) {
				 	printf("Rcode: ");
				 	printf("%x \n", rcode);
				 	continue;
				}
				// Process Mouse Data to VGA Interface
				mouseTask(&buf, &mouseX, &mouseY, &sensitvity);
			}
		} else if (GetUsbTaskState() == USB_STATE_ERROR) {
			if (!errorflag) {
				errorflag = 1;
				printf("USB Error State\n");
			}
		} else {
			printf("USB task state: ");
			printf("%x\n", GetUsbTaskState());
			if (runningdebugflag) {	//previously running, reset USB hardware just to clear out any funky state, HS/FS etc
				runningdebugflag = 0;
				MAX3421E_init();
				USB_init();
			}
			errorflag = 0;
		}
	}

	return 0;
}

BYTE GetDriverandReport() {
	BYTE i;
	BYTE rcode;
	BYTE device = 0xFF;
	BYTE tmpbyte;

	DEV_RECORD* tpl_ptr;
	printf("Reached USB_STATE_RUNNING (0x40)\n");
	for (i = 1; i < USB_NUMDEVICES; i++) {
		tpl_ptr = GetDevtable(i);
		if (tpl_ptr->epinfo != NULL) {
			printf("Device: %d", i);
			printf("%s \n", devclasses[tpl_ptr->devclass]);
			device = tpl_ptr->devclass;
		}
	}
	//Query rate and protocol
	rcode = XferGetIdle(addr, 0, hid_device.interface, 0, &tmpbyte);
	if (rcode) {   //error handling
		printf("GetIdle Error. Error code: ");
		printf("%x \n", rcode);
	} else {
		printf("Update rate: ");
		printf("%x \n", tmpbyte);
	}
	printf("Protocol: ");
	rcode = XferGetProto(addr, 0, hid_device.interface, &tmpbyte);
	if (rcode) {   //error handling
		printf("GetProto Error. Error code ");
		printf("%x \n", rcode);
	} else {
		printf("%d \n", tmpbyte);
	}
	return device;
}
