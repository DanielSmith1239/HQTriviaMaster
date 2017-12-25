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
    
    static func getGoogleNumSearchResults(for searchStr: String, completion: @escaping (Int) -> ())
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
                    if let json = try JSONSerialization.jsonObject(with: pageData, options: []) as? [String: Any],
                        let searchInfo = json["searchInformation"] as? [String: Any],
                        let results = searchInfo["totalResults"] as? Int
                    {
                        completion(results)
                    }
                    else
                    {
                        completion(0)
                    }
                }
                catch
                {
                    print(error)
                    completion(0)
                }
            }
            task.resume()
        }
        else
        {
            completion(0)
        }
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
//                sleep(4) // Sleep for 4 seconds

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
    
    static func getDiffenPage(for searchStr: String, completion: @escaping (String) -> ())
    {
        if let url = TextController.getDiffenUrl(forOption: searchStr)
        {
            let request = URLRequest(url: url)
            let session = URLSession.shared
            
            let task = session.dataTask(with: request)
            { data, response, error in
                guard let pageData = data else
                {
                    print("error getting diffen page for: \(searchStr)")
                    return
                }
                completion(String(data: pageData, encoding: .utf8) ?? "")
            }
            task.resume()
        }
        else
        {
            completion("")
        }
    }
    
    static func getImageText(_ imageUrlString: String, completion: @escaping (String) -> ())
    {
        let apiKey = "4159879d4788957"
        
        let url = URL(string: "https://api.ocr.space/parse/imageurl?apikey=\(apiKey)&url=\(URL(string: imageUrlString)!)")!
        let request = URLRequest(url: url)
        let session = URLSession.shared
        
        let task = session.dataTask(with: request)
        { data, response, error in
            guard let pageData = data else
            {
                print(error ?? "")
                return
            }
            do
            {
                if let json = try JSONSerialization.jsonObject(with: pageData, options: []) as? [String: Any],
                let results = json["ParsedResults"] as? [[String: Any]],
                let text = results[0]["ParsedText"] as? String
                {
                    completion(text)
                }
                
            }
            catch
            {
                print(error)
                completion(String(data: pageData, encoding: .ascii) ?? "")
            }
        }
        task.resume()
    }
}
