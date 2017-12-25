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
    static let removeFromOption = ["of", "the", "?"]
    
    static func getMatchesWithOption(_ question: String, for searchStrings: [String], completion: @escaping ([Int]) -> ())
    {
        var ret = [0, 0, 0]
        var searched = [false, false, false]
        for (i, str) in searchStrings.enumerated()
        {
            WebAPIController.getGooglePage(for: "\(question) \(str)")
            {
                page, _ in
                let matches = getMatchesInPage(page: page, searchStringLong: str, searchStringShort: str)
                DispatchQueue.main.sync {
                    ret[i] = matches
                }
                searched[i] = true
                if searched[0] && searched[1] && searched[2]
                {
                    completion(ret)
                }
            }
        }
    }
    
    static func getMatchesWithoutOption(_ question: String, for searchStrings: [String], completion: @escaping ([Int]) -> ())
    {
        var ret = [0, 0, 0]
        var searched = [false, false, false]
        WebAPIController.getGooglePage(for: question)
        {
            page, _ in
            for (i, str) in searchStrings.map({ $0.withoutExtra() }).enumerated()
            {
                let matches = getMatchesInPage(page: page, searchStringLong: str, searchStringShort: str.withoutExtra().lowercased())
                ret[i] = matches
                searched[i] = true
                if searched[0] && searched[1] && searched[2]
                {
                    completion(ret)
                }
            }
        }
    }
    
    static func getMatchesWithAllOptions(_ question: String, for searchStrings: [String], completion: @escaping ([Int]) -> ())
    {
        var ret = [0, 0, 0]
        var searched = [false, false, false]
        WebAPIController.getGooglePage(for: "\(question) \(searchStrings[0]) \(searchStrings[1]) \(searchStrings[2])")
        {
            page, _ in
            let searchPage = page.lowercased()
            
            for (i, str) in searchStrings.enumerated()
            {
                let matches = getMatchesInPage(page: searchPage, searchStringLong: str, searchStringShort: str)
                DispatchQueue.main.sync {
                    ret[i] = matches
                }
                searched[i] = true
                if searched[0] && searched[1] && searched[2]
                {
                    completion(ret)
                }
            }
        }
    }
    
    static func getMatchesForQuote(_ question: String, quote: String, for searchStrings: [String], completion: @escaping ([Int]) -> ())
    {
        var ret = [0, 0, 0]
        var searched = [false, false, false]
        let allSearchStrs = searchStrings + question.replacingOccurrences(of: quote, with: "").withoutExtra().components(separatedBy: " ")
        let searchStr = "\(allSearchStrs.joined(separator: " ").components(separatedBy: " ").joined(separator: ". .")) \(quote)"
        WebAPIController.getGooglePage(for: searchStr)
        {
            page, _ in
            for (i, str) in searchStrings.enumerated()
            {
                let matches = getMatchesInPage(page: page, searchStringLong: str, searchStringShort: str)
                DispatchQueue.main.sync {
                    ret[i] = matches
                }
                searched[i] = true
                if searched[0] && searched[1] && searched[2]
                {
                    completion(ret)
                }
            }
        }
    }
    
    static func getMatchesWithReplacing(_ question: String, for searchStrings: [String], withQuestion: Bool = false, completion: @escaping ([Int]) -> ())
    {
        var ret = [0, 0, 0]
        var results = [0, 0, 0]
        var searched = [false, false, false]
        for (i, str) in searchStrings.map({ $0.asGoogleOption() }).enumerated()
        {
            let wordArr = str.split(separator: " ")
            let search = wordArr.count > 1 ? AnswerType.replaceInQuestion(question: question, replaceWith: "\(wordArr.joined(separator: ". ."))") :
                AnswerType.replaceInQuestion(question: question, replaceWith: "\(str).")
            let searchStr = withQuestion ? search.withoutExtra() : str
            
            WebAPIController.getGooglePage(for: search)
            {
                page, numResults in
                results[i] = numResults
                let matches = getMatchesInPage(page: page, searchStringLong: searchStr, searchStringShort: str)
                DispatchQueue.main.sync {
                    ret[i] = matches
                }
                searched[i] = true
                if searched[0] && searched[1] && searched[2]
                {
                    let typeCode = AnswerController.getTypeForQuestion(question).searchFunctionCode
                    let shouldAdd = false //typeCode != 7 && typeCode != 4
                    fixForSameNumberMatches(ret, numResults: results, shouldAddResults: shouldAdd)
                    {
                        newRet in
                        ret = newRet
                        
                        for (j, option) in searchStrings.enumerated()
                        {
                            if let largestIndex = AnswerController.getLargestIndex(ret).first,
                                isOptionInQuestion(question: question, option: option),
                                j == largestIndex
                            {
                                let biggest = ret[largestIndex]
                                var temp = ret
                                temp[j] = 0
                                if let secondLargestIndex = AnswerController.getLargestIndex(temp).first
                                {
                                    ret[largestIndex] = ret[secondLargestIndex]
                                    ret[secondLargestIndex] = biggest
                                }
                            }
                        }
                        completion(ret)
                    }
                }
            }
        }
    }
    
    static func getMatchesFromNumResults(_ question: String = "", superSearches: [String] = [String](), for searchStrings: [String] = [String](), completion: @escaping ([Int]) -> ())
    {
        var ret = [0, 0, 0]
        var searched = [false, false, false]
        let arr = superSearches.isEmpty ? searchStrings.map({ $0.asGoogleOption() }) : superSearches
        for (i, str) in arr.enumerated()
        {
            let search = AnswerType.replaceInQuestion(question: question, replaceWith: str).withoutExtra()
            
            WebAPIController.getGooglePage(for: search)
            {
                _, results in
                DispatchQueue.main.sync {
                    ret[i] = results
                }
                searched[i] = true
                if searched[0] && searched[1] && searched[2]
                {
                    completion(ret)
                }
            }
        }
    }
    
    static func getMatchesForNot(_ question: String, for searchStrings: [String], completion: @escaping ([Int]) -> ())
    {
        let toReplace = ["not ", "never ", "no "]
        var temp = question.lowercased()
        toReplace.forEach {
            temp = temp.replacingOccurrences(of: $0, with: "")
        }
        getMatchesWithReplacing(temp.withoutExtra(), for: searchStrings, withQuestion: true)
        {
            matches in
            var ret = matches
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
    
    private static func getMatchesInPage(page: String, searchStringLong longStr: String, searchStringShort shortStr: String) -> Int
    {
        var ret = 0
        let searchPage = page.lowercased().trimmingCharacters(in: .newlines)
        var tempStr = longStr
        if tempStr.last == "s"
        {
            tempStr.removeLast()
        }
        
        ret += searchPage.components(separatedBy: tempStr.lowercased()).count - 1
        let arr = longStr.split(separator: " ")
        var temp = 0
        var toDivide = 0
        for (k, str3) in arr.enumerated()
        {
            var test = str3
            
            if test.count > 7
            {
                test.removeLast()
                temp += searchPage.components(separatedBy: "\(test.lowercased())").count - 1
                toDivide += 1
            }
            else if test.count > 4
            {
                let q = test.prefix(4)
                temp += searchPage.components(separatedBy: q.lowercased()).count - 1
                toDivide += 1
            }
            else if test.count > 1 && !longStr.contains(".")
            {
                temp += searchPage.components(separatedBy: "\(test.lowercased()) ").count - 1
                toDivide += 1
            }
            else if k != 0 && str3.contains(".")
            {
                let regEx = ".*\\b\(arr.prefix(k).joined(separator: " ").lowercased())\\b.*\\b\(arr.suffix(k).joined(separator: " ").lowercased())\\b.*"
                temp += matches(for: regEx, in: searchPage).count
            }
        }
        ret += toDivide > 0 ? temp / toDivide : temp
        
        ret += searchPage.components(separatedBy: " \(shortStr.lowercased()))").count - 1
        
        return ret
    }
    
    private static func fixForSameNumberMatches(_ matches: [Int], numResults: [Int], shouldAddResults: Bool = true, completion: @escaping ([Int]) -> ())
    {
        var ret = matches
        var counts: [Int: Int] = [:]
        var sameIndexes = [Int]()
        var tempSearchStrs = [String]()
        
        ret.forEach { counts[$0, default: 0] += 1 }
        for (key, val) in counts
        {
            if val != 1
            {
                let itemIndex = ret.index(of: key) ?? 0
                sameIndexes.append(itemIndex)
            }
            else
            {
                tempSearchStrs.append("")
            }
        }
        
        var tempResults = numResults
        
        let largest = AnswerController.getLargestIndex(numResults).first ?? 0
        tempResults.remove(at: largest)
        let secondLargest = numResults.index(of: tempResults[AnswerController.getLargestIndex(tempResults).first ?? 0]) ?? 0
        
        let largestResults = numResults[largest]
        let secondLargestResults = numResults[secondLargest]
        
        if largestResults > 0, secondLargestResults > 0, shouldAddResults
        {
            let percentDifference = (Double(secondLargestResults) / Double(largestResults)) * 100.0
            if percentDifference >= 70 { ret[largest] += largestResults }
            else
            {
                let largerNum = ret[largest]
                ret[largest] = largerNum + 1
            }
            completion(ret)
        }
        else
        {
            let largerNum = ret[largest]
            ret[largest] = largerNum + 1
            completion(ret)
        }
    }
    
    private static func hasQuoteString(_ question: String) -> String?
    {
        let quoteTypes = ["“", "”"]
        var temp = question
        quoteTypes.forEach { temp = temp.replacingOccurrences(of: $0, with: "\"") }
        if temp.contains("\"")
        {
            let arr = temp.components(separatedBy: "\"")
            let item = arr[1]
            return item
        }
        return nil
    }
    
    private static func isOptionInQuestion(question: String, option: String) -> Bool
    {
        for str in option.split(separator: " ")
        {
            if question.contains(" \(str)") { return true }
        }
        return false
    }
    
    private static func matches(for regex: String, in text: String) -> [String]
    {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text,
                                        range: NSRange(text.startIndex..., in: text))
            return results.map {
                String(text[Range($0.range, in: text)!])
            }
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
