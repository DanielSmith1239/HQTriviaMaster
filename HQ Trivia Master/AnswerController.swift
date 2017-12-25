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
        /*
         static let other = AnswerType(title: "Other", check: { !$0.isEmpty }, searchFunctionCode: 0)
         static let startsWhich = AnswerType(title: "Starts Which", check: { $0.starts(with: "Which") }, searchFunctionCode: 1)
         static let startWhat = AnswerType(title: "Start What", check: { $0.starts(with: "What") }, searchFunctionCode: 2)
         static let whichOfThese = AnswerType(title: "Which of These", check: { $0.lowercased().containsAtLeastOne("which of these", "which one of these", "which of the following") }, searchFunctionCode: 3)
         static let midWhich = AnswerType(title: "Middle Which", check: { $0.contains(" which ") }, searchFunctionCode: 4)
         static let correctSpelling = AnswerType(title: "Correct Spelling", check: { $0.containsAtLeastOne("spelling", "spelled", " spell ") }, searchFunctionCode: 5)
         static let whose = AnswerType(title: "Whose", check: { $0.lowercased().contains("whose") }, searchFunctionCode: 6)
         static let not = AnswerType(title: "Not", check: { $0.lowercased().contains(" not ") }, searchFunctionCode: 7)
         static let who = AnswerType(title: "Who", check: { $0.lowercased().containsAtLeastOne(" who ", " who's", "whom") }, searchFunctionCode: 8)
         static let whereIs = AnswerType(title: "Where", check: { $0.lowercased().contains(" where ") || $0.starts(with: "Where")}, searchFunctionCode: 9)
         static let howMany = AnswerType(title: "How Many", check: { $0.lowercased().contains(" how many ") }, searchFunctionCode: 10) // TODO`
         //    static let comparison = AnswerType(title: "Comparison", check: { $0.lowercased().containsAtLeastOne("most", "least", "closest", "furthest", "largest", "smallest", "biggest")}, searchFunctionCode: 11)
         static let otherTwo = AnswerType(title: "Other Two", check: { $0.lowercased().contains(" other two ") }, searchFunctionCode: 12)
         static let isWhat = AnswerType(title: "Is What", check: { $0.contains("is what?") }, searchFunctionCode: 13)
         static let midWhat = AnswerType(title: "Middle What", check: { $0.contains(" what") }, searchFunctionCode: 14)
         static let endWhat = AnswerType(title: "End What", check: { $0.hasSuffix("what?") }, searchFunctionCode: 15)
         static let definition = AnswerType(title: "Definition", check: { $0.starts(with: "What") && $0.contains("word") && $0.contains("mean") }, searchFunctionCode: 16)
         */
        
        print(type.title)
        let searchCode = type.searchFunctionCode
        if searchCode == 5 ||
            searchCode == 7 ||
            searchCode == 3
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
                print("without matches: \(matches)")
                if Set(matches).count != 1,
                    matches[getLargestIndex(matches).first ?? 0] > 0,
                    getLargestIndex(matches).count == 1
                {
                    let splitQ = question.split(separator: " ")[0...3].joined(separator: " ")
                    print("used without: \(getLargestIndex(matches).first! == 0), \(splitQ)")
                    completion(getLargestIndex(matches))
                    return
                }
                else
                {
                    getSecondaryMatches(question: question, options: options)
                    {
                        matches in
                        let splitQ = question.split(separator: " ")[0...3].joined(separator: " ")
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
//        case 3:
//            GoogleController.getMatchesWithAllOptions(question, for: options)
//            {
//                matches in
//                completion(matches)
//            }
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
