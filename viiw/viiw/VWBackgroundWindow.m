//
//  WWBackgroundWindow.m
//  viiw
//
//  Created by hideya kawahara on 2015/08/24.
//  Copyright (c) 2015年 hideya kawahara. All rights reserved.
//

#import "VWBackgroundWindow.h"

@implementation VWBackgroundWindow

- (id)initWithContentRect:(NSRect)contentRect
                styleMask:(NSUInteger)windowStyle
                  backing:(NSBackingStoreType)bufferingType
                    defer:(BOOL)deferCreation {

    self = [super initWithContentRect:contentRect
                            styleMask:NSBorderlessWindowMask
                              backing:bufferingType
                                defer:deferCreation];

    if (!self) {
        return nil;
    }

//    self.backgroundColor = [NSColor blackColor];

    self.frameOrigin = CGPointZero;
    NSSize mainScreenSize = [[NSScreen mainScreen] frame].size;
    mainScreenSize.height -= [[NSStatusBar systemStatusBar] thickness];
    self.contentSize = mainScreenSize;

    self.collectionBehavior =
        NSWindowCollectionBehaviorStationary |
        NSWindowCollectionBehaviorTransient |
        NSWindowCollectionBehaviorIgnoresCycle;

    [self setLevel:kCGDesktopWindowLevel];
    [self orderBack:self];

    return self;
}

- (BOOL)canBecomeMainWindow {
    return NO;
}

- (BOOL)canBecomeKeyWindow {
    return NO;
}

- (BOOL)acceptsFirstResponder {
    return NO;
}

@end
