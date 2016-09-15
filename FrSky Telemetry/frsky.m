/*
 * FrSky Telemetry Protocol Host implementation.
 * Copyright 2016 by Thomas Buck <xythobuz@xythobuz.de>
 *
 * Based on the FrSky Telemetry Protocol documentation:
 * http://www.frsky-rc.com/download/down.php?id=128
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation, version 2.
 */

#import "AppWindow.h"

#include "serial.h"
#include "frsky.h"

const static unsigned char bufferSize = 19;
const static unsigned char userDataSize = 6;
const static unsigned char minPacketSize = 11;
const static unsigned char delimiter = 0x7E;
const static unsigned char escape = 0x7D;
const static unsigned char key = 0x20;
const static unsigned char idVoltageQuality = 0xFE;
const static unsigned char idUserData = 0xFD;
const static unsigned char idAlarm0 = 0xFC;
const static unsigned char idAlarm1 = 0xFB;
const static unsigned char idAlarm2 = 0xFA;
const static unsigned char idAlarm3 = 0xF9;
const static unsigned char idGetAlarms = 0xF8;

static unsigned char userData[userDataSize];
static unsigned char buffer[bufferSize];
static unsigned char bufferIndex = 0;
static int port = -1;
static AppWindow *parent = nil;

void telemetryDataHandler(unsigned char a1, unsigned char a2, unsigned char q1, unsigned char q2) {
    NSLog(@"Telemetry Data: %d %d %d %d", a1, a2, q1, q2);
    [[parent level1] setIntValue:q1];
    [[parent level2] setIntValue:q2];
    [[parent level3] setIntValue:a1];
    [[parent level4] setIntValue:a2];
    [[parent rssiRx] setStringValue:[NSString stringWithFormat:@"RSSI RX: %d%%", q1 * 100 / 255]];
    [[parent rssiTx] setStringValue:[NSString stringWithFormat:@"RSSI TX: %d%%", q2 * 100 / 255]];
    [[parent valueA1] setStringValue:[NSString stringWithFormat:@"A1 Value: %d", a1]];
    [[parent valueA2] setStringValue:[NSString stringWithFormat:@"A2 Voltage: %.2fV", a2 * (3.3 / 255.0) * (1.0 / 0.767)]];
    [[parent batteryLevel] setFloatValue:a2 * (3.3 / 255.0) * (1.0 / 0.767) * 100.0];
}

void telemetryAlarmThresholdHandler(struct AlarmThreshold alarm) {
    NSLog(@"Telemetry Alarm Threshold: %d %d %d %d", alarm.id, alarm.dir, alarm.level, alarm.value);
    [[parent alarmStatus] setStringValue:[NSString stringWithFormat:@"%d %d %d %d", alarm.id, alarm.dir, alarm.level, alarm.value]];
}

void telemetryUserDataHandler(const unsigned char* buf, unsigned char len) {
    NSString *s = [NSString stringWithCString:buf length:len];
    NSLog(@"Telemetry User Data: %d bytes: %@", len, s);
    [[parent userData] setString:[NSString stringWithFormat:@"%@\n%@", [[parent userData] string], s]];
}

void telemetryParent(AppWindow *aw) {
    parent = aw;
}

int telemetryInit(const char *portName) {
    for (unsigned char i = 0; i < userDataSize; i++) {
        userData[i] = 0;
    }

    for (unsigned char i = 0; i < bufferSize; i++) {
        buffer[i] = 0;
    }
    
    if (port != -1) {
        NSLog(@"Closed port to reopen...");
        serialClose(port);
    }
    
    port = serialOpen(portName, 9600);
    if (port == -1) {
        NSLog(@"Error opening serial port: %d", port);
        return -1;
    }
    
    NSLog(@"Serial port \"%s\" opened!", portName);
    return 0;
}

void telemetryClose(void) {
    if (port != -1) {
        NSLog(@"Closing serial port...");
        serialClose(port);
        port = -1;
    }
}

void telemetryPoll() {
    if ((port == -1) || (!serialHasChar(port))) {
        return;
    }

    unsigned char c;
    serialReadChar(port, (char *)&c);
    if (c == delimiter) {
        if (bufferIndex < minPacketSize) {
            bufferIndex = 0;
        }
        if (bufferIndex >= bufferSize) {
            bufferIndex = bufferSize - 1;
        }
        buffer[bufferIndex++] = c;
        if (bufferIndex > minPacketSize) {
            telemetryHandleMessage();
            bufferIndex = 0;
        }
    } else if ((bufferIndex > 0) && (bufferIndex < bufferSize)) {
        buffer[bufferIndex++] = c;
    }
}

void telemetryPollAlarms() {
    serialWriteChar(port, delimiter);
    telemetryWriteEscaped(idGetAlarms);
    for (unsigned char i = 0; i < 8; i++) {
        telemetryWriteEscaped(0);
    }
    serialWriteChar(port, delimiter);
}

void telemetrySetAlarm(struct AlarmThreshold alarm) {
    unsigned char id = (alarm.id == analog1_1) ? idAlarm0
            : ((alarm.id == analog1_2) ? idAlarm1
            : ((alarm.id == analog2_1) ? idAlarm2 : idAlarm3));
    serialWriteChar(port, delimiter);
    telemetryWriteEscaped(id);
    telemetryWriteEscaped(alarm.value);
    telemetryWriteEscaped(alarm.dir);
    telemetryWriteEscaped(alarm.level);
    for (unsigned char i = 0; i < 5; i++) {
        telemetryWriteEscaped(0);
    }
    serialWriteChar(port, delimiter);
}

void telemetryWriteEscaped(unsigned char v) {
    if ((v == delimiter) || (v == escape)) {
        v ^= key;
        serialWriteChar(port, escape);
    }
    serialWriteChar(port, v);
}

void telemetryHandleMessage() {
    if ((buffer[0] != delimiter) || (buffer[bufferIndex - 1] != delimiter)) {
        NSLog(@"Telemetry: invalid packet begin/end!");
        return;
    }

    // Fix escaped bytes
    for (unsigned char i = 0; i < (bufferIndex - 1); i++) {
        if (buffer[i] == escape) {
            buffer[i] = buffer[i + 1] ^ key;
            for (unsigned char j = i + 1; j < (bufferIndex - 1); j++) {
                buffer[j] = buffer[j + 1];
            }
            bufferIndex--;
        }
    }

    if (buffer[1] == idVoltageQuality) {
        telemetryDataHandler(buffer[2], buffer[3], buffer[4], buffer[5]);
    } else if (buffer[1] == idUserData) {
        unsigned char len = buffer[2];
        if (len > userDataSize) {
            len = userDataSize;
        }
        for (unsigned char i = 0; i < len; i++) {
            userData[i] = buffer[i + 4];
        }
        if (len > 0) {
            telemetryUserDataHandler(userData, len);
        }
    } else if ((buffer[1] == idAlarm0) || (buffer[1] == idAlarm1)
            || (buffer[1] == idAlarm2) || (buffer[1] == idAlarm3)) {
        enum AnalogValue v = (buffer[1] == idAlarm0) ? analog1_1
                : ((buffer[1] == idAlarm1) ? analog1_2
                : ((buffer[1] == idAlarm2) ? analog2_1 : analog2_2));
        struct AlarmThreshold at = { v, (enum GreaterLessThan)buffer[3], (enum AlarmLevel)buffer[4], buffer[2] };
        telemetryAlarmThresholdHandler(at);
    } else {
        NSLog(@"Unexpected ID!");
    }
}

