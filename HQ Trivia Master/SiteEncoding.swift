//
//  SiteEncoding.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 10/31/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Foundation
import Cocoa

/**
 Determines what site will be searched for answers
 
 Contains a pretty name as well as a base URL
 */
struct SiteEncoding : Equatable, CustomStringConvertible, CustomDebugStringConvertible
{
    private let name : String
    private let url : URL?
    
    var description : String { return name }
    var debugDescription : String { return name + ": \(url?.absoluteString ?? "No URL")" }
    
    private init(name: String, url: URL?)
    {
        self.name = name
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
        //Your API key
        let apiKey = "AIzaSyD8_CHjjufyxzrW570qkuxrl5W3LsH3EFc"
        
        //Your Search Engine ID
        let searchEngineId = "006677768737737570095:raoebjow3iy"
        
        let url = URL(string: "https://www.googleapis.com/customsearch/v1?key=\(apiKey)&cx=\(searchEngineId)")
        return SiteEncoding(name: "Google - Custom Search", url: url)
    }()
}
