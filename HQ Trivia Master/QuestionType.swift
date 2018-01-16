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
struct QuestionType : Equatable, CustomStringConvertible, CustomDebugStringConvertible
{
    let title : String
    let check : (String) -> Bool
    let searchFunctionCode : Int
    
    var description : String { return title }
    var debugDescription : String { return description }
    
    private init(title: String, searchFunctionCode: Int, check: @escaping (String) -> Bool)
    {
        self.title = title
        self.searchFunctionCode = searchFunctionCode
        self.check = check
    }
    
    static func == (lhs: QuestionType, rhs: QuestionType) -> Bool
    {
        return lhs.searchFunctionCode == rhs.searchFunctionCode
    }
    
    static let other = QuestionType(title: "Unknown", searchFunctionCode: 0) { !$0.isEmpty }
    
    static let startsWhich = QuestionType(title: "Starts with \"Which\"", searchFunctionCode: 1) { $0.starts(with: "Which") }
    
    static let startWhat = QuestionType(title: "Start with \"What\"", searchFunctionCode: 2) { $0.starts(with: "What") }
    
    static let whichOfThese = QuestionType(title: "Which of These", searchFunctionCode: 3) { $0.lowercased().contains(atLeastOneElementIn: ["which of these", "which one of these", "which of the following"]) }
    
    static let midWhich = QuestionType(title: "Middle Which", searchFunctionCode: 4) { $0.contains(" which ") }
    
    static let correctSpelling = QuestionType(title: "Correct Spelling", searchFunctionCode: 5) { $0.contains(atLeastOneElementIn: ["spelling", "spelled", " spell "]) }
    
    static let whose = QuestionType(title: "Whose", searchFunctionCode: 6) { $0.lowercased().contains("whose") }
    
    static let not = QuestionType(title: "Not", searchFunctionCode: 7) { $0.lowercased().contains(atLeastOneElementIn: [" not ", " no ", " never "]) }
    
    static let who = QuestionType(title: "Who", searchFunctionCode: 8) { $0.lowercased().contains(atLeastOneElementIn: ["who ", " who ", " who's", "whom"]) }
    
    static let whereIs = QuestionType(title: "Where", searchFunctionCode: 9) { $0.lowercased().contains(" where ") || $0.starts(with: "Where") }
    
    static let howMany = QuestionType(title: "How Many", searchFunctionCode: 10) { $0.lowercased().contains(" how many ") } // TODO`
    
    //static let comparison = AnswerType(title: "Comparison", searchFunctionCode: 11) { $0.lowercased().containsAtLeastOne("most", "least", "closest", "furthest", "largest", "smallest", "biggest") }
    
    static let otherTwo = QuestionType(title: "Other Two", searchFunctionCode: 12) { $0.lowercased().contains(" other two ") }
    
    static let isWhat = QuestionType(title: "Is What", searchFunctionCode: 13) { $0.contains("is what?") }
    
    static let midWhat = QuestionType(title: "Middle What", searchFunctionCode: 14) { $0.contains(" what") }
    
    static let endWhat = QuestionType(title: "End What", searchFunctionCode: 15) { $0.hasSuffix("what?") }
    
    static let definition = QuestionType(title: "Definition", searchFunctionCode: 16) { $0.starts(with: "What") && $0.contains("word") && $0.contains("mean") }
    
    static fileprivate let all : [QuestionType] = [.not, .definition, .otherTwo, .whichOfThese, .midWhich, .correctSpelling, .whose, .who, .howMany, .startsWhich, .isWhat, .startWhat, .endWhat, .midWhat, .whereIs]
    static fileprivate let uniqueQuestionTypes : [QuestionType] = [.definition, .howMany, .correctSpelling, .whereIs]
    static fileprivate let startingQuestionTypes : [QuestionType] = [.startWhat, .startsWhich, .whose, .who, .whichOfThese]
    static fileprivate let middleQuestionTypes : [QuestionType] = [.midWhat, .midWhich]
    static fileprivate let endingQuestionTypes : [QuestionType] = [.isWhat, .endWhat, .otherTwo]
}

struct QuestionAnalysis : CustomStringConvertible, CustomDebugStringConvertible
{
    private static let UniqueQuestionTypeCategory = "unique"
    private static let StartingQuestionTypeCategory = "starting"
    private static let MiddleQuestionTypeCategory = "middle"
    private static let EndingQuestionTypeCategory = "ending"
    private static let categoriesToTypes = [UniqueQuestionTypeCategory : QuestionType.uniqueQuestionTypes, StartingQuestionTypeCategory : QuestionType.startingQuestionTypes, MiddleQuestionTypeCategory : QuestionType.middleQuestionTypes, EndingQuestionTypeCategory : QuestionType.endingQuestionTypes]
    
    private var question = ""
    private(set) var isNot = false
    private(set) var unique = QuestionType.other
    private(set) var start = QuestionType.other
    private(set) var middle = QuestionType.other
    private(set) var ending = QuestionType.other
    private(set) var invalid = false
    private var issueQuestionType : QuestionType?
    private var issuingQuestionType : QuestionType?
    private var category : String?
    
    var description : String
    {
        var string = "Question Analysis for \"\(question)\":\n"
        guard !invalid else
        {
            string += "!!--Question is invalid--!!\n"
            if let issueQuestionType = issueQuestionType, let issuingQuestionType = issuingQuestionType, let category = category, let questionTypesForCategory = QuestionAnalysis.categoriesToTypes[category]
            {
                string += "Question contained a QuestionType of ((\(issueQuestionType))) but ((\(issuingQuestionType))) was found later in the question.\n"
                string += "For a question to be valid, it must contain only one of the following: \(questionTypesForCategory)"
            }
            else
            {
                string += "Question Analysis determined the question to be invalid and could not futher determine the issue"
            }
            return string
        }
        string += "!!--Question is valid--!!\n"
        string = addMainProperties(to: string)
        
        return string
    }
    
    var debugDescription: String
    {
        var string = "Debugging Question Analysis for \"\(question)\":\n"
        string = addMainProperties(to: string)
        string += "\nQuestion is invalid: \(invalid)\n"
        string += "\nIssue QuestionType: \(issueQuestionType?.title ?? "No Issue QuestionType")\n"
        string += "\nIssuing QuestionType: \(issuingQuestionType?.title ?? "No Issuing QuestionType")\n"
        string += "\nIssue Category: \(category ?? "No Category")\n"
        
        return string
    }
    
    init(question: String)
    {
        self.question = question
        
        var isNot = false
        var unique : QuestionType?
        var start : QuestionType?
        var middle : QuestionType?
        var ending : QuestionType?
        
        for type in question.questionType
        {
            var questionTypeToCheck : String?
            if type == .not
            {
                isNot = true
                continue
            }
            else if QuestionType.uniqueQuestionTypes.contains(type)
            {
                questionTypeToCheck = QuestionAnalysis.UniqueQuestionTypeCategory
            }
            else if QuestionType.startingQuestionTypes.contains(type)
            {
                questionTypeToCheck = QuestionAnalysis.StartingQuestionTypeCategory
            }
            else if QuestionType.middleQuestionTypes.contains(type)
            {
                questionTypeToCheck = QuestionAnalysis.MiddleQuestionTypeCategory
            }
            else if QuestionType.endingQuestionTypes.contains(type)
            {
                questionTypeToCheck = QuestionAnalysis.EndingQuestionTypeCategory
            }
            
            guard let questionTypeToCheckNonNil = questionTypeToCheck else
            {
                self.resetMainProperties()
                self.invalid = true
                return
            }
            guard (questionTypeToCheckNonNil == QuestionAnalysis.UniqueQuestionTypeCategory ? unique : questionTypeToCheckNonNil == QuestionAnalysis.StartingQuestionTypeCategory ? start : questionTypeToCheckNonNil == QuestionAnalysis.MiddleQuestionTypeCategory ? middle : ending) == nil else
            {
                setInvalid(withIssueQuestionType: (questionTypeToCheckNonNil == QuestionAnalysis.UniqueQuestionTypeCategory ? unique : questionTypeToCheckNonNil == QuestionAnalysis.StartingQuestionTypeCategory ? start : questionTypeToCheckNonNil == QuestionAnalysis.MiddleQuestionTypeCategory ? middle : ending), issuingQuestionType: type, category: questionTypeToCheckNonNil)
                return
            }
            switch questionTypeToCheckNonNil
            {
            case QuestionAnalysis.UniqueQuestionTypeCategory:
                unique = type
                
            case QuestionAnalysis.StartingQuestionTypeCategory:
                start = type
                
            case QuestionAnalysis.MiddleQuestionTypeCategory:
                middle = type
                
            default:
                ending = type
            }
        }
        
        self.isNot = isNot
        if let uniqueNonNil = unique
        {
            self.unique = uniqueNonNil
        }
        if let startNonNil = start
        {
            self.start = startNonNil
        }
        if let middleNonNil = middle
        {
            self.middle = middleNonNil
        }
        if let endingNonNil = ending
        {
            self.ending = endingNonNil
        }
    }
    
    private func addMainProperties(to: String) -> String
    {
        var string = to
        if isNot
        {
            string += "Question contains \"not\"\n"
        }
        if unique != .other
        {
            string += "Unique QuestionType: \(unique)\n"
        }
        if start != .other
        {
            string += "Beginning QuestionType: \(start)\n"
        }
        if middle != .other
        {
            string += "Middle QuestionType: \(middle)\n"
        }
        if ending != .other
        {
            string += "Ending QuestionType: \(ending)\n"
        }
        return string
    }
    
    mutating private func resetMainProperties()
    {
        isNot = false
        unique = QuestionType.other
        start = QuestionType.other
        middle = QuestionType.other
        ending = QuestionType.other
    }
    
    mutating private func setInvalid(withIssueQuestionType issueQuestionType: QuestionType?, issuingQuestionType: QuestionType, category: String)
    {
        resetMainProperties()
        invalid = true
        guard let issueQuestionType = issueQuestionType else { return }
        self.issueQuestionType = issueQuestionType
        self.issuingQuestionType = issuingQuestionType
        self.category = category
    }
}

extension String
{
    ///A list of hot phrases to replace in a question
    private static let replacementWords = ["which of these", "which one of these", "whose", "who", "whom", "which", "what", "where"]
    
    /**
     Returns a list of all possible `QuestionType` for the given Question.  To be a Question, `self` must end with a "?".  A Question can have be of multiple types.
     
     i.e.
     
         "What is NOT...?"
     is both a "Starts with What" and a "Not" question
     */
    var questionType : [QuestionType]
    {
        guard hasSuffix("?") else { return [] }
        let questionTypes = QuestionType.all.filter { $0.check(self) }
        return questionTypes.isEmpty ? [.other] : questionTypes
    }
    
    /**
     Replaces any instance of hot phrases with the specified String
     - Parameter replacementString: The string to substitute in
     - Returns: A lowercased string with all instances of hot phrases replaced with the specified string
     */
    func replacingHotPhrases(with replacementString: String) -> String
    {
        let lowercaseQuestion = lowercased()
        for hotPhrase in String.replacementWords where lowercaseQuestion.contains(hotPhrase)
        {
            return lowercaseQuestion.replacingOccurrences(of: hotPhrase, with: replacementString)
        }
        return self
    }
}
