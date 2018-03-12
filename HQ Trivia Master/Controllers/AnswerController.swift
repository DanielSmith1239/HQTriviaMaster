//
//  AnswerController.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 11/8/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import AppKit

/**
 Stores information about each answer and its probability of being the correct answer
 
 The most probable answer is stored separately for more explicit and quicker recall
 */
struct Answer
{
    let correctAnswer : String
    let probability : CGFloat
    
    let others : [(String, CGFloat)]
    
    init(correctAnswer: String, probability: CGFloat, others: [(String, CGFloat)])
    {
        self.correctAnswer = correctAnswer
        self.probability = probability
        self.others = others
    }
}

class AnswerController
{
    private static let questionTypes : [QuestionType] = [.not, .definition, .otherTwo, .whichOfThese, .midWhich, .correctSpelling, .whose, .who, .howMany, .startsWhich, .isWhat, .startWhat, .endWhat, .midWhat, .whereIs, .other]
    
    /**
     Attempts to answer a question by using Google.  Questions can range in type, as such this method serves as a delegator to various question types
     - Parameter question: The question being asked
     - Parameter answers: The list of answers
     - Parameter completion: A closure accepting the correct answer
     - Parameter answer: An instance on `Answer` containing the correct answer and probabilities for all 3 answers
     */
    static func answer(for hqQuestion: HQQuestion, completion: @escaping (_ answer: Answer) -> ())
    {
        func processAnswer(for matches: AnswerCounts)
        {
            if HQTriviaMaster.debug
            {
                print("\nAnswers:\n\(matches)")
            }
            let largestMatch = matches.largest
            let sum : Int = matches.sumOfResults
            var others = [(String, CGFloat)]()
            if sum == 0
            {
                completion(Answer(correctAnswer: "", probability: 0.0, others: []))
            }
            else
            {
                for match in matches.dump where match.0 != largestMatch.0
                {
                    others.append((match.0, CGFloat(match.1) / CGFloat(sum)))
                }
                completion(Answer(correctAnswer: largestMatch.0, probability: CGFloat(largestMatch.1) / CGFloat(sum), others: others))
            }
        }
        
        if HQTriviaMaster.debug
        {
            print("Question type: \(hqQuestion.questionType.title)")
            print("Question search function code: \(hqQuestion.questionType.searchFunctionCode)")
        }
        
        switch hqQuestion.questionType.searchFunctionCode
        {
        case 5, 7, 3:
            //Questions that include "not", questions that are spelling questions, and questions that ask "which of these" cannot be easily answered, and thus require more precise processing
            matches(for: hqQuestion) { matches in
                processAnswer(for: matches)
            }
            
        default:
            //For everything else, questions have the potential to be answered without needing precision
            Google.matches(for: hqQuestion) { matches in
                guard matches.count != 1, matches.largest.1 > 0 else
                {
                    //We need precision anyways since the imprecise didn't give us enough accuracy
                    AnswerController.matches(for: hqQuestion) { matches in
                        processAnswer(for: matches)
                    }
                    return
                }
                processAnswer(for: matches)
            }
        }
    }
    
    /**
     Dispatches more precise question answering
     - Parameter question: The question being asked
     - Parameter answers: The answers
     - Parameter completion: A closure accepting an `AnswerCounts` object
     - Parameter counts: An `AnswerCounts` object that hold the number of results for each answer
     */
    private static func matches(for hqQuestion: HQQuestion, completion: @escaping (_ counts: AnswerCounts) -> ())
    {
        switch hqQuestion.questionType.searchFunctionCode
        {
        case 13:
            Google.numberOfResultsBasedMatches(for: hqQuestion.question, including: hqQuestion.possibleAnswers) { matches in
                completion(matches)
            }
        case 1, 4, 6:
            Google.matches(replacingLargestAnswerIn: hqQuestion) { matches in
                completion(matches)
            }
        case 2, 8, 9, 14, 16:
            Google.matches(replacingLargestAnswerIn: hqQuestion, queryContainsQuestion: true) { matches in
                completion(matches)
            }
        case 3, 15:
            Google.matches(replacingLargestAnswerIn: hqQuestion, queryContainsQuestion: true, withInText: true) { matches in
                completion(matches)
            }
        case 7:
            Google.inverseMatches(for: hqQuestion) { matches in
                completion(matches)
            }
        case 5:
            let matches = AnswerController.matches(withCorrectlySpelledAnswers: hqQuestion.possibleAnswers)
            completion(matches)
            break
        default: // 10, 11, 15, others
            Google.matches(for: hqQuestion) { matches in
                completion(matches)
            }
        }
    }
    
    /**
     Determines the type of question being asked
     - Parameter question: The questin being asked
     - Returns: An `QuestionType` determining the type of question that is being asked
     */
    static func type(forQuestion question: String) -> QuestionType
    {
        for type in questionTypes
        {
            if type.check(question)
            {
                return type
            }
        }
        return QuestionType.other
    }
    
    /**
     Finds the first answer in a list of answers that is spelled correctly.  Can be done locally as macOS has a built-in spell checker
     - Parameter: answers: A list of answers to check against
     - Returns: An `AnswerCounts` object where the correct answer will be the one with a `1`
     */
    static func matches(withCorrectlySpelledAnswers answers: [String]) -> AnswerCounts
    {
        var answerCounts = AnswerCounts()
        for answer in answers
        {
            let corrector = NSSpellChecker.shared
            let range = corrector.checkSpelling(of: answer, startingAt: 0)
            if range.length == 0
            {
                answerCounts[answer] = 1
                break
            }
        }
        return answerCounts
    }
}
