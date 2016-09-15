//
//  AppWindow.h
//  FrSky Telemetry
//
// ----------------------------------------------------------------------------
// "THE BEER-WARE LICENSE" (Revision 42):
// <xythobuz@xythobuz.de> wrote this file.  As long as you retain this notice
// you can do whatever you want with this stuff. If we meet some day, and you
// think this stuff is worth it, you can buy me a beer in return.   Thomas Buck
// ----------------------------------------------------------------------------
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
@property (weak) IBOutlet NSTextField *rssiRx;
@property (weak) IBOutlet NSTextField *rssiTx;
@property (weak) IBOutlet NSTextField *valueA1;
@property (weak) IBOutlet NSTextField *valueA2;
@property (weak) IBOutlet NSLevelIndicator *batteryLevel;
@property (weak) IBOutlet NSTextField *alarmStatus;

@end
