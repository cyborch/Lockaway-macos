//
//  AppDelegate.swift
//  Lockaway Helper
//
//  Created by Anders Borch on 9/1/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        var pathComponents = NSString(string: Bundle.main.bundlePath).pathComponents
        pathComponents.removeLast(4)
        let path = NSString.path(withComponents: pathComponents)
        NSWorkspace.shared().launchApplication(path)
        NSApp.terminate(nil)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
    }
}
