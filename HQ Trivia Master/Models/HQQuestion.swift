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
    var category: String?
    var questionNumber: Int?
    var questionType: QuestionType { return AnswerController.type(forQuestion: question) }
    
    init(_ json: [String: Any])
    {
        possibleAnswers = [String]()
        
        question = json["question"] as? String ?? "Error"
        category = json["category"] as? String
        questionNumber = json["questionNumber"] as? Int

        if let answers = json["answers"] as? [[String: Any]]
        {
            for answer in answers
            {
                let text = answer["text"] as? String ?? "Error"
                possibleAnswers.append(text)
            }
        }
    }
    
    init(questionText: String, answers: [String])
    {
        question = questionText
        possibleAnswers = answers
    }
}
