//
//  AppDelegate.swift
//  SwOsxTest
//
//  Created by hideya kawahara on 2/6/16.
//  Copyright © 2016 hideya. All rights reserved.
//

import Cocoa
import WebKit

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    @IBOutlet weak var webView: WebView!
    @IBOutlet weak var statusMenu: NSMenu!
    @IBOutlet weak var infoPanel: NSPanel!
    @IBOutlet weak var imageViewInfoPanel: NSImageView!
    @IBOutlet weak var selectionInfoPanel: NSPanel!
    @IBOutlet weak var imageViewSelectionInfoPanel: NSImageView!

    private let defaultBackgroundKey = "kBackgroundUrl"
    private let backgroundFilenames = [
        "samples/green-field/index",
        "samples/cliff-view/index",
        "samples/poppy-flowers/index",
        "samples/winter-trees/index",
        "samples/sunny-beach/index",
        "samples/waves/index",
    ]
    private let projectWebSiteUrl = "http://hideya.github.io/viiw/"

    private let statusItem: NSStatusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    private let userDefaults: NSUserDefaults = NSUserDefaults.standardUserDefaults()


    func applicationDidFinishLaunching(aNotification: NSNotification) {

        statusItem.image = NSImage.init(named: "StatusBarIcon")
        statusItem.menu = statusMenu
        imageViewInfoPanel.image = NSImage.init(named: "AppIcon")
        imageViewSelectionInfoPanel.image = NSImage.init(named: "AppIcon")

        setupBackground()
        
        NSEvent.addGlobalMonitorForEventsMatchingMask([.MouseMovedMask, .LeftMouseDraggedMask, .RightMouseDraggedMask]) {event in
            let point = event.locationInWindow
            let mx = point.x
            let my = NSScreen.mainScreen()!.frame.size.height - point.y
            let invocationStr = "fireMouseMoveEvent(\(mx),\(my));"
            self.webView.windowScriptObject.evaluateWebScript(invocationStr)
        }
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

    private func setupBackground() {
//        let urlString = getUrlStringFor(backgroundFilenames[0])
        let urlString = userDefaults.stringForKey(defaultBackgroundKey) ?? getUrlStringFor(backgroundFilenames[0])
        print("opening: \(urlString)")
        let urlOp = NSURL.init(string: urlString)
        guard let url = urlOp else {
            return
        }

        webView.shouldUpdateWhileOffscreen = false
        let urlRequest = NSURLRequest.init(URL: url)
        webView.mainFrame.loadRequest(urlRequest)

        let filepath = NSBundle.mainBundle().pathForResource("bridge", ofType: "js")!
        let jscontents = try? NSString.init(contentsOfFile: filepath, encoding: NSUTF8StringEncoding)
        webView.windowScriptObject.evaluateWebScript(jscontents! as String)
    }

    private func getUrlStringFor(nameStem: String) -> String {
        let filepath = NSBundle.mainBundle().pathForResource(nameStem, ofType: "html")!
        let url = "file://\(filepath)"
        return url
    }

    private func relaunch() {
        let task = NSTask()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "sleep 1; open \"\(NSBundle.mainBundle().bundlePath)\""]
        task.launch()
        NSApplication.sharedApplication().terminate(self)
    }
    
    @IBAction func switchBackground(sender: AnyObject) {
        let tag = (sender as? NSMenuItem)?.tag
        let urlStr = getUrlStringFor(backgroundFilenames[tag!])
        userDefaults.setObject(urlStr, forKey: defaultBackgroundKey)
//        setupBackground()
        relaunch() // FIXME
    }

    @IBAction func selectBackgroundFile(sender: AnyObject) {
        let openPanel = NSOpenPanel()
        openPanel.allowedFileTypes = ["html"]
        let buttonPressed = openPanel.runModal()
        if buttonPressed == NSModalResponseOK {
            let urlStr = openPanel.URL!.absoluteString
            print("opening: \(urlStr)")
            userDefaults.setObject(urlStr, forKey: defaultBackgroundKey)
//            setupBackground()
            relaunch() // FIXME
        }
        else if buttonPressed == NSModalResponseCancel {
            // canceled
        }
        else {
            // error
        }
    }

    @IBAction func showInfoPanel(sender: AnyObject) {
        let xRelativeToScreen = statusItem.button!.window!.convertRectToScreen(statusItem.button!.bounds).origin.x
        let infoWindowWidth = infoPanel.frame.size.width
        let mainScreenHeight = NSScreen.mainScreen()!.visibleFrame.size.height
        infoPanel.setFrameOrigin(CGPoint(x: xRelativeToScreen - infoWindowWidth - 10, y: mainScreenHeight))

        NSApp.activateIgnoringOtherApps(true)
        infoPanel.makeKeyAndOrderFront(self)
    }

    @IBAction func showMoreInfo(sender: AnyObject) {
        NSWorkspace.sharedWorkspace().openURL(NSURL.init(string: projectWebSiteUrl)!)
        infoPanel.close()
        selectionInfoPanel.close()
    }

    @IBAction func quitButtonPressed(sender: AnyObject) {
        NSApplication.sharedApplication().terminate(self)
    }
}
