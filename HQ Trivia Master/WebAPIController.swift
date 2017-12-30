//
//  WebAPIController.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 10/31/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Foundation

class WebAPIController
{
    static func getWikipediaPage(for searchStr: String, completion: @escaping (String) -> ())
    {
        let url = TextController.getWikipediaUrl(forOption: searchStr)
        let request = URLRequest(url: url)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request)
        { data, response, error in
            guard let pageData = data else
            {
                print("error getting wiki page for: \(searchStr)")
                return
            }
            completion(String(data: pageData, encoding: .utf8) ?? "")
        }
        task.resume()
    }
    
    static func getGooglePage(for searchStr: String, completion: @escaping (String, Int) -> ())
    {
        if let url = TextController.getGoogleUrl(forQuestion: searchStr)
        {
            let request = URLRequest(url: url)
            let session = URLSession.shared
            
            let task = session.dataTask(with: request)
            { data, response, error in
                guard let pageData = data else
                {
                    print("error getting google page for: \(searchStr)")
                    return
                }
                do
                {
                    if let json = try JSONSerialization.jsonObject(with: pageData, options: []) as? [String: Any]
                    {
                        var snippets = ""
                        if let items = json["items"] as? [[String: Any]]
                        {
                            snippets = items.map ({ ($0["snippet"] as? String) ?? "" }).joined(separator: " ")
                            snippets +=  items.map ({ ($0["title"] as? String) ?? "" }).joined(separator: " ")
                        }
                        if let searchInfo = json["searchInformation"] as? [String: Any],
                            let results = searchInfo["totalResults"] as? String,
                            let numResults = Int(results),
                            numResults != 10
                        {
                            completion(snippets, numResults)
                        }
                        else
                        {
                            completion(NSAttributedString(html: pageData, baseURL: url, documentAttributes: nil)!.string, 0)
                        }
                    }
                    else
                    {
                        completion(NSAttributedString(html: pageData, baseURL: url, documentAttributes: nil)!.string, 0)
                    }
                }
                catch
                {
                    print(error)
                    completion(NSAttributedString(html: pageData, baseURL: url, documentAttributes: nil)!.string, 0)
                }
            }
            task.resume()
        }
        else
        {
            completion("", 0)
        }
    }
}
