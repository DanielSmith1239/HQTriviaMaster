//
//  Shell.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 11/1/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Foundation

class Shell
{
    //Runs Tesseract to convert the image to text
    static func convertImageToText()
    {
        shell("/usr/local/bin/convert", "\(NSTemporaryDirectory())hqTriviaMasterTemp.jpg", "-resize", "400%", "-type", "Grayscale", "\(NSTemporaryDirectory())/hqTriviaMasterTemp.tif")
        if HQTriviaMaster.debug
        {
            print("Converted .tif: \(NSTemporaryDirectory())hqTriviaMasterTemp.tif")
        }
        shell("/usr/local/bin/tesseract", "\(NSTemporaryDirectory())hqTriviaMasterTemp.tif", "output")
    }
    
    private static func shell(_ args: String...)
    {
        let task = Process()
        task.launchPath = "/usr/bin/env"
        task.currentDirectoryURL = FileManager.default.temporaryDirectory
        task.arguments = args
        task.launch()
        task.waitUntilExit()
    }
}
