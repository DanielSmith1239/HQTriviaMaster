//
//  GoogleController.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 11/1/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Foundation

class GoogleController
{
    static func getMatches(_ question: String, for searchStrings: [String], googleOption: Int, completion: @escaping ([Int]) -> ())
    {
        var ret = [0, 0, 0]
        var searched = [false, false, false]
        if googleOption == 0
        {
            for (i, str) in searchStrings.enumerated()
            {
                
                WebAPIController.getGooglePage(for: "\(question) \(str)")
                {
                    page in
                    let searchPage = page.lowercased()
                    print(searchPage)
                    
                    ret[i] += searchPage.components(separatedBy: str.lowercased()).count - 1
                    for (j, str2) in searchStrings.enumerated()
                    {
                        ret[j] += searchPage.components(separatedBy: str2.lowercased()).count - 1
                        searched[i] = searchPage.components(separatedBy: str2.lowercased()).count > 0
                        if searched[0] && searched[1] && searched[2]
                        {
                            completion(ret)
                        }
                    }
                }
            }
        }
        if googleOption == 1
        {
            WebAPIController.getGooglePage(for: "\(question)")
            {
                page in
                let searchPage = page.lowercased()
                print(searchPage)
                
                for (i, str) in searchStrings.enumerated()
                {
                    ret[i] += searchPage.components(separatedBy: str.lowercased()).count - 1
                    searched[i] = searchPage.components(separatedBy: str.lowercased()).count > 0
                    if searched[0] && searched[1] && searched[2]
                    {
                        completion(ret)
                    }
                }
            }
        }
    }
    
    static func getMatches2(_ question: String, for searchStrings: [String], googleOption: Int, completion: @escaping ([Int]) -> ())
    {
        var ret = [0, 0, 0]
        var searched = [false, false, false]
        WebAPIController.getGooglePage(for: "\(question) \(searchStrings.joined(separator: " "))")
        {
            page in
            let searchPage = page.lowercased()
            for (i, str) in searchStrings.enumerated()
            {
                ret[i] += searchPage.components(separatedBy: str.lowercased()).count - 1
                searched[i] = searchPage.components(separatedBy: str.lowercased()).count > 0
            }
            if searched[0] && searched[1] && searched[2]
            {
                completion(ret)
            }
        }
    }
}
