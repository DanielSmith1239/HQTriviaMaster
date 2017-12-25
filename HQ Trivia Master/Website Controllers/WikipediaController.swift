//
//  WikipediaController.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 10/31/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Foundation

class WikipediaController
{
    static func getMatches(_ question: String, for options: [String], completion: @escaping ([Int]) -> ())
    {
        var ret = [0, 0, 0]
        var searched = [false, false, false]
        let searchStrings = TextController.getSearchWords(forQuestion: question)
        for (i, option) in options.enumerated()
        {
            WebAPIController.getWikipediaPage(for: option)
            {
                page in
                let searchPage = page.lowercased()
                for str in searchStrings
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
    
    static func getMatchesForNot(_ question: String, for options: [String], completion: @escaping ([Int]) -> ())
    {
        var ret = [0, 0, 0]
        var searched = [false, false, false]
        let searchStrings = TextController.getSearchWords(forQuestion: question)
        for (i, option) in options.enumerated()
        {
            WebAPIController.getWikipediaPage(for: option)
            {
                page in
                let searchPage = page.lowercased()
                for str in searchStrings
                {
                    ret[i] += searchPage.components(separatedBy: str.lowercased()).count - 1
                    searched[i] = searchPage.components(separatedBy: str.lowercased()).count > 0
                }
                if searched[0] && searched[1] && searched[2]
                {
                    var temp = ret.sorted()
                    let most = temp.removeLast()
                    let _ = temp.removeLast()
                    let least = temp.removeLast()
                    
                    let mostIndex = ret.index(of: most)!
                    let leastIndex = ret.index(of: least)!
                    
                    ret[mostIndex] = least
                    ret[leastIndex] = most
                    completion(ret)
                }
            }
        }
    }
}
