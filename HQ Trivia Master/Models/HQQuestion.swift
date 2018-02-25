//
//  HQQuestion.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 2/22/18.
//  Copyright © 2018 Daniel Smith. All rights reserved.
//

import Foundation

struct HQQuestion
{
    var question: String
    var possibleAnswers: [String]
    var category: String
    var questionType: QuestionType
    var questionNumber: Int
    
    init(_ json: [String: Any])
    {
        possibleAnswers = [String]()
        
        question = json["question"] as? String ?? "Error"
        category = json["category"] as? String ?? "Error"
        questionType = AnswerController.type(forQuestion: question)
        questionNumber = json["questionNumber"] as? Int ?? 0
        
        if let answers = json["answers"] as? [[String: Any]]
        {
            for answer in answers
            {
                let text = answer["text"] as? String ?? "Error"
                possibleAnswers.append(text)
            }
        }
    }
}
