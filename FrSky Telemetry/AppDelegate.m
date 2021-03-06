//
//  AppDelegate.m
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
#import "AppDelegate.h"

#include "frsky.h"
#include "serial.h"

@interface AppDelegate ()

@property (weak) IBOutlet AppWindow *window;

@end

@implementation AppDelegate

@synthesize window;

- (void)timerPolling:(NSTimer *)timer {
    telemetryPoll();
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    char **ports = getSerialPorts();
    
    if (ports[0] != NULL) {
        [window.portList removeAllItems];
    }
    
    int i;
    for (i = 0; ports[i] != NULL; i++) {
        NSString *s = [NSString stringWithUTF8String:ports[i]];
        [window.portList addItemWithTitle:s];
        if ([s isEqualToString:@"/dev/tty.usbserial-A100OZQ1"]) {
            [window.portList selectItemAtIndex:i];
        }
        free(ports[i]);
    }
    
    NSLog(@"Filled port list with %d items...", i);
    free(ports);
    
    NSLog(@"Scheduling serial port polling...");
    [NSTimer scheduledTimerWithTimeInterval:0.00005
                                     target:self
                                   selector:@selector(timerPolling:)
                                   userInfo:nil
                                    repeats:YES];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    NSLog(@"Cleaning up...");
    telemetryClose();
}

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)theApplication {
    return YES;
}

@end
