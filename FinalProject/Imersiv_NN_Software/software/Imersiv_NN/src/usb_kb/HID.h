/* HID support header */

#ifndef __HID_h_
#define __HID_h_

#pragma once

#include "GenericTypeDefs.h"

/* HID device structure */
typedef struct HID_DEVICE{
	BYTE addr;
	BYTE interface;
} HID_DEVICE;

/* Boot mouse report 8 bytes */
typedef struct BOOT_MOUSE_REPORT{
	BYTE button;
	BYTE Xdispl;
	BYTE Ydispl;
	BYTE bytes3to7[5];   //optional bytes
} BOOT_MOUSE_REPORT;

/* boot keyboard report 8 bytes */
typedef struct BOOT_KBD_REPORT{
	BYTE mod;
	BYTE reserved;
	BYTE keycode[6];
} BOOT_KBD_REPORT;

/* Function prototypes */
BOOL HIDMProbe(BYTE address, DWORD flags);
BOOL HIDKProbe(BYTE address, DWORD flags);
void HID_init(void);
BYTE mousePoll(BOOT_MOUSE_REPORT* buf);
BYTE kbdPoll(BOOT_KBD_REPORT* buf);
BOOL HIDMEventHandler(BYTE addr, BYTE event, void *data, DWORD size);
BOOL HIDKEventHandler(BYTE addr, BYTE event, void *data, DWORD size);
#endif // _HID_h_
