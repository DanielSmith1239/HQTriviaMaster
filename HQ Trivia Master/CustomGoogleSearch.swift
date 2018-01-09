//
//  CustomGoogleSearch.swift
//  HQ Trivia Master
//
//  Created by Michael Schloss on 1/9/18.
//  Copyright © 2018 Daniel Smith. All rights reserved.
//

import Cocoa

class CustomGoogleSearch : NSViewController
{
    @IBOutlet private var apiKeyTextField : NSTextField!
    @IBOutlet private var searchEngineIDTextField : NSTextField!
    
    @IBAction private func confirm(sender: Any)
    {
        guard let window = view.window else { return }
        let apiKey = apiKeyTextField.stringValue
        let searchEngineID = searchEngineIDTextField.stringValue
        guard apiKey != "", searchEngineID != "" else
        {
            view.window?.shake()
            return
        }
        
        SiteEncoding.addGoogleAPICredentials(apiKey: apiKey, searchEngineID: searchEngineID)
        NSApplication.shared.mainWindow?.endSheet(window)
    }
    
    override func cancelOperation(_ sender: Any?)
    {
        guard let window = view.window else { return }
        NSApplication.shared.mainWindow?.endSheet(window)
    }
    
    @IBAction private func cancel(sender: Any)
    {
        cancelOperation(sender)
    }
}
