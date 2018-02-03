//
//  CustomGoogleSearch.swift
//  HQ Trivia Master
//
//  Created by Michael Schloss on 1/9/18.
//  Copyright © 2018 Daniel Smith. All rights reserved.
//

import Cocoa

/**
 Prompts the user to input their Google CSE credentials
 */
class CustomGoogleSearch : NSViewController
{
    @IBOutlet private var apiKeyTextField : NSTextField!
    {
        didSet
        {
            apiKeyTextFields.append(apiKeyTextField)
        }
    }
    @IBOutlet private var searchEngineIDTextField : NSTextField!
    @IBOutlet private var stackView : NSStackView!
    private var apiKeyTextFields = [NSTextField]()
    
    @IBAction private func confirm(sender: Any)
    {
        guard let window = view.window else { return }
        let apiKeys = apiKeyTextFields.map { $0.stringValue }
        let searchEngineID = searchEngineIDTextField.stringValue
        var allEmpty = true
        for apiKey in apiKeys where apiKey != ""
        {
            allEmpty = false
        }
        if allEmpty || searchEngineID == ""
        {
            view.window?.shake()
            return
        }
        SiteEncoding.addGoogleAPICredentials(apiKeys: apiKeys, searchEngineID: searchEngineID)
        NSApplication.shared.mainWindow?.endSheet(window)
    }
    
    @IBAction private func addAPIKey(sender: Any)
    {
        view.window?.animations.removeAll()
        let newAPITextField = NSTextField()
        newAPITextField.placeholderString = "API Key"
        apiKeyTextFields.append(newAPITextField)
        stackView.insertArrangedSubview(newAPITextField, at: apiKeyTextFields.count)
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
