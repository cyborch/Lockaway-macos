//
//  PowerManager.m
//  Lockstep
//
//  Created by Anders Borch on 8/12/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

#import "PowerManager.h"
@import IOKit;
#import <IOKit/pwr_mgt/IOPMLib.h>
#import <IOKit/IOMessage.h>
@import ScreenSaver;
#import "ScreenSaverControl.h"

@interface PowerManager () {
    id<ScreenSaverControl> _controller;
}

@end

@implementation PowerManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _controller = [ScreenSaverController controller];
    }
    return self;
}

- (BOOL)startSaver
{
    // If the saver is already front do nothing
    if ([_controller screenSaverIsRunning]) { return NO; }
    
    // Can saver start?
    if (![_controller screenSaverCanRun]) { return NO; }
    
    // Start the saver
    [_controller screenSaverStartNow];
    return YES;
}

- (BOOL)startSleep
{
    mach_port_t masterPort = 0;
    io_connect_t ioPort = 0;
    
    if (IOPMSleepEnabled()) {
        IOMasterPort(MACH_PORT_NULL, &masterPort);
        if (!masterPort) { return NO; }
        ioPort = IOPMFindPowerManagement(masterPort);
        if (ioPort) {
            if (IOPMSleepSystem(ioPort)) {
                NSLog(@"Cannot sleep machine (sleep failed).\n");
                return NO;
            }
        }
    } else {
        NSLog(@"Cannot sleep machine (not supported).\n");
        return NO;
    }
    return YES;
}


@end
