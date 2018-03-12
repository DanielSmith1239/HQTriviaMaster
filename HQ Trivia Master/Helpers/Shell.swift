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
    ///Checks if System Integrity Protection is enabled.  If SIP is on, the app may not function properly
    static func sipCheck() -> Bool
    {
        return runCommand(cmd: "/usr/bin/csrutil", args: "status").output.first?.contains("enabled") ?? true
    }
    
    ///Returns the status of the two required files to make sure we're not going to run into any issues.
    static func checkForRequiredFiles() -> (hasConvert: Bool, hasTesseract: Bool)
    {
        let hasConvert = runCommand(cmd: "/usr/local/bin/convert", args: "").output.contains("Usage: convert [options ...] file [ [options ...] file ...] [options ...] file")
        let hasTesseract = runCommand(cmd: "/usr/local/bin/tesseract", args: "").output.contains("  /usr/local/bin/tesseract --help | --help-psm | --help-oem | --version")
        return (hasConvert, hasTesseract)
    }
    
    ///Runs Tesseract to convert the image to text
    static func convertImageToText(completion: @escaping (String?) -> Void)
    {
        shell("/usr/local/bin/convert", "\(NSTemporaryDirectory())hqTriviaMasterTemp.jpg", "-resize", "400%", "-type", "Grayscale", "\(NSTemporaryDirectory())/hqTriviaMasterTemp.tif", completion: {
            shell("/usr/local/bin/tesseract", "\(NSTemporaryDirectory())hqTriviaMasterTemp.tif", "output", completion: {
                DispatchQueue.main.async {
                    completion(try? String(contentsOf: FileManager.default.temporaryDirectory.appendingPathComponent("output.txt")))
                }
            })
        })
        
    }
    
    ///Asynchronously runs a command with the given inputs
    private static func shell(_ args: String..., completion: @escaping () -> Void)
    {
        let task = Process()
        if !HQTriviaMaster.debug
        {
            task.standardOutput = FileHandle()
            task.standardError = FileHandle()
        }
        task.launchPath = "/usr/bin/env"
        if #available(OSX 10.13, *)
        {
            task.currentDirectoryURL = FileManager.default.temporaryDirectory
        }
        else
        {
            task.currentDirectoryPath = "/" + FileManager.default.temporaryDirectory.pathComponents.filter { !$0.isEmpty && $0 != "/" }.joined(separator: "/")
        }
        task.arguments = args
        task.launch()
        task.terminationHandler = { _ in completion() }
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
        task.launchPath = "/usr/bin/env"
        task.arguments = [cmd] + args
        
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
