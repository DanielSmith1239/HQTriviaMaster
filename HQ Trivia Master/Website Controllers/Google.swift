//
//  Google.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 11/1/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Foundation

class Google
{
    static let removeFromOption = ["of", "the", "?"]
    
    /**
     Finds matches for the options by Googling the question for every option, and includes the option in the search query.
     - Parameters:
        - question: The questin being asked
        - searchStrings: The possible options
        - completion: The function to call on completion
     */
    static func matches(for question: String, including searchStrings: [String], completion: @escaping (AnswerCounts) -> ())
    {
        var answerCounts = AnswerCounts()
        let group = DispatchGroup()
        for answer in searchStrings
        {
            group.enter()
            if HQTriviaMaster.debug
            {
                print("Search String: \(question) \(answer)")
            }
            getGooglePage(for: "\(question) \(answer)") { page, _ in
                defer
                {
                    group.leave()
                }
                guard let page = page else { return }
                let matches = numberOfMatches(in: page, longString: answer, shortString: answer)
                answerCounts[answer] = matches
            }
        }
        group.notify(queue: .main) {
            completion(answerCounts)
        }
    }
    
    /**
     Finds matches for the options in a Google page.
     - Parameters:
        - question: The questin being asked
        - searchStrings: The possible options
        - completion: The function to call on completion
     */
    static func matches(for question: String, notIncluding searchStrings: [String], completion: @escaping (AnswerCounts) -> ())
    {
        var answerCounts = AnswerCounts()
        let group = DispatchGroup()
        group.enter()
        if HQTriviaMaster.debug
        {
            print("Search String: \(question)")
        }
        getGooglePage(for: question) { page, _ in
            defer
            {
                group.leave()
            }
            guard let page = page else { return }
            for answer in searchStrings.map({ $0.withoutExtraneousWords })
            {
                let matches = numberOfMatches(in: page, longString: answer, shortString: answer.withoutExtraneousWords.lowercased())
                answerCounts[answer] = matches
            }
        }
        group.notify(queue: .main) {
            completion(answerCounts)
        }
    }
    
    /**
     Finds matches for the options in the Google page by adding all of the options to the search query.
     - Parameters:
        - question: The questin being asked
        - searchStrings: The possible options
        - completion: The function to call on completion
     */
    static func matches(for question: String, includingAll searchStrings: [String], completion: @escaping (AnswerCounts) -> ())
    {
        var answerCounts = AnswerCounts()
        let group = DispatchGroup()
        group.enter()
        if HQTriviaMaster.debug
        {
            print("Search String: \(question) \(searchStrings[0]) \(searchStrings[1]) \(searchStrings[2])")
        }
        getGooglePage(for: "\(question) \(searchStrings[0]) \(searchStrings[1]) \(searchStrings[2])") { page, _ in
            defer
            {
                group.leave()
            }
            guard let searchPage = page?.lowercased() else { return }
            for answer in searchStrings
            {
                let matches = numberOfMatches(in: searchPage, longString: answer, shortString: answer)
                answerCounts[answer] = matches
            }
        }
        group.notify(queue: .main) {
            completion(answerCounts)
        }
    }
    
    /**
     Finds matches for the options in the Google page, for when the question contains a quote.
     - Parameters:
        - question: The question being asked
        - searchStrings: The possible options
        - completion: The function to call on completion
     */
    static func matches(for question: String, including quote: String, andIncluding searchStrings: [String], completion: @escaping (AnswerCounts) -> ())
    {
        var answerCounts = AnswerCounts()
        let group = DispatchGroup()
        group.enter()
        let allSearchStrs = searchStrings + question.replacingOccurrences(of: quote, with: "").withoutExtraneousWords.components(separatedBy: " ")
        let searchStr = "\(allSearchStrs.joined(separator: " ").components(separatedBy: " ").joined(separator: ". .")) \(quote)"
        if HQTriviaMaster.debug
        {
            print("Search String: \(searchStr)")
        }
        getGooglePage(for: searchStr) { page, _ in
            defer
            {
                group.leave()
            }
            guard let page = page else { return }
            for answer in searchStrings
            {
                let matches = numberOfMatches(in: page, longString: answer, shortString: answer)
                answerCounts[answer] = matches
            }
        }
        group.notify(queue: .main) {
            completion(answerCounts)
        }
    }
    
    /**
     Finds matches for the specified answers on Google.  This method will swap the largest and second largest answers
     - Parameter question: The question being asked
     - Parameter searchStrings: The answers to search for
     - Parameter queryContainsQuestion: Determines whether to only search for the answer or for the question + answer.  Defaults to `false`
     - Parameter completion: A closure called once all results have been tallied
     */
    static func matches(for question: String, withReplacingLargestAnswerIn searchStrings: [String], queryContainsQuestion: Bool = false, withInText: Bool = false, completion: @escaping (AnswerCounts) -> ())
    {
        var answerCounts = AnswerCounts()
        var answerResults = AnswerCounts()
        let group = DispatchGroup()
        for answer in searchStrings.map({ $0.googleOption })
        {
            group.enter()
            let wordArr = answer.split(separator: " ")
            let inTextSearch = wordArr.count > 1 ? QuestionType.replace(in: question, replaceWith: "\(wordArr.joined(separator: ". ."))") :
                QuestionType.replace(in: question, replaceWith: "\(answer).")
            let search = withInText ? inTextSearch :
                QuestionType.replace(in: question, replaceWith: answer)
            
            let searchStr = queryContainsQuestion ? search.withoutExtraneousWords : answer
            if HQTriviaMaster.debug
            {
                print("Search String: \(search)")
            }
            getGooglePage(for: search) { page, numberOfResults in
                defer
                {
                    group.leave()
                }
                guard let page = page else
                {
                    completion(answerCounts)
                    return
                }
                answerResults[answer] = numberOfResults
                let matches = numberOfMatches(in: page, longString: searchStr, shortString: answer)
                answerCounts[answer] = matches
            }
        }
        group.notify(queue: .main) {
            fixForSameNumberMatches(answerCounts, numResults: answerResults, shouldAddResults: false) { newAnswerCount in
                answerCounts = newAnswerCount
                let largestAnswer = answerCounts.largest
                /*
                 If the question contains any word in the predicted correct answer, switch the predeicted correct answer and the answer with the second largest amount of matches.
                 
                 This is, of course, a workaround that will hopefully be fixed at some point.
                */
                guard `is`(answer: largestAnswer.0, inQuestion: question) else
                {
                    completion(answerCounts)
                    return
                }
                var temp = answerCounts
                temp[largestAnswer.0] = 0
                let secondLargestAnswer = temp.largest
                answerCounts[largestAnswer.0] = secondLargestAnswer.1
                answerCounts[secondLargestAnswer.0] = largestAnswer.1
                completion(answerCounts)
            }
        }
    }
    
    /**
     
     */
    static func numberOfResultsBasedMatches(for question: String = "", overridingAnswers: [String] = [String](), including searchStrings: [String] = [String](), completion: @escaping (AnswerCounts) -> Void)
    {
        var answerCounts = AnswerCounts()
        let group = DispatchGroup()
        for answer in (overridingAnswers.isEmpty ? searchStrings.map({ $0.googleOption }) : overridingAnswers)
        {
            group.enter()
            let search = QuestionType.replace(in: question, replaceWith: answer).withoutExtraneousWords
            if HQTriviaMaster.debug
            {
                print("Search String: \(search)")
            }
            getGooglePage(for: search) { _, numberOfResults in
                answerCounts[answer] = numberOfResults
                group.leave()
            }
        }
        group.notify(queue: .main) {
            completion(answerCounts)
        }
    }
    
    /**
     Finds matches for the options in the Google, for when you want the option with the least hits.
     - Parameters:
        - question: The questin being asked
        - searchStrings: The possible options
        - completion: The function to call on completion
     */
    static func inverseMatches(for question: String, with searchStrings: [String], completion: @escaping (AnswerCounts) -> ())
    {
        let toReplace = ["not ", "never ", "no "]
        var temp = question.lowercased()
        toReplace.forEach {
            temp = temp.replacingOccurrences(of: $0, with: "")
        }
        matches(for: temp.withoutExtraneousWords, withReplacingLargestAnswerIn: searchStrings, queryContainsQuestion: true) { matches in
            var invertedNumberOfResults = matches
            let most = invertedNumberOfResults.largest
            let smallest = invertedNumberOfResults.smallest
            invertedNumberOfResults[most.0] = smallest.1
            invertedNumberOfResults[smallest.0] = most.1
            completion(invertedNumberOfResults)
        }
    }
    
    private static func numberOfMatches(in page: String, longString: String, shortString: String) -> Int
    {
        var ret = 0
        let searchPage = page.lowercased().trimmingCharacters(in: .newlines)
        var tempStr = longString
        if tempStr.last == "s"
        {
            tempStr.removeLast()
        }
        
        ret += searchPage.components(separatedBy: tempStr.lowercased()).count - 1
        let arr = longString.split(separator: " ")
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
            else if test.count > 1 && !longString.contains(".")
            {
                temp += searchPage.components(separatedBy: "\(test.lowercased()) ").count - 1
                toDivide += 1
            }
            else if k != 0 && str3.contains(".")
            {
                let regEx = ".*\\b\(arr.prefix(k).joined(separator: " ").lowercased())\\b.*\\b\(arr.suffix(k).joined(separator: " ").lowercased())\\b.*"
                guard let matches = matches(for: regEx, in: searchPage) else
                {
                    print("No regex matches")
                    return -1
                }
                temp += matches.count
            }
        }
        ret += toDivide > 0 ? temp / toDivide : temp
        
        ret += searchPage.components(separatedBy: " \(shortString.lowercased()))").count - 1
        
        return ret
    }
    
    /**
     
     */
    private static func fixForSameNumberMatches(_ matches: AnswerCounts, numResults: AnswerCounts, shouldAddResults: Bool = true, completion: @escaping (AnswerCounts) -> ())
    {
        // The largest difference (percentage) between the first and second largest AnswerCount that would requier the program to take the number of results into account.
        // Feel free to play around with this number.
        let useNumResultsThreshold = 0.3
        
        guard matches.countsOfResults.count != matches.count else
        {
            completion(matches)
            return
        }
        var returnCounts = matches
        var tempResults = numResults
        
        let largest = numResults.largest
        let largestResults = largest.1
        tempResults[largest.0] = 0
        let secondLargest = tempResults.largest
        let secondLargestResults = secondLargest.1
        
        let difference =  matches.getPercentage(ofAnswer: largest) - matches.getPercentage(ofAnswer: secondLargest)
        
        if largestResults > 0,
            secondLargestResults > 0,
            shouldAddResults
        {
            let percentDifference = (Double(secondLargestResults) / Double(largestResults)) * 100.0
            if percentDifference >= 70
            {
                returnCounts[largest.0] += largestResults
            }
            else
            {
                let largerNum = returnCounts[largest.0]
                returnCounts[largest.0] = largerNum + 1
            }
            completion(returnCounts)
        }
        else if difference <= useNumResultsThreshold,
            [largest.0, tempResults.largest.0].contains(matches.largest.0)
        {
            returnCounts[matches.largest.0] += Int((difference * Double(matches.sumOfResults)) * 2)
            print("Adjusted for number of Google results.")
        }
        else
        {
            let largerNum = returnCounts[largest.0]
            returnCounts[largest.0] = largerNum + 1
            completion(returnCounts)
        }
    }
    
    /**
     Determines whether or not the specified option is contained in the question
     - Parameter answer: The string to search for
     - Parameter question: The question to search in
     - Returns: true if `option` is found in `question`, false otherwise
     */
    private static func `is`(answer: String, inQuestion question: String) -> Bool
    {
        for str in answer.split(separator: " ")
        {
            if question.contains(" \(str)") { return true }
        }
        return false
    }
    
    /**
     Returns all instances within a string that match the given regular expression
     - Parameter regex: A regular expression
     - Parameter text: A string to search in
     */
    private static func matches(for regex: String, in text: String) -> [String]?
    {
        do
        {
            let regex = try NSRegularExpression(pattern: regex)
            let results = regex.matches(in: text, range: NSRange(text.startIndex..., in: text))
            return results.map { String(text[Range($0.range, in: text)!]) }
        }
        catch
        {
            print("invalid regex: \(error)")
            return nil
        }
    }
    
    /**
     Downloads and parses search results from a custom Google Search Engine
     - Parameter searchString: The string to search
     - Parameter completion: A closure that accepts a string and integer
     - Parameter snippet: Joined snippets returned from the Google API
     - Parameter numberOfResults: The number of results returned
     */
    private static func getGooglePage(for searchString: String, completion: @escaping (_ snippet: String?, _ numberOfResults: Int) -> ())
    {
        guard let url = SiteEncoding.google.url(with: searchString) else
        {
            completion(nil, 0)
            return
        }
        URLSession.shared.dataTask(with: URLRequest(url: url)) { data, response, error in
            if let error = error
            {
                print(error)
                completion(nil, 0)
                return
            }
            guard let pageData = data, let unknownReturnString = NSAttributedString(html: pageData, baseURL: url, documentAttributes: nil) else
            {
                print("Empty Google page for: \(searchString)")
                completion(nil, 0)
                return
            }
            do
            {
                guard let json = try JSONSerialization.jsonObject(with: pageData, options: []) as? [String: Any] else
                {
                    completion(unknownReturnString.string, 0)
                    return
                }
                var snippets = ""
                if let items = json["items"] as? [[String: Any]]
                {
                    snippets = items.flatMap { $0["snippet"] as? String }.joined(separator: " ")
                    snippets += items.flatMap { $0["title"] as? String }.joined(separator: " ")
                }
                guard let searchInfo = json["searchInformation"] as? [String : Any], let results = searchInfo["totalResults"] as? String, let numResults = Int(results), numResults != 10 else
                {
                    completion(unknownReturnString.string, 0)
                    return
                }
                completion(snippets, numResults)
            }
            catch
            {
                print(error)
                completion(unknownReturnString.string, 0)
            }
            }.resume()
    }
}

