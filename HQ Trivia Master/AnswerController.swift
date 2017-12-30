//
//  AnswerController.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 11/8/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Foundation

class AnswerController
{
    private static let answerTypes = [AnswerType.not, AnswerType.definition, AnswerType.otherTwo, AnswerType.whichOfThese, AnswerType.midWhich, AnswerType.correctSpelling, AnswerType.whose, AnswerType.who, AnswerType.howMany, AnswerType.startsWhich, AnswerType.isWhat, AnswerType.startWhat, AnswerType.endWhat, AnswerType.midWhat, AnswerType.whereIs, AnswerType.other]
    
    static func getAnswer(question: String, options: [String], completion: @escaping ([Int]) -> ())
    {
        let type = getTypeForQuestion(question)
        
        print(type.title)
        let skipCodes = [5, 7, 3]
        let searchCode = type.searchFunctionCode
        if skipCodes.contains(searchCode)
        {
            getSecondaryMatches(question: question, options: options)
            {
                matches in
                print(matches)
                completion(getLargestIndex(matches))
                return
            }
        }
        else
        {
            GoogleController.getMatchesWithOption(question, for: options)
            {
                matches in
                if Set(matches).count != 1,
                    matches[getLargestIndex(matches).first ?? 0] > 0,
                    getLargestIndex(matches).count == 1
                {
                    completion(getLargestIndex(matches))
                    return
                }
                else
                {
                    getSecondaryMatches(question: question, options: options)
                    {
                        matches in
                        completion(getLargestIndex(matches))
                    }
                }
            }
        }
    }
    
    private static func getSecondaryMatches(question: String, options: [String], completion: @escaping ([Int]) -> ())
    {
        let type = getTypeForQuestion(question)
        switch type.searchFunctionCode
        {
        case 13:
            GoogleController.getMatchesFromNumResults(question, for: options)
            {
                matches in
                completion(matches)
            }
        case 1, 3, 4, 9, 16:
            GoogleController.getMatchesWithReplacing(question, for: options, withQuestion: true)
            {
                matches in
                completion(matches)
            }
        case 2, 6, 8:
            GoogleController.getMatchesWithReplacing(question, for: options)
            {
                matches in
                completion(matches)
            }
        case 10, 11, 14:
            GoogleController.getMatchesWithOption(question, for: options)
            {
                matches in
                completion(matches)
            }
        case 7:
            GoogleController.getMatchesForNot(question, for: options)
            {
                matches in
                completion(matches)
            }
        case 5:
            let matches = TextController.getMatchesForCorrectSpelling(options)
            completion(matches)
            break
        case 15:
            GoogleController.getMatchesFromNumResults(question, for: options)
            {
                matches in
                completion(matches)
            }
        default:
            GoogleController.getMatchesWithOption(question, for: options)
            {
                matches in
                completion(matches)
            }
        }
    }
    
    static func getLargestIndex(_ arr: [Int]) -> [Int]
    {
        var ret = [Int]()
        let sorted = arr.sorted()
        let last = sorted.last!
        var i = sorted.index(of: last)!
        while sorted[i] == last && i != 0
        {
            ret.append(arr.index(of: sorted[i])!)
            i -= 1
        }
        return ret
    }
    
    static func getSmallestIndex(_ arr: [Int]) -> [Int]
    {
        var ret = [Int]()
        let sorted: [Int] = arr.sorted().reversed()
        let last = sorted.last!
        var i = sorted.index(of: last)!
        while sorted[i] == last && i != 0
        {
            ret.append(arr.index(of: sorted[i])!)
            i -= 1
        }
        return ret
    }
    
    static func getTypeForQuestion(_ question: String) -> AnswerType
    {
        for type in answerTypes
        {
            if type.check(question)
            {
                return type
            }
        }
        return AnswerType.other
    }
}
