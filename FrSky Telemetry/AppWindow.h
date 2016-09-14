//
//  AppWindow.h
//  FrSky Telemetry
//
//  Created by Thomas Buck on 14.09.16.
//  Copyright © 2016 Thomas Buck. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppWindow : NSWindow

@property (weak) IBOutlet NSPopUpButton *portList;
@property (weak) IBOutlet NSButton *connectButton;
@property (weak) IBOutlet NSLevelIndicator *level1;
@property (weak) IBOutlet NSLevelIndicator *level2;
@property (weak) IBOutlet NSLevelIndicator *level3;
@property (weak) IBOutlet NSLevelIndicator *level4;
@property (unsafe_unretained) IBOutlet NSTextView *userData;

@end
