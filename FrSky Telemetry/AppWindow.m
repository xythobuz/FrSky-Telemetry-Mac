//
//  AppWindow.m
//  FrSky Telemetry
//
// ----------------------------------------------------------------------------
// "THE BEER-WARE LICENSE" (Revision 42):
// <xythobuz@xythobuz.de> wrote this file.  As long as you retain this notice
// you can do whatever you want with this stuff. If we meet some day, and you
// think this stuff is worth it, you can buy me a beer in return.   Thomas Buck
// ----------------------------------------------------------------------------
//

#import "AppWindow.h"

#include "frsky.h"

@implementation AppWindow

@synthesize portList, connectButton, level1, level2, level3, level4, userData, rssiRx, rssiTx, valueA1, valueA2, batteryLevel, alarmStatus;

- (IBAction)connectClicked:(id)sender {
    telemetryParent(self);
    if ([connectButton.title isEqualToString:@"Connect"]) {
        int result = telemetryInit([[portList selectedItem].title cStringUsingEncoding:NSUTF8StringEncoding]);
        if (result == 0) {
            [connectButton setTitle:@"Disconnect"];
            [userData setString:@""];
            telemetryPollAlarms();
        }
    } else {
        telemetryClose();
        [connectButton setTitle:@"Connect"];
    }
}

- (IBAction)setAlarms:(id)sender {
    struct AlarmThreshold alarm1 = { analog2_1, less, red, 220 };
    struct AlarmThreshold alarm2 = { analog2_2, less, orange, 225 };
    telemetrySetAlarm(alarm1);
    telemetrySetAlarm(alarm2);
}

- (IBAction)resetAlarms:(id)sender {
    struct AlarmThreshold alarm1 = { analog2_1, less, disable, 0 };
    struct AlarmThreshold alarm2 = { analog2_2, less, disable, 0 };
    telemetrySetAlarm(alarm1);
    telemetrySetAlarm(alarm2);
}

- (IBAction)pollAlarms:(id)sender {
    telemetryPollAlarms();
}

@end
