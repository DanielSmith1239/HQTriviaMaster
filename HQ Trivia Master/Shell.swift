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
    ///Checks if System Integrity Protection is enabled.  If SIP is on, tesseract doesn't function properly as the '/usr/local/bin/convert' is unavailable
    static func sipCheck() -> Bool
    {
        return runCommand(cmd: "/usr/bin/csrutil", args: "status").output.first?.contains("enabled") ?? true
    }
    
    ///Runs Tesseract to convert the image to text
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
    
    /**
     Taken from https://stackoverflow.com/a/29519615
     
     Runs a terminal command in the app's process so we can capture output
     */
    private static func runCommand(cmd: String, args: String...) -> (output: [String], error: [String], exitCode: Int32)
    {
        var output : [String] = []
        var error : [String] = []
        
        let task = Process()
        task.launchPath = cmd
        task.arguments = args
        
        let outpipe = Pipe()
        task.standardOutput = outpipe
        let errpipe = Pipe()
        task.standardError = errpipe
        
        task.launch()
        
        let outdata = outpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: outdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            output = string.components(separatedBy: "\n")
        }
        
        let errdata = errpipe.fileHandleForReading.readDataToEndOfFile()
        if var string = String(data: errdata, encoding: .utf8) {
            string = string.trimmingCharacters(in: .newlines)
            error = string.components(separatedBy: "\n")
        }
        
        task.waitUntilExit()
        let status = task.terminationStatus
        
        return (output, error, status)
    }
}
