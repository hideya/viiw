//
//  WWBackgroundWindow.h
//  viiw
//
//  Created by hideya kawahara on 2015/08/24.
//  Copyright (c) 2015年 hideya kawahara. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface VWBackgroundWindow : NSWindow

- (BOOL)canBecomeMainWindow;
- (BOOL)canBecomeKeyWindow;
- (BOOL)acceptsFirstResponder;

@end
