//
//  AnswerType.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 11/8/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Foundation

class AnswerType
{
    static let replacementWords = ["which of these", "which one of these", "whose", "who", "whom", "which", "what", "where"]

    var title: String
    var check: (String) -> (Bool)
    var searchFunctionCode: Int
    
    init(title: String, check: @escaping (String) -> (Bool), searchFunctionCode: Int)
    {
        self.title = title
        self.searchFunctionCode = searchFunctionCode
        self.check = check
    }
    
    static func replaceInQuestion(question: String, replaceWith toReplace: String) -> String
    {
        let lowercaseQuestion = question.lowercased()
        for str in replacementWords
        {
            if lowercaseQuestion.contains(str)
            {
                return lowercaseQuestion.replacingOccurrences(of: str, with: toReplace)
            }
        }
        return question
    }
    
    static func replacedWord(question: String) -> String
    {
        for str in replacementWords
        {
            if question.lowercased().contains(str)
            {
                return str
            }
        }
        return ""
    }
    
    static func == (lhs: AnswerType, rhs: AnswerType) -> Bool
    {
        return lhs.searchFunctionCode == rhs.searchFunctionCode
    }
    
    static func != (lhs: AnswerType, rhs: AnswerType) -> Bool
    {
        return lhs.searchFunctionCode != rhs.searchFunctionCode
    }
    
    static let other = AnswerType(title: "Other", check: { !$0.isEmpty }, searchFunctionCode: 0)
    static let startsWhich = AnswerType(title: "Starts Which", check: { $0.starts(with: "Which") }, searchFunctionCode: 1)
    static let startWhat = AnswerType(title: "Start What", check: { $0.starts(with: "What") }, searchFunctionCode: 2)
    static let whichOfThese = AnswerType(title: "Which of These", check: { $0.lowercased().containsAtLeastOne("which of these", "which one of these", "which of the following") }, searchFunctionCode: 3)
    static let midWhich = AnswerType(title: "Middle Which", check: { $0.contains(" which ") }, searchFunctionCode: 4)
    static let correctSpelling = AnswerType(title: "Correct Spelling", check: { $0.containsAtLeastOne("spelling", "spelled", " spell ") }, searchFunctionCode: 5)
    static let whose = AnswerType(title: "Whose", check: { $0.lowercased().contains("whose") }, searchFunctionCode: 6)
    static let not = AnswerType(title: "Not", check: { $0.lowercased().containsAtLeastOne(" not ", " no ", " never ") }, searchFunctionCode: 7)
    static let who = AnswerType(title: "Who", check: { $0.lowercased().containsAtLeastOne("who ", " who ", " who's", "whom") }, searchFunctionCode: 8)
    static let whereIs = AnswerType(title: "Where", check: { $0.lowercased().contains(" where ") || $0.starts(with: "Where")}, searchFunctionCode: 9)
    static let howMany = AnswerType(title: "How Many", check: { $0.lowercased().contains(" how many ") }, searchFunctionCode: 10) // TODO`
//    static let comparison = AnswerType(title: "Comparison", check: { $0.lowercased().containsAtLeastOne("most", "least", "closest", "furthest", "largest", "smallest", "biggest")}, searchFunctionCode: 11)
    static let otherTwo = AnswerType(title: "Other Two", check: { $0.lowercased().contains(" other two ") }, searchFunctionCode: 12)
    static let isWhat = AnswerType(title: "Is What", check: { $0.contains("is what?") }, searchFunctionCode: 13)
    static let midWhat = AnswerType(title: "Middle What", check: { $0.contains(" what") }, searchFunctionCode: 14)
    static let endWhat = AnswerType(title: "End What", check: { $0.hasSuffix("what?") }, searchFunctionCode: 15)
    static let definition = AnswerType(title: "Definition", check: { $0.starts(with: "What") && $0.contains("word") && $0.contains("mean") }, searchFunctionCode: 16)

}
