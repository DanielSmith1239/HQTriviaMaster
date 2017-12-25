//
//  TerminalController.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 11/1/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Foundation
class TerminalController
{
    static func getImageText()
    {
        shell("/usr/local/bin/convert", "hqTriviaMasterTemp.jpg", "-resize", "400%", "-type", "Grayscale", "hqTriviaMasterTemp.tif")
        shell("/usr/local/bin/tesseract", "hqTriviaMasterTemp.tif", "output")
    }
    
    @discardableResult
    private static func shell(_ args: String...) -> Int32 {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.currentDirectoryURL = URL(fileURLWithPath: "\(NSHomeDirectory())/Desktop")
        task.arguments = args
        task.launch()
        task.waitUntilExit()
        return task.terminationStatus
    }
}
