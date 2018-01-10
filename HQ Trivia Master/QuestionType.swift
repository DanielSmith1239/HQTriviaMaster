//
//  QuestionType.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 11/8/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Foundation

/**
 Holds basic information about the type of question
 
 The question's type is used for more precise searches, or to flip results where needed
 */
struct QuestionType : Equatable
{
    private static let replacementWords = ["which of these", "which one of these", "whose", "who", "whom", "which", "what", "where"]

    var title : String
    var check : (String) -> Bool
    var searchFunctionCode : Int
    
    private init(title: String, check: @escaping (String) -> Bool, searchFunctionCode: Int)
    {
        self.title = title
        self.searchFunctionCode = searchFunctionCode
        self.check = check
    }
    
    /**
     Replaces any instance of a phrase in `replacementWords` with the specified String
     - Parameter question: The string to search in
     - Parameter toReplace: The string to substitute in
     - Returns: A string with all instances of a phrase in `replacementWords` replaced with the specified string
     */
    static func replace(in question: String, replaceWith toReplace: String) -> String
    {
        let lowercaseQuestion = question.lowercased()
        for str in replacementWords where lowercaseQuestion.contains(str)
        {
            return lowercaseQuestion.replacingOccurrences(of: str, with: toReplace)
        }
        return question
    }
    
    static func == (lhs: QuestionType, rhs: QuestionType) -> Bool
    {
        return lhs.searchFunctionCode == rhs.searchFunctionCode
    }
    
    static let other = QuestionType(title: "Other", check: { !$0.isEmpty }, searchFunctionCode: 0)
    static let startsWhich = QuestionType(title: "Starts with \"Which\"", check: { $0.starts(with: "Which") }, searchFunctionCode: 1)
    static let startWhat = QuestionType(title: "Start with \"What\"", check: { $0.starts(with: "What") }, searchFunctionCode: 2)
    static let whichOfThese = QuestionType(title: "Which of These", check: { $0.lowercased().contains(atLeastOneElementIn: ["which of these", "which one of these", "which of the following"]) }, searchFunctionCode: 3)
    static let midWhich = QuestionType(title: "Middle Which", check: { $0.contains(" which ") }, searchFunctionCode: 4)
    static let correctSpelling = QuestionType(title: "Correct Spelling", check: { $0.contains(atLeastOneElementIn: ["spelling", "spelled", " spell "]) }, searchFunctionCode: 5)
    static let whose = QuestionType(title: "Whose", check: { $0.lowercased().contains("whose") }, searchFunctionCode: 6)
    static let not = QuestionType(title: "Not", check: { $0.lowercased().contains(atLeastOneElementIn: [" not ", " no ", " never "]) }, searchFunctionCode: 7)
    static let who = QuestionType(title: "Who", check: { $0.lowercased().contains(atLeastOneElementIn: ["who ", " who ", " who's", "whom"]) }, searchFunctionCode: 8)
    static let whereIs = QuestionType(title: "Where", check: { $0.lowercased().contains(" where ") || $0.starts(with: "Where")}, searchFunctionCode: 9)
    static let howMany = QuestionType(title: "How Many", check: { $0.lowercased().contains(" how many ") }, searchFunctionCode: 10) // TODO`
    //static let comparison = AnswerType(title: "Comparison", check: { $0.lowercased().containsAtLeastOne("most", "least", "closest", "furthest", "largest", "smallest", "biggest")}, searchFunctionCode: 11)
    static let otherTwo = QuestionType(title: "Other Two", check: { $0.lowercased().contains(" other two ") }, searchFunctionCode: 12)
    static let isWhat = QuestionType(title: "Is What", check: { $0.contains("is what?") }, searchFunctionCode: 13)
    static let midWhat = QuestionType(title: "Middle What", check: { $0.contains(" what") }, searchFunctionCode: 14)
    static let endWhat = QuestionType(title: "End What", check: { $0.hasSuffix("what?") }, searchFunctionCode: 15)
    static let definition = QuestionType(title: "Definition", check: { $0.starts(with: "What") && $0.contains("word") && $0.contains("mean") }, searchFunctionCode: 16)
}
