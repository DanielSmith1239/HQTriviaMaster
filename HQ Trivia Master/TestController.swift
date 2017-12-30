//
//  TestController.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 11/5/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Foundation

class TestController
{
    typealias question = (question: String, correctOption: String, option2: String, option3: String)
    
    private static var testQuestions: [question]
    {
        get
        {
            if let items = UserDefaults.standard.object(forKey: "questions") as? [[String]]
            {
                if items.count == 0
                {
                    return [question]()
                }
                return items.map { (question: $0[0], correctOption: $0[1], option2: $0[2], option3: $0[3]) }
            }
            else
            {
                UserDefaults.standard.set([[String]](), forKey: "questions")
                return UserDefaults.standard.object(forKey: "questions") as! [question]
            }
        }
        set
        {
            let new = newValue.map { [$0.question, $0.correctOption, $0.option2, $0.option3] }
             UserDefaults.standard.set(new, forKey: "questions")
        }
    }
    
    static func addTestQuestion(_ q: question)
    {
        testQuestions.append(q)
    }
    
    static func removeLastTestQuestion()
    {
        testQuestions.removeLast()
    }
    
    static func testAll(completion: @escaping (Int, Int) -> ())
    {
        var questionsTested = 0
        var questionsCorrect = 0
        var correctQuestions = [String]()
        for q in testQuestions
        {
            testQuestion(for: q)
            {
                didPass in
                if didPass { correctQuestions.append(q.question) }
                questionsTested += 1
                questionsCorrect += didPass ? 1 : 0
                if questionsTested == testQuestions.count
                {
                    completion(questionsTested, questionsCorrect)
                }
            }
        }
    }
    
    private static func testQuestion(for q: question, completion: @escaping (Bool) -> ())
    {
        let options = [q.correctOption, q.option2, q.option3]
        
        AnswerController.getAnswer(question: q.question, options: options)
        {
            correct in
            if correct.isEmpty
            {
                completion(false)
            }
            else
            {
                let didPass = correct[0] == 0
                print("*************************")
                print("\(q.question)")
                print("(\(AnswerController.getTypeForQuestion(q.question).title))")
                print(" - \(q.correctOption)")
                print(" - \(q.option2)")
                print(" - \(q.option3)")
                print("       \(didPass ? "😀" : "☠️")")
                print("*************************")
                completion(didPass)
            }
        }
    }
    
    private static func getLargestIndex(_ arr: [Int]) -> Int
    {
        let last = arr.sorted().last!
        return arr.index(of: last)!
    }
}
