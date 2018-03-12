//
//  ScreenshotController.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 11/1/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import AppKit

class ScreenshotController
{
    static private let imagePath = "\(NSTemporaryDirectory())hqTriviaMasterTemp.jpg"
    
    /**
     Takes a screenshot given a rectangle
     - Parameter inRect: An `NSRect` that describes the location to take the screenshot
     - Parameter completion: A closure called when the screenshot has been written to disk
     */
    static func takeScreenshot(inRect: NSRect, completion: @escaping () -> Void)
    {
        //ATTENTION: Quartz works in a different coordinate system than Cocoa
        //Quartz's coordinate systems starts at the top-left
        //While Cocoa starts at the bottom left.  The next lines convert coordinate spaces
        var rect = inRect
        rect.origin.y = (NSScreen.main?.frame.maxY ?? 0.0) - rect.maxY
        
        var displayCount : UInt32 = 0
        var result = CGGetActiveDisplayList(0, nil, &displayCount)
        guard result == .success else
        {
            print("Unexpected display count.  Underlying error: \(result)")
            return
        }
        let allocated = Int(displayCount)
        let activeDisplays = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: allocated)
        result = CGGetActiveDisplayList(displayCount, activeDisplays, &displayCount)
        guard result == .success else
        {
            print("Unexpected display list.  Underlying error: \(result)")
            return
        }
        
        for i in 1...displayCount
        {
            let fileUrl = URL(fileURLWithPath: imagePath)
            
            guard let screenShot = CGDisplayCreateImage(activeDisplays[Int(i - 1)], rect: NSRectToCGRect(rect)) else { continue }
            let bitmapRep = NSBitmapImageRep(cgImage: screenShot)
            guard let jpegData = bitmapRep.representation(using: .jpeg, properties: [:]) else { continue }
            do
            {
                try jpegData.write(to: fileUrl, options: .atomic)
            }
            catch
            {
                print("Could not write screenshot to disk.  Underlying error: \(error)")
                continue
            }
            completion()
        }
    }
}
