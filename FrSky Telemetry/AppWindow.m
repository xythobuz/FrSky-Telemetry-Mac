//
//  AppWindow.m
//  FrSky Telemetry
//
//  Created by Thomas Buck on 14.09.16.
//  Copyright © 2016 Thomas Buck. All rights reserved.
//

#import "AppWindow.h"

#include "frsky.h"

@implementation AppWindow

@synthesize portList, connectButton, level1, level2, level3, level4, userData;

- (IBAction)connectClicked:(id)sender {
    telemetryParent(self);
    if ([connectButton.title isEqualToString:@"Connect"]) {
        int result = telemetryInit([[portList selectedItem].title cStringUsingEncoding:NSUTF8StringEncoding]);
        if (result == 0) {
            [connectButton setTitle:@"Disconnect"];
            [userData setString:@""];
        }
    } else {
        telemetryClose();
        [connectButton setTitle:@"Connect"];
    }
}

@end
