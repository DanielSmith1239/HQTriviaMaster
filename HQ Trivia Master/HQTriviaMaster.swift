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
}

