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
    /**
     Attempts to answer a question by using Google.  Questions can range in type, as such this method serves as a delegator to various question types
     - Parameter question: The question being asked
     - Parameter answers: The list of answers
     - Parameter completion: A closure accepting the correct answer
     - Parameter answer: An instance on `Answer` containing the correct answer and probabilities for all 3 answers
     */
    static func predictedAnswer(for question: String, answers: [String], using siteEncoding: SiteEncoding, completion: @escaping (_ answer: Answer) -> ())
    {
        let questionTypes = question.questionType
        
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
            print("Question types: \(questionTypes)")
            print("Question search function codes: \(questionTypes.map({ return $0.searchFunctionCode }))")
        }
        
        if questionTypes.contains(.correctSpelling)
        {
            let matches = AnswerController.matches(withCorrectlySpelledAnswers: answers)
            processAnswer(for: matches)
        }
        else
        {
            siteEncoding.website.process(question: question, possibleAnswers: answers, completion: { answerCounts in
                processAnswer(for: answerCounts)
            })
        }
    }
    
    /*
    /**
     Dispatches more precise question answering
     - Parameter question: The question being asked
     - Parameter answers: The answers
     - Parameter completion: A closure accepting an `AnswerCounts` object
     - Parameter counts: An `AnswerCounts` object that hold the number of results for each answer
     */
    private static func matches(for question: String, answers: [String], completion: @escaping (_ counts: AnswerCounts) -> ())
    {
        let type = AnswerController.type(forQuestion: question)
        switch type.searchFunctionCode
        {
        case 13:
            Google.numberOfResultsBasedMatches(for: question, including: answers) { matches in
                completion(matches)
            }
        case 1, 3, 4, 9, 16:
            Google.matches(for: question, withReplacingLargestAnswerIn: answers, queryContainsQuestion: true) { matches in
                completion(matches)
            }
        case 2, 6, 8:
            Google.matches(for: question, withReplacingLargestAnswerIn: answers) { matches in
                completion(matches)
            }
        case 10, 11, 14:
            Google.matches(for: question, including: answers) { matches in
                completion(matches)
            }
        case 7:
            Google.inverseMatches(for: question, with: answers) { matches in
                completion(matches)
            }
        case 5:
            let matches = AnswerController.matches(withCorrectlySpelledAnswers: answers)
            completion(matches)
            break
        case 15:
            Google.matches(for: question, including: answers) { matches in
                completion(matches)
            }
        default:
            Google.matches(for: question, including: answers) {
                matches in
                completion(matches)
            }
        }
    }*/
    
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
