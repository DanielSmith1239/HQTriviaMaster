//
//  ViewController.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 10/31/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Cocoa
import AVFoundation

class ViewController: NSViewController, NSTextFieldDelegate, InteractableWindowDelegate
{
    @IBOutlet private var questionField : NSTextField!
    @IBOutlet private var optionOneField : NSTextField!
    @IBOutlet private var optionTwoField : NSTextField!
    @IBOutlet private var optionThreeField : NSTextField!
    @IBOutlet private var optionOneMatchesLabel : NSTextField!
    @IBOutlet private var optionTwoMatchesLabel : NSTextField!
    @IBOutlet private var optionThreeMatchesLabel : NSTextField!
    @IBOutlet private var startScanningButton : NSButton!
    @IBOutlet private var answerButton : NSButton!
    @IBOutlet private var resetButton : NSButton!
    
    private lazy var labels = { return [optionOneField : optionOneMatchesLabel, optionTwoField : optionTwoMatchesLabel, optionThreeField : optionThreeMatchesLabel] }()
    private var screenshotRect = NSRect.zero
    private var interactableWindow : InteractableWindow?
    
    ///Manually starts the answering process
    @IBAction private func answerButtonPressed(_ sender: NSButton)
    {
        clearMatches()
        getMatches()
    }
    
    ///Starts automated scanning of the specified boundry
    @IBAction private func scanButtonPressed(_ sender: NSButton)
    {
        if sender.title.contains("Start")
        {
            sender.title = "Stop Scanning"
            takeScreenshot()
        }
        else
        {
            sender.title = "Start Scanning"
            NSObject.cancelPreviousPerformRequests(withTarget: self)
        }
    }
    
    ///Resets all fields and stops scanning
    @IBAction private func clearFields(sender: NSButton)
    {
        self.answerButton.isEnabled = false
        self.resetButton.isEnabled = false
        self.startScanningButton.title = "Start Scanning"
        internalClearFields()
    }
    
    ///Allows the user to draw a boundry for which to monitor the screen
    @IBAction private func defineBoundry(sender: NSButton)
    {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        startScanningButton.title = "Start Scanning"
        
        if let window = interactableWindow
        {
            window.becomeKey()
            window.setIsVisible(true)
            window.becomeFirstResponder()
        }
        else
        {
            let window = InteractableWindow()
            window.interactableWindowDelegate = self
            window.titleVisibility = .hidden
            window.titlebarAppearsTransparent = true
            window.isOpaque = false
            window.backgroundColor = NSColor.black.withAlphaComponent(0.5)
            window.isMovable = false
            window.styleMask.remove(.resizable)
            window.styleMask.insert(.borderless)
            
            let view = NSView()
            view.frame = NSScreen.main?.frame ?? .zero
            let label = NSTextField(labelWithString: "Please choose area of screen to watch for gameplay")
            label.alignment = .center
            label.translatesAutoresizingMaskIntoConstraints = false
            label.textColor = .white
            label.font = .systemFont(ofSize: 50.0, weight: .bold)
            view.addSubview(label)
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            label.topAnchor.constraint(equalTo: view.topAnchor, constant: 40.0).isActive = true
            label.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 1.0, constant: -100).isActive = true
            label.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
            label.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
            label.setContentHuggingPriority(.defaultLow, for: .horizontal)
            label.setContentHuggingPriority(.defaultLow, for: .vertical)
            
            window.contentView = view
            window.setFrame(NSScreen.main?.frame ?? .zero, display: true)
            window.makeKey()
            window.setIsVisible(true)
            window.becomeFirstResponder()
            interactableWindow = window
        }
    }
    
    ///Protocol method that's called when the user has finished choosing their rectangle
    func drew(rect: NSRect)
    {
        screenshotRect = rect
        startScanningButton.isEnabled = true
        view.window?.makeKey()
        interactableWindow?.setIsVisible(false)
    }
    
    override func controlTextDidChange(_ obj: Notification)
    {
        resetButton.isEnabled = !allFieldsAreEmpty()
        answerButton.isEnabled = !fieldIsEmpty()
    }
    
    ///Takes the screenshot
    ///On failure to read, it repeats the screenshot after a 0.3 second wait
    ///On success, it begins to process the information and search for the answer, waiting 10 seconds (this is the amount of time given for each question)
    @objc private func takeScreenshot()
    {
        guard !startScanningButton.title.contains("Start") else { return }
        internalClearFields()
        ScreenshotController.takeScreenshot(inRect: screenshotRect) {
            DispatchQueue.main.async {
                Shell.convertImageToText()
                guard let text = OCROutputController.outputText else { return }
                if HQTriviaMaster.debug
                {
                    print(text)
                }
                self.setFieldValues(fromText: text)
                if !self.fieldIsEmpty()
                {
                    self.perform(#selector(ViewController.takeScreenshot), with: nil, afterDelay: 10.0)
                    self.answerButton.isEnabled = true
                    self.resetButton.isEnabled = true
                    self.clearMatches()
                    self.getMatches()
                }
                else
                {
                    self.perform(#selector(ViewController.takeScreenshot), with: nil, afterDelay: 0.3)
                }
            }
        }
    }
    
    ///Determines if every field is empty
    private func allFieldsAreEmpty() -> Bool
    {
        return questionField.stringValue.isEmpty && optionOneField.stringValue.isEmpty && optionTwoField.stringValue.isEmpty && optionThreeField.stringValue.isEmpty
    }
    
    ///Determines if at least one field is empty
    private func fieldIsEmpty() -> Bool
    {
        return questionField.stringValue.isEmpty || optionOneField.stringValue.isEmpty || optionTwoField.stringValue.isEmpty || optionThreeField.stringValue.isEmpty
    }
    
    ///Clears all data from UI
    private func internalClearFields()
    {
        self.questionField.stringValue = ""
        self.optionOneField.stringValue = ""
        self.optionTwoField.stringValue = ""
        self.optionThreeField.stringValue = ""
        self.clearMatches()
    }
    
    ///Resets the match labels
    private func clearMatches()
    {
        self.optionOneMatchesLabel.stringValue = "---"
        self.optionTwoMatchesLabel.stringValue = "---"
        self.optionThreeMatchesLabel.stringValue = "---"
    }
    
    ///Retrieves the correct answer
    private func getMatches()
    {
        if !fieldIsEmpty()
        {
            let options = [optionOneField.stringValue, optionTwoField.stringValue, optionThreeField.stringValue]
            AnswerController.answer(for: questionField.stringValue, answers: options) { correctAnswer in
                if HQTriviaMaster.debug
                {
                    print("Predicted Correct Answer: \(correctAnswer)")
                }
                self.labels.first(where: { $0.0.stringValue == correctAnswer })?.1?.stringValue = "✔️"
            }
        }
    }
    
    ///Sets the values in UI
    func setFieldValues(fromText text: String)
    {
        var arr = text.split(separator: "\n").filter { !$0.isEmpty}.map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
        guard let questionEnd = findQuestionEnd(arr) else
        {
            return
        }
        
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
        
        let option3 = String(fixedArr.removeLast()).fixedText
        let option2 = String(fixedArr.removeLast()).fixedText
        let option1 = String(fixedArr.removeLast()).fixedText
        let question = String(questionArr.joined()).fixedText
        
        self.optionOneField.stringValue = option1
        self.optionTwoField.stringValue = option2
        self.optionThreeField.stringValue = option3
        self.questionField.stringValue = question
        if AnswerController.type(forQuestion: question) != QuestionType.correctSpelling
        {
            self.fixSpelling()
        }
    }
    
    ///Finds the index of end of the question
    private func findQuestionEnd(_ arr: [String]) -> Int?
    {
        let qElement = arr.filter { $0.replacingOccurrences(of: "\"", with: "?").replacingOccurrences(of: "”", with: "?").last == "?" }
        guard let last = qElement.last else
        {
            return nil
        }
        return arr.index(of: last)
    }
    
    ///Auto-Correct
    private func fixSpelling()
    {
        let corrector = NSSpellChecker.shared
        let fields = [questionField, optionOneField, optionTwoField, optionThreeField]
        for field in fields
        {
            guard var textFieldValue = field?.stringValue else { continue }
            for word in textFieldValue.split(separator: " ")
            {
                let range = corrector.checkSpelling(of: textFieldValue, startingAt: 0)
                if range.length > 0
                {
                    guard let replacement = corrector.correction(forWordRange: range, in: String(word), language: "en", inSpellDocumentWithTag: 0) else
                    {
                        field?.becomeFirstResponder()
                        continue
                    }
                    textFieldValue = textFieldValue.replacingOccurrences(of: word, with: replacement)
                }
            }
            field?.stringValue = textFieldValue
        }
    }
}

