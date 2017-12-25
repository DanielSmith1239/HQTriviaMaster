//
//  OCROutputController.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 11/2/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Foundation
class OCROutputController
{
    private static let fileUrl = "file://\(NSHomeDirectory())/Desktop/output.txt"
    
    static func getOutputText() -> String
    {
        do
        {
            let text = try String(contentsOf: URL(string: fileUrl)!)
            return text
        }
        catch
        {
            print(error)
            return ""
        }
    }
}
