//
//  TextController.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 10/31/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Foundation
import Cocoa

class TextController
{
    static func getWikipediaUrl(forOption option: String) -> URL
    {
        return URL(string: "https://en.wikipedia.org/wiki/\(forWikipedia(option))")!
    }
    
    static func getGoogleUrl(forQuestion question: String) -> URL?
    {
        let apiKey = "KEYHERE"
        let searchEngineId = "IDHERE"
        let url = URL(string: "https://www.googleapis.com/customsearch/v1?key=\(apiKey)&cx=\(searchEngineId)&q=\(forGoogle(question))")
        return url
    }
    
    static func getSearchWords(forQuestion question: String) -> [String]
    {
        let q = question.withoutExtra()
        return q.split(separator: " ").map { String($0) }
    }
    
    static func getFixedText(_ str: String) -> String
    {
        let replaceArr = [["'s", ""], ["ﬁ", "fi"], ["|", "I"], ["vv", "w"], ["VV", "W"], ["é", "e"], ["ﬂ", "tl"], ["re-", "re"], ["-", ""], [":8", "&"], ["05", "0s"]]
        var ret = str
        for item in replaceArr
        {
            ret = ret.replacingOccurrences(of: item[0], with: item[1])
        }
        return ret
    }
    
    private static func withoutIlligalCharacters(_ str: String) -> String
    {
        let toKeep = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890&-_. "
        var fixed = ""
        for letter in getFixedText(str)
        {
            if toKeep.contains(letter)
            {
                fixed += String(letter)
            }
        }
        return fixed
    }
    
    private static func forWikipedia(_ option: String) -> String
    {
        return getFixedText(option.replacingOccurrences(of: " ", with: "_"))
    }
    
    private static func forGoogle(_ question: String) -> String
    {
        let punctuationToRemove = ["\"", "\\", "“", "”", "?", "#", "&", ".", ",", "’", "”", "“"]
        let punctuationToReplace = ["  ", " "]
        var fixed = withoutIlligalCharacters(question)

        if fixed.contains(".")
        {
            var words = fixed.components(separatedBy: " ")
            for (i, word) in words.enumerated()
            {
                if word.contains(".")
                {
                    let temp = word.replacingOccurrences(of: ".", with: "")
                    words[i] = temp
                }
                else
                {
                    words[i] = "intext:\(word) "
                }
            }
            fixed = words.joined(separator: " ")
        }
        else
        {
            fixed = fixed.withoutExtra()
        }

        for item in punctuationToReplace
        {
            fixed = fixed.replacingOccurrences(of: item, with: "+")
        }
        for item in punctuationToRemove
        {
            fixed = fixed.replacingOccurrences(of: item, with: "")
        }
        fixed = fixed.replacingOccurrences(of: "+intext:+", with: "+").replacingOccurrences(of: "++", with: "+") 
        if fixed.hasSuffix("+") { fixed.removeLast() }
        return fixed
    }
    
    static func getMatchesForCorrectSpelling(_ options: [String]) -> [Int]
    {
        var ret = [0, 0, 0]
        for (i, str) in options.enumerated()
        {
            let corrector = NSSpellChecker.shared
            let range = corrector.checkSpelling(of: str, startingAt: 0)
            if range.length == 0
            {
                ret[i] = 1
                break;
            }
        }
        return ret
    }
}

extension String
{
    func slice(from: String, to: String) -> String
    {
        return (range(of: from)?.upperBound).flatMap { substringFrom in
            (range(of: to, range: substringFrom..<endIndex)?.lowerBound).map { substringTo in
                String(self[substringFrom..<substringTo])
            }
        }!
    }
    
    func asGoogleOption() -> String
    {
        var ret = self
        for str in GoogleController.removeFromOption
        {
            ret = ret.replacingOccurrences(of: str, with: "")
        }
        return ret.replacingOccurrences(of: "  ", with: " ")
    }
    
    func containsAtLeastOne(_ strs: String...) -> Bool
    {
        for str in strs
        {
            if contains(str)
            {
                return true
            }
        }
        return false
    }
    
    static var ExtraWords: [String]
    {
        return [ " of these ", " his ", " is ", " her ", " their ", " in ", " from ", " was ", " which ", "?", "\"", " or ", " a ", " an ", " of ", " the ", " that ", " what ", " to ", " for ", " only ", " not ", " does ", " NOT ", " would ", " you ", " need ", " at ", "On ", " find ", " all time ", "Which ", "What is ","What ",  "For", "also", "with"]
    }
    
    func hasExtra() -> Bool
    {
        var extra = String.ExtraWords
        for (i, word) in extra.enumerated()
        {
            extra[i] = word.lowercased() //word.replacingOccurrences(of: " ", with: "").lowercased()
        }
        for word in self.components(separatedBy: " ")
        {
            if extra.contains(word)
            {
                return true
            }
        }
        return false
    }
    
    func withoutExtra() -> String
    {
        var q  = self
        let toRemove = String.ExtraWords
        toRemove.forEach { q = $0.first == " " ? q.replacingOccurrences(of: $0, with: " ") : q.replacingOccurrences(of: $0, with: "") }
        q = q.replacingOccurrences(of: "  ", with: " ")
        return q
    }
}
