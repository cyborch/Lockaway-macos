//
//  AppDelegate.swift
//  Lockaway
//
//  Created by Anders Borch on 8/28/17.
//  Copyright © 2017 Anders Borch. All rights reserved.
//

import Cocoa
import XCGLogger

let log = XCGLogger.default

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var pair: NSWindowController?
    
    var services: [Service] = []

    enum InterfaceStyle: String {
        case dark, light
        
        init() {
            let type = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") ?? "Light"
            self = InterfaceStyle(rawValue: type.lowercased())!
        }
    }
    
    var statusItem: NSStatusItem = {
        let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
        let style = InterfaceStyle()
        switch style {
        case .light:
            statusItem.image = NSImage(named: "small-lock")
        case .dark:
            statusItem.image = NSImage(named: "small-lock-light")
        }
        let menu = NSMenu()
        
        menu.addItem(NSMenuItem(title: "Start Screensaver",
                                action: #selector(startSaver),
                                keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Pair Device",
                                action: #selector(showPairing),
                                keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Unpair All Devices",
                                action: #selector(unpairAll),
                                keyEquivalent: ""))
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit",
                                action: #selector(terminate),
                                keyEquivalent: "q"))
        
        statusItem.menu = menu
        
        return statusItem
    }()
    
    var powerManager = PowerManager()

    func showFailed() {
        let alert = NSAlert()
        alert.addButton(withTitle: "OK")
        alert.messageText = "Starting screensaver failed."
        alert.informativeText = "Neither screensaver nor powersave could be started. " +
        "Ensure that powersave or screensaver is enabled in Settings."
        alert.alertStyle = .critical
        alert.runModal()
    }
    
    func showPairing() {
        guard let screen = NSScreen.main() else { return }
        let main = NSStoryboard(name: "Pair", bundle: Bundle.main)
        pair = main.instantiateInitialController() as? NSWindowController
        let center = NSPoint(x: screen.frame.width / 2.0, y: screen.frame.height / 2.0)
        guard let frame = pair?.window?.frame else { return }
        let origin = NSPoint(x: center.x - frame.width / 2.0, y: center.y + frame.height / 2.0)
        pair?.window?.setFrameTopLeftPoint(origin)
        pair?.showWindow(nil)
        pair?.window?.orderFrontRegardless()
    }
    
    func startSaver() {
        // Use screensaver when available
        if !powerManager.startSaver() {
            // Use system sleep when screensaver isn't available
            if !powerManager.startSleep() {
                // Show error message when neither is available
                showFailed()
            }
        }
    }
    
    func unpairAll() {
        let alert = NSAlert()
        alert.alertStyle = .warning
        alert.messageText = "Unpair all devices?"
        alert.informativeText = "This will disable remote lock from all paired devices."
        alert.addButton(withTitle: "Cancel")
        alert.addButton(withTitle: "Unpair")
        let button = alert.runModal()
        if button == NSAlertSecondButtonReturn {
            log.info("Unprairing all devices")
            let ud = UserDefaults.standard
            ud.removeObject(forKey: "SocketID")
            ud.synchronize()
            showPairing()
        }
    }
    
    func terminate() {
        NSApplication.shared().terminate(nil)
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        //unpairAll()
        log.setup(level: .debug, showThreadName: true, showLevel: true, showFileNames: true, showLineNumbers: true, writeToFile: nil, fileLevel: .none)

        let ud = UserDefaults.standard
        if ud.object(forKey: "SocketID") == nil {
            showPairing()
        } else if let ids = ud.object(forKey: "SocketID") as? [String] {
            for id in ids {
                let service = Service(id: id)
                service.connect()
                services.append(service)
            }
        }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

