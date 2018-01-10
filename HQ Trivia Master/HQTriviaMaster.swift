//
//  AppDelegate.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 10/31/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Cocoa

@NSApplicationMain
class HQTriviaMaster : NSObject, NSApplicationDelegate
{
    static let debug = true
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool
    {
        return true
    }
    
    ///Shows the Google CSE edit window
    @IBAction func showPreferences(sender: Any)
    {
        (NSApplication.shared.keyWindow?.contentViewController as? ViewController)?.showGoogleAPIChangeWindow(sender: sender)
    }
}

