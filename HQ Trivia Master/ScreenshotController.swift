//
//  ScreenshotController.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 11/1/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Foundation
import AppKit

class ScreenshotController
{
    static let imagePath = "PATH-HERE/hqTriviaMasterTemp.jpg"
    
    static func takeScreenshot(vc: NSViewController, line: NSBox, completion: @escaping () -> ())
    {
        var displayCount: UInt32 = 0;
        var result = CGGetActiveDisplayList(0, nil, &displayCount)
        if (result != CGError.success)
        {
            print("error: \(result)")
            return
        }
        let allocated = Int(displayCount)
        let activeDisplays = UnsafeMutablePointer<CGDirectDisplayID>.allocate(capacity: allocated)
        result = CGGetActiveDisplayList(displayCount, activeDisplays, &displayCount)
        
        if (result != CGError.success)
        {
            print("error: \(result)")
            return
        }
        
        for i in 1...displayCount
        {
            let fileUrl = URL(fileURLWithPath: imagePath, isDirectory: true)
            let screenShot: CGImage = CGDisplayCreateImage(activeDisplays[Int(i - 1)], rect: getScreenshotRect(vc: vc, line: line))!
            let bitmapRep = NSBitmapImageRep(cgImage: screenShot)
            let jpegData = bitmapRep.representation(using: .jpeg, properties: [:])!
            
            do
            {
                try jpegData.write(to: fileUrl, options: .atomic)
            }
            catch
            {
                print("error: \(error)")
            }
            completion()
        }
    }
    
    private static func getScreenshotRect(vc: NSViewController, line: NSBox) -> CGRect
    {
        let view = vc.view
        return CGRect(x: view.window!.frame.origin.x, y: view.window!.frame.origin.y - view.bounds.height + 50, width: line.frame.origin.x, height: view.bounds.height)
    }
}
