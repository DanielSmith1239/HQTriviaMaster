//
//  SiteEncoding.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 10/31/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Foundation
import Cocoa

private let googleSearchAPIKeyConstant = "googleSearchAPIKey"
private let googleSearchSearchEngineIDConstant = "googleSearchSearchEngineID"

/**
 Determines what site will be searched for answers
 
 Contains a pretty name as well as a base URL
 */
struct SiteEncoding : Equatable, CustomStringConvertible, CustomDebugStringConvertible
{
    private static let keychain = KeychainSwift()
    
    private let name : String
    private let url : URL?
    private(set) var website : Website
    
    var description : String { return name }
    var debugDescription : String { return name + ": \(url?.absoluteString ?? "No URL")" }
    
    private init(name: String, website: Website, url: URL?)
    {
        self.name = name
        self.website = website
        self.url = url
    }
    
    /**
     This method returns a URL object that includes the given option in the string.
     
     **Programmer Notes:** This method may need to be modified with each new SiteEncoding added
     */
    func url(with option: String) -> URL?
    {
        guard let url = url else { return nil }
        guard let urlEncoded = option.urlEncoded(for: self) else { return nil }
        if self == SiteEncoding.google
        {
            guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else { return nil }
            components.queryItems = (components.queryItems ?? []) + [URLQueryItem(name: "q", value: urlEncoded)]
            return components.url
        }
        return url.appendingPathComponent(urlEncoded)
    }
    
    static func ==(lhs: SiteEncoding, rhs: SiteEncoding) -> Bool
    {
        return lhs.name == rhs.name
    }
    
    static let google : SiteEncoding = {
        guard let apiKey = keychain.get(googleSearchAPIKeyConstant), let searchEngineID = keychain.get(googleSearchSearchEngineIDConstant) else
        {
            return SiteEncoding(name: "Invalid Google Search.  Missing API Key or SearchEngineID", website: Google(), url: nil)
        }
        let url = URL(string: "https://www.googleapis.com/customsearch/v1?key=\(apiKey)&cx=\(searchEngineID)")
        var encoding = SiteEncoding(name: "Google - Custom Search", website: Google(), url: url)
        encoding.website.siteEncoding = encoding
        return encoding
    }()
}

//Extra methods for SiteEncoding verification and what-not
extension SiteEncoding
{
    ///Verifies the user has recently inputted Google CSE credentials.  If not, a critical alert is presented prompting for them
    static func checkGoogleAPICredentials(force: Bool = false)
    {
        if keychain.get(googleSearchAPIKeyConstant) == nil || keychain.get(googleSearchSearchEngineIDConstant) == nil || force
        {
            guard let window = (NSStoryboard(name: NSStoryboard.Name(rawValue: "Main"), bundle: nil).instantiateController(withIdentifier: NSStoryboard.SceneIdentifier(rawValue: "googleAlert")) as? NSWindowController)?.window else { return }
            NSApplication.shared.keyWindow?.beginCriticalSheet(window, completionHandler: nil)
        }
    }
    
    ///Stores the credentials into the user's Secure Keychain
    static func addGoogleAPICredentials(apiKey: String, searchEngineID: String)
    {
        keychain.set(apiKey, forKey: googleSearchAPIKeyConstant)
        keychain.set(searchEngineID, forKey: googleSearchSearchEngineIDConstant)
    }
}
