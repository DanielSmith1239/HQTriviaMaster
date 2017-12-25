//
//  ViewController.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 10/31/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController, NSTextFieldDelegate
{
    @IBOutlet weak var questionField: NSTextField!
    @IBOutlet weak var optionOneField: NSTextField!
    @IBOutlet weak var optionTwoField: NSTextField!
    @IBOutlet weak var optionThreeField: NSTextField!
    
    @IBOutlet weak var optionOneMatchesLabel: NSTextField!
    @IBOutlet weak var optionTwoMatchesLabel: NSTextField!
    @IBOutlet weak var optionThreeMatchesLabel: NSTextField!
    
    @IBOutlet weak var lineSeparator: NSBox!
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        questionField.delegate = self
        optionOneField.delegate = self
        optionTwoField.delegate = self
        optionThreeField.delegate = self
    }
    
    func fixSpelling()
    {
        let corrector = NSSpellChecker.shared
        let fields = [questionField, optionOneField, optionTwoField, optionThreeField]
        for field in fields
        {
            var newStr = field!.stringValue
            for word in newStr.split(separator: " ")
            {
                let range = corrector.checkSpelling(of: newStr, startingAt: 0)
                if range.length > 0
                {
                    if let replacement = corrector.correction(forWordRange: range, in: String(word), language: "en", inSpellDocumentWithTag: 0)
                    {
                        newStr = newStr.replacingOccurrences(of: word, with: replacement)
                    }
                    else
                    {
                        field!.becomeFirstResponder()
                    }
                }
            }
            field?.stringValue = newStr
        }
    }

    @IBAction func answerButtonPressed(_ sender: NSButton)
    {
        clearMatches()
        getMatches()
    }
    
    @IBAction func removeLastButtonPressed(_ sender: Any)
    {
        TestController.removeLastTestQuestion()
    }
    
    func setCorrectLabel(forOption labelNum: Int)
    {
        let labels = [optionOneMatchesLabel, optionTwoMatchesLabel, optionThreeMatchesLabel]
        DispatchQueue.main.async {
            labels[labelNum]!.stringValue = "✔️"
        }
    }
    
    func getLargestIndex(_ arr: [Int]) -> Int
    {
        let last = arr.sorted().last!
        return arr.index(of: last)!
    }
    
    @IBAction func scanButtonPressed(_ sender: Any)
    {
        clearFields()
        let window =  NSApplication.shared.mainWindow!
        let group = DispatchGroup()
        group.enter()
        DispatchQueue.global(qos: .default).async {
            window.setIsVisible(false)
            group.leave()
        }
        
        group.wait()
                
        ScreenshotController.takeScreenshot(vc: self, line: lineSeparator)
        {
            window.setIsVisible(true)
            TerminalController.getImageText()
            let text = OCROutputController.getOutputText()
            self.setFieldValues(fromText: text)
            self.getMatches()
        }
    }
    
    @IBAction func runTestsPressed(_ sender: Any)
    {
        print("Running test...")
        TestController.testAll()
        {
            questionsTested, questionsCorrect in
            print("-----------------------------")
            print("Tested:  \(questionsTested)")
            print("Correct: \(questionsCorrect)")
            print("-----------------------------")
        }
    }
    
    @IBAction func addForTestingPressed(_ sender: Any)
    {
        if !questionField.stringValue.isEmpty,
            !optionOneField.stringValue.isEmpty,
            !optionTwoField.stringValue.isEmpty,
            !optionThreeField.stringValue.isEmpty
        {
            let q: TestController.question = (question: questionField.stringValue, correctOption: optionOneField.stringValue, option2: optionTwoField.stringValue, option3: optionThreeField.stringValue)
            TestController.addTestQuestion(q)
        }
    }
    
    func setFieldValues(fromText text: String)
    {
        var arr = text.split(separator: "\n").filter { !$0.isEmpty}.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        let questionEnd = findQuestionEnd(arr)

        var questionArr = arr[0...questionEnd].map { (value: String) -> String in
            var ret = value
            if ret.first == " " { ret.removeFirst() }
            if ret.last != " " && ret.last != "?" { ret += " " }
            return ret
            }
        
        while questionArr.first!.isEmpty || questionArr.first!.count < 10
        {
            questionArr.removeFirst()
        }
        
        var fixedArr = [String]()
        for op in arr
        {
            if !op.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .illegalCharacters).isEmpty
            {
                fixedArr.append(op)
            }
        }
        
        let option3 = TextController.getFixedText(String(fixedArr.removeLast()))
        let option2 = TextController.getFixedText(String(fixedArr.removeLast()))
        let option1 = TextController.getFixedText(String(fixedArr.removeLast()))
        let question = TextController.getFixedText(String(questionArr.joined()))

        DispatchQueue.main.async
        {
            self.optionOneField.stringValue = option1
            self.optionTwoField.stringValue = option2
            self.optionThreeField.stringValue = option3
            self.questionField.stringValue = question
            if AnswerController.getTypeForQuestion(question) != AnswerType.correctSpelling
            {
                self.fixSpelling()
            }
        }
    }
    
    private func findQuestionEnd(_ arr: [String]) -> Int
    {
        let qElement = arr.filter { $0.replacingOccurrences(of: "\"", with: "?").replacingOccurrences(of: "”", with: "?").last == "?" }
        return arr.index(of: qElement.last!)!
    }
    
    func getMatches()
    {
        if !questionField.stringValue.isEmpty,
            !optionOneField.stringValue.isEmpty,
            !optionTwoField.stringValue.isEmpty,
            !optionThreeField.stringValue.isEmpty
        {
            let options = [optionOneField.stringValue, optionTwoField.stringValue, optionThreeField.stringValue]
            AnswerController.getAnswer(question: questionField.stringValue, options: options)
            {
                correctIndexes in
                for correct in correctIndexes
                {
                    self.setCorrectLabel(forOption: correct)
                }
            }
        }
    }
    
    func clearFields()
    {
        DispatchQueue.main.async
        {
            self.questionField.stringValue = ""
            self.optionOneField.stringValue = ""
            self.optionTwoField.stringValue = ""
            self.optionThreeField.stringValue = ""
            self.clearMatches()
        }
    }
    
    func clearMatches()
    {
        DispatchQueue.main.async
        {
            self.optionOneMatchesLabel.stringValue = "---"
            self.optionTwoMatchesLabel.stringValue = "---"
            self.optionThreeMatchesLabel.stringValue = "---"
        }
    }
}

