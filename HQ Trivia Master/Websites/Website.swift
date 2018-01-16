//
//  Website.swift
//  HQ Trivia Master
//
//  Created by Michael Schloss on 1/10/18.
//  Copyright © 2018 Daniel Smith. All rights reserved.
//

import Foundation

protocol Website
{
    /**
     Processes a question for an internet search.  Easy `QuestionType` the question contains could require slightly different processing.   This method should be ansynchronous and return control as soon as possible.
     - Parameter question: The text entered into the question field in the UI
     - Parameter possibleAnswers: A list of strings entered into the 3 Option fields in the UI
     - Parameter completion: A closure accepting an `AnswerCounts` instance
     - Parameter answerCounts: An `AnswerCounts` instance
     */
    func process(question: String, possibleAnswers: [String], completion: @escaping (_ answerCounts: AnswerCounts) -> Void)
    
    /**
     Reaches out to a web page to perform the search.  This method should be ansynchronous and return control as soon as possible.
     - Parameter search: The string to send up to the webpage
     - Parameter completion: A closure called once data has been returned and processed
     - Parameter snippet: A snippet of the returned results
     - Parameter numberOfResults: The number of results returned from the site
     */
    func perform(search: String, completion: @escaping (_ snippet: String?, _ numberOfResults: Int) -> Void)
}
