//
//  TestController.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 3/1/18.
//  Copyright © 2018 Daniel Smith. All rights reserved.
//

import Foundation

class TestController
{
    public static func testQuestionWithAllFunctions(hqQuestion: HQQuestion)
    {
        print("Testing question: \(hqQuestion.question)")
        print("Type: \(hqQuestion.questionType)")
        
        // Method 1
        Google.numberOfResultsBasedMatches(for: hqQuestion.question, including: hqQuestion.possibleAnswers) { matches in
            processAnswer(matches, methodNum: 1)
        }
        
        // Method 2
        Google.matches(replacingLargestAnswerIn: hqQuestion, queryContainsQuestion: true) { matches in
            processAnswer(matches, methodNum: 2)
        }
        
        // Method 3
        Google.matches(replacingLargestAnswerIn: hqQuestion, queryContainsQuestion: true, withInText: true) { matches in
            processAnswer(matches, methodNum: 3)
        }
        
        // Method 4
        Google.matches(replacingLargestAnswerIn: hqQuestion) { matches in
            processAnswer(matches, methodNum: 4)
        }
        
        // Method 5
        Google.inverseMatches(for: hqQuestion) { matches in
            processAnswer(matches, methodNum: 5)
        }
        
        // Method 6
        Google.matches(withCategory: hqQuestion) { matches in
            processAnswer(matches, methodNum: 6)
        }
        
        func processAnswer(_ matches: AnswerCounts, methodNum: Int)
        {
            if HQTriviaMaster.debug
            {
                print("\nAnswers for method \(methodNum):\n\(matches)")
            }
            let largestMatch = matches.largest
            let sum : Int = matches.sumOfResults
            var others = [(String, CGFloat)]()
            if sum == 0
            {
                print("Error: No clue what the answer is.")
            }
            else
            {
                for match in matches.dump where match.0 != largestMatch.0
                {
                    others.append((match.0, CGFloat(match.1) / CGFloat(sum)))
                }
                print("Correct: \(largestMatch.0): \(largestMatch.1)")
            }
        }
    }
}
