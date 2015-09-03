//
//  AppDelegate.m
//  viiw
//
//  Created by hideya kawahara on 2015/08/24.
//  Copyright (c) 2015年 hideya kawahara. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>

#import "AppDelegate.h"

//#define APPSTORE_VERSION

static NSString *const DefaultbackgroundKey = @"kBackgroundUrl";

@interface AppDelegate () {
}

@property (weak) IBOutlet NSWindow *window;
@property (weak) IBOutlet WebView *webView;
@property (weak) IBOutlet NSMenu *statusMenu;
@property (weak) IBOutlet NSMenuItem *statusMenuFirstItem;
@property (weak) IBOutlet NSPanel *infoPanel;
@property (weak) IBOutlet NSImageView *imageViewInfoPanel;
@property (weak) IBOutlet NSPanel *selectionInfoPanel;
@property (weak) IBOutlet NSImageView *imageViewSelectionInfoPanel;


@property NSStatusItem *statusItem;
@property NSUserDefaults *userDefaults;

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {

    self.statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    self.statusItem.image = [NSImage imageNamed:@"StatusBarIcon"];
    self.statusItem.menu = self.statusMenu;
    self.imageViewInfoPanel.image = [NSImage imageNamed:@"AppIcon"];
    self.imageViewSelectionInfoPanel.image = [NSImage imageNamed:@"AppIcon"];

    self.userDefaults = [NSUserDefaults standardUserDefaults];
    NSURL *backgroundUrl = [NSURL URLWithString:[self.userDefaults objectForKey:DefaultbackgroundKey]];
    if (backgroundUrl == nil) {
        NSString *url = [self getUrlFor:@"green-field"];
        [self.userDefaults setObject:url forKey:DefaultbackgroundKey];
        backgroundUrl = [NSURL URLWithString:url];
    }

    [self setupBackground:backgroundUrl];

    [NSEvent addGlobalMonitorForEventsMatchingMask:(NSMouseMovedMask | NSLeftMouseDraggedMask | NSRightMouseDraggedMask) handler:^(NSEvent *event) {
        if (self.statusMenuFirstItem.view.window != nil) { // if the menu is shown
            return;
        }
        NSPoint point = event.locationInWindow;
        int mx = point.x;
        int my = [NSScreen mainScreen].frame.size.height - point.y;
        NSString* invocationStr = [NSString stringWithFormat:@"fireMouseMoveEvent(%d,%d);", mx, my];
        [[self.webView windowScriptObject] evaluateWebScript:invocationStr];
    }];
}

- (void)setupBackground:(NSURL *)url {
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    [[[self webView] mainFrame] loadRequest:urlRequest];
    [self.window setContentView:self.webView];

    NSString* filepath = [[NSBundle mainBundle] pathForResource:@"bridge" ofType:@"js"];
    NSString* jscontents = [NSString stringWithContentsOfFile:filepath encoding:NSUTF8StringEncoding error:nil];
    [[self.webView windowScriptObject] evaluateWebScript:jscontents];
}

- (NSString *)getUrlFor:(NSString *)stemName {
    NSString* filepath = [[NSBundle mainBundle] pathForResource:stemName ofType:@"html"];
    NSLog(@"file opened '%@'", filepath);
    NSString *url = [NSString stringWithFormat:@"file://%@", filepath];
    return url;
}

- (void)switchBackgroundTo:(NSString *)htmlStem {
    NSString *urlStr = [self getUrlFor:htmlStem];
    [self.userDefaults setObject:urlStr forKey:DefaultbackgroundKey];
//    NSURL *backgroundUrl = [NSURL URLWithString:urlStr];
//    [self setupBackground:backgroundUrl];
    [self relaunch]; // FIXME
}

- (IBAction)switchToGreenField:(id)sender {
    [self switchBackgroundTo:@"green-field"];
}

- (IBAction)switchToCrif:(id)sender {
    [self switchBackgroundTo:@"criff"];
}

- (IBAction)switchToGinkgo:(id)sender {
    [self switchBackgroundTo:@"ginkgo"];
}

- (IBAction)switchToTreesLining:(id)sender {
    [self switchBackgroundTo:@"trees-lining"];
}

- (IBAction)switchToOcean:(id)sender {
    [self switchBackgroundTo:@"ocean"];
}

- (IBAction)switchToIllumination:(id)sender {
    [self switchBackgroundTo:@"illumination"];
}

- (IBAction)switchToWaves:(id)sender {
    [self switchBackgroundTo:@"waves"];
}

- (IBAction)selectBackgroundFile:(id)sender {
#ifdef APPSTORE_VERSION
    [self showWindowAtTopCenter:self.selectionInfoPanel];
#else
    NSOpenPanel *openPanel = [NSOpenPanel openPanel];
    NSArray *allowedFileTypes = [NSArray arrayWithObjects:@"html", nil];
    [openPanel setAllowedFileTypes:allowedFileTypes];
    NSInteger pressedButton = [openPanel runModal];
    if (pressedButton == NSModalResponseOK) {
        NSURL *url = [openPanel URL];
        NSLog(@"file opened '%@'", url.absoluteString);
        [self.userDefaults setObject:url.absoluteString forKey:DefaultbackgroundKey];
        [self relaunch]; // FIXME
    }
    else if (pressedButton == NSModalResponseCancel) {
        // canceled
    }
    else {
        // error
    }
#endif
}

- (IBAction)showInfoPanel:(id)sender {
    [self showWindowAtTopCenter:self.infoPanel];
}

- (void)showWindowAtTopCenter:(NSWindow *)window {
    NSPoint pos;
    pos.x = [[NSScreen mainScreen] visibleFrame].origin.x
            + [[NSScreen mainScreen] visibleFrame].size.width / 2
            - [window frame].size.width / 2;
    pos.y = [[NSScreen mainScreen] visibleFrame].origin.y
            + [[NSScreen mainScreen] visibleFrame].size.height;
    [window setFrameOrigin : pos];
    [NSApp activateIgnoringOtherApps:YES];
    [window makeKeyAndOrderFront:self];
}

- (IBAction)quitButtonPressed:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

- (void) relaunch {
    NSTask *task = [[NSTask alloc] init];
    NSMutableArray *args = [NSMutableArray array];
    [args addObject:@"-c"];
    [args addObject:[NSString stringWithFormat:@"sleep 1; open \"%@\"", [[NSBundle mainBundle] bundlePath]]];
    [task setLaunchPath:@"/bin/sh"];
    [task setArguments:args];
    [task launch];
    [[NSApplication sharedApplication] terminate:self];
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}




@end
