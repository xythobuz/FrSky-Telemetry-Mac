/*
 * FrSky Telemetry Protocol Host implementation.
 * Copyright 2016 by Thomas Buck <xythobuz@xythobuz.de>
 *
 * Based on the FrSky Telemetry Protocol documentation:
 * http://www.frsky-rc.com/download/down.php?id=128
 *
 * ----------------------------------------------------------------------------
 * "THE BEER-WARE LICENSE" (Revision 42):
 * <xythobuz@xythobuz.de> wrote this file.  As long as you retain this notice
 * you can do whatever you want with this stuff. If we meet some day, and you
 * think this stuff is worth it, you can buy me a beer in return.   Thomas Buck
 * ----------------------------------------------------------------------------
 */

#ifndef __FRSKY_H__
#define __FRSKY_H__

#import <Cocoa/Cocoa.h>

enum AnalogValue {
    analog1_1 = 0,
    analog1_2 = 1,
    analog2_1 = 2,
    analog2_2 = 3
};

enum GreaterLessThan {
    less = 0,
    greater = 1
};

enum AlarmLevel {
    disable = 0,
    yellow = 1,
    orange = 2,
    red = 3
};

struct AlarmThreshold {
    enum AnalogValue id;
    enum GreaterLessThan dir;
    enum AlarmLevel level;
    unsigned char value;
};

void telemetryParent(AppWindow *aw);
int telemetryInit(const char *portName);
void telemetryClose(void);
void telemetryPoll();
void telemetryPollAlarms();
void telemetrySetAlarm(struct AlarmThreshold alarm);

void telemetryHandleMessage();
void telemetryWriteEscaped(unsigned char v);

#endif // __FRSKY_H__

