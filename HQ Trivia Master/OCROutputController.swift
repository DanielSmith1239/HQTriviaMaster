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
    private static let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent("output.txt")
    
    static var outputText : String?
    {
        do
        {
            return try String(contentsOf: fileURL)
        }
        catch
        {
            print(error)
            return nil
        }
    }
}
