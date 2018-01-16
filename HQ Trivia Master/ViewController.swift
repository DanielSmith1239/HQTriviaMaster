//
//  ViewController.swift
//  HQ Trivia Master
//
//  Created by Daniel Smith on 10/31/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTextFieldDelegate, InteractableWindowDelegate
{
    @IBOutlet private var questionField : NSTextField!
    @IBOutlet private var optionOneField : NSTextField!
    @IBOutlet private var optionTwoField : NSTextField!
    @IBOutlet private var optionThreeField : NSTextField!
    @IBOutlet private var optionOneMatchesLabel : NSTextField!
    @IBOutlet private var optionTwoMatchesLabel : NSTextField!
    @IBOutlet private var optionThreeMatchesLabel : NSTextField!
    @IBOutlet private var questionTypeLabel : NSTextField!
    @IBOutlet private var startScanningButton : NSButton!
    @IBOutlet private var answerButton : NSButton!
    @IBOutlet private var resetButton : NSButton!
    
    @IBOutlet private var optionOneCorrectBox : NSBox!
    @IBOutlet private var optionTwoCorrectBox : NSBox!
    @IBOutlet private var optionThreeCorrectBox : NSBox!
    @IBOutlet private var optionOneCorrectCenterConstraint : NSLayoutConstraint!
    @IBOutlet private var optionTwoCorrectCenterConstraint : NSLayoutConstraint!
    @IBOutlet private var optionThreeCorrectCenterConstraint : NSLayoutConstraint!
    private var optionOneCorrectOffScreenCenterConstraint : NSLayoutConstraint?
    private var optionTwoCorrectOffScreenCenterConstraint : NSLayoutConstraint?
    private var optionThreeCorrectOffScreenCenterConstraint : NSLayoutConstraint?
    
    private lazy var labels = { return [optionOneField : optionOneMatchesLabel, optionTwoField : optionTwoMatchesLabel, optionThreeField : optionThreeMatchesLabel] }()
    private var screenshotRect = NSRect.zero
    private var interactableWindow : InteractableWindow?
    
    override func viewDidLoad()
    {
        hideAnswerBoxes()
    }
    
    override func viewDidAppear()
    {
        super.viewDidAppear()
        if Shell.sipCheck(), UserDefaults.standard.bool(forKey: "ShowSIPDialog"), let window = view.window
        {
            let alert = NSAlert()
            alert.messageText = "System Integrity Protection Enabled"
            alert.informativeText = "System Integrety Protection (SIP) is enabled.  HQ Trivia Master may have issues communicating with Tesseract and ImageMagick.  If you experience issues, you will need to disable SIP.  To disable SIP, reboot to Recovery and run \"csrutil disable\" in Terminal"
            alert.showsSuppressionButton = true
            alert.beginSheetModal(for: window, completionHandler: { _ in
                if alert.suppressionButton?.state == .on
                {
                    UserDefaults.standard.set(true, forKey: "ShowSIPDialog")
                }
            })
        }
        let hasRequiredFiles = Shell.checkForRequiredFiles()
        if !hasRequiredFiles.hasConvert || !hasRequiredFiles.hasTesseract, let window = view.window
        {
            let alert = NSAlert()
            alert.messageText = "Missing Files"
            switch hasRequiredFiles
            {
            case (false, false):
                alert.informativeText = "You are missing Tesseract and ImageMagick.  You can install them by running \"brew install tesseract imagemagick\" if you have Homebrew installed."
                
            case (false, true):
                alert.informativeText = "You are missing ImageMagick.  You can install it by running \"brew install imagemagick\" if you have Homebrew installed."
                
            case (true, false):
                alert.informativeText = "You are missing Tesseract.  You can install it by running \"brew install tesseract\" if you have Homebrew installed."
                
            default: return
            }
            alert.beginSheetModal(for: window, completionHandler: { _ in exit(-1) })
            return
        }
        SiteEncoding.checkGoogleAPICredentials()
    }
    
    @IBAction func showGoogleAPIChangeWindow(sender: Any)
    {
        SiteEncoding.checkGoogleAPICredentials(force: true)
    }
    
    ///Manually starts the answering process
    @IBAction private func answerButtonPressed(_ sender: NSButton)
    {
        clearMatches()
        getMatches()
    }
    
    ///Starts automated scanning of the specified boundary
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
    
    ///Allows the user to draw a boundary for which to monitor the screen
    @IBAction private func defineboundary(sender: NSButton)
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
            window.setup()
            window.setFrame(NSScreen.main?.frame ?? .zero, display: true)
            window.makeKey()
            window.setIsVisible(true)
            window.becomeFirstResponder()
            view.window?.resignFirstResponder()
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
    
    /**
     Removes the green overlays from screen possibly with an animation
     - Parameter shouldAnimate: Determines whether the transition off-screen should be animated or not.  Defaults to `false`
     */
    private func hideAnswerBoxes(shouldAnimate: Bool = false)
    {
        if self.optionOneCorrectOffScreenCenterConstraint == nil
        {
            self.optionOneCorrectOffScreenCenterConstraint = NSLayoutConstraint(item: self.optionOneCorrectBox, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        }
        if self.optionTwoCorrectOffScreenCenterConstraint == nil
        {
            self.optionTwoCorrectOffScreenCenterConstraint = NSLayoutConstraint(item: self.optionTwoCorrectBox, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        }
        if self.optionThreeCorrectOffScreenCenterConstraint == nil
        {
            self.optionThreeCorrectOffScreenCenterConstraint = NSLayoutConstraint(item: self.optionThreeCorrectBox, attribute: .leading, relatedBy: .equal, toItem: self.view, attribute: .trailing, multiplier: 1.0, constant: 0.0)
        }
        
        if shouldAnimate
        {
            NSAnimationContext.runAnimationGroup({ context in
                context.duration = 0.2
                context.allowsImplicitAnimation = true
                
                self.optionOneCorrectCenterConstraint.animator().isActive = false
                self.optionTwoCorrectCenterConstraint.animator().isActive = false
                self.optionThreeCorrectCenterConstraint.animator().isActive = false
                self.optionOneCorrectOffScreenCenterConstraint?.animator().isActive = true
                self.optionTwoCorrectOffScreenCenterConstraint?.animator().isActive = true
                self.optionThreeCorrectOffScreenCenterConstraint?.animator().isActive = true
                self.view.animator().layout()
            }, completionHandler: nil)
        }
        else
        {
            optionOneCorrectCenterConstraint.isActive = false
            optionTwoCorrectCenterConstraint.isActive = false
            optionThreeCorrectCenterConstraint.isActive = false
            optionOneCorrectOffScreenCenterConstraint?.isActive = true
            optionTwoCorrectOffScreenCenterConstraint?.isActive = true
            optionThreeCorrectOffScreenCenterConstraint?.isActive = true
        }
    }
    
    /**
     Takes the screenshot.
     
     On failure to read, it repeats the screenshot after a 0.3 second wait.
     
     On success, it begins to process the information and search for the answer, waiting 20 seconds (this is the amount of time given for each question)
     */
    @objc private func takeScreenshot()
    {
        guard !startScanningButton.title.contains("Start") else { return }
        internalClearFields()
        ScreenshotController.takeScreenshot(inRect: screenshotRect) {
            DispatchQueue.main.async {
                Shell.convertImageToText { text in
                    guard let text = text else { return }
                    self.setFieldValues(from: text)
                    if !self.fieldIsEmpty()
                    {
                        self.perform(#selector(ViewController.takeScreenshot), with: nil, afterDelay: 20.0)
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
    }
    
    ///Determines if every field is empty
    private func allFieldsAreEmpty() -> Bool
    {
        return questionField.stringValue.isEmpty && questionField.stringValue.questionType.isEmpty && optionOneField.stringValue.isEmpty && optionTwoField.stringValue.isEmpty && optionThreeField.stringValue.isEmpty
    }
    
    ///Determines if at least one field is empty
    private func fieldIsEmpty() -> Bool
    {
        return questionField.stringValue.isEmpty || questionField.stringValue.questionType.isEmpty || optionOneField.stringValue.isEmpty || optionTwoField.stringValue.isEmpty || optionThreeField.stringValue.isEmpty
    }
    
    ///Clears all data from UI
    private func internalClearFields()
    {
        self.questionTypeLabel.stringValue = ""
        self.questionField.stringValue = ""
        self.optionOneField.stringValue = ""
        self.optionTwoField.stringValue = ""
        self.optionThreeField.stringValue = ""
        self.clearMatches()
    }
    
    ///Resets the match labels
    private func clearMatches()
    {
        hideAnswerBoxes(shouldAnimate: true)
        self.optionOneMatchesLabel.stringValue = "---"
        self.optionTwoMatchesLabel.stringValue = "---"
        self.optionThreeMatchesLabel.stringValue = "---"
    }
    
    private func updateQuestionType()
    {
        var string = "Question Type: "
        for type in questionField.stringValue.questionType
        {
            string += type.title + ", "
        }
        questionTypeLabel.stringValue = string.trimmingCharacters(in: CharacterSet(charactersIn: ", "))
    }
    
    ///Retrieves the correct answer
    private func getMatches()
    {
        if !fieldIsEmpty()
        {
            resignFirstResponder()
            updateQuestionType()
            let options = [optionOneField.stringValue, optionTwoField.stringValue, optionThreeField.stringValue]
            AnswerController.predictedAnswer(for: questionField.stringValue, answers: options, using: .google) { answer in
                if HQTriviaMaster.debug
                {
                    print("Predicted Correct Answer: \(answer.correctAnswer)")
                }
                
                //No answer was able to be determined
                if answer.probability == 0 && answer.correctAnswer == ""
                {
                    let alert = NSAlert()
                    alert.icon = nil
                    alert.messageText = "Answers Not Found in Results"
                    alert.informativeText = "HQ Trivia Master could not find any instance of any answer in the search results."
                    return
                }
                
                self.processProbabilities(for: answer)
                
                //Make sure there's a "strong" enough probability to warrant showing which one is correct.  Otherwise, let the user decide
                guard answer.probability > 0.4 else { return }
                NSAnimationContext.runAnimationGroup({ context in
                    context.duration = 0.2
                    context.allowsImplicitAnimation = true
                    
                    switch options.index(of: answer.correctAnswer) ?? -1
                    {
                    case 0:
                        self.optionOneCorrectOffScreenCenterConstraint?.animator().isActive = false
                        self.optionOneCorrectCenterConstraint.animator().isActive = true
                        self.view.animator().layout()
                        
                    case 1:
                        self.optionTwoCorrectOffScreenCenterConstraint?.animator().isActive = false
                        self.optionTwoCorrectCenterConstraint.animator().isActive = true
                        self.view.animator().layout()
                        
                    case 2:
                        self.optionThreeCorrectOffScreenCenterConstraint?.animator().isActive = false
                        self.optionThreeCorrectCenterConstraint.animator().isActive = true
                        self.view.animator().layout()
                        
                    default: break
                    }
                }, completionHandler: nil)
            }
        }
    }
    
    ///Updates the probabilites for each answer.  The probability is the liklihood the answer is correct based on how many instances were found in the search results
    private func processProbabilities(for answer: Answer)
    {
        let correctPercentage = answer.probability * 100.0
        let firstCorrectPercentage = (answer.others.first?.1 ?? 0.0) * 100.0
        let lastCorrectPercentage = (answer.others.last?.1 ?? 0.0) * 100.0
        let correctProbabilityString = correctPercentage.format(f: correctPercentage == floor(correctPercentage) ? ".0" : ".2")
        let firstOtherAnswerProbabilityString = firstCorrectPercentage.format(f: firstCorrectPercentage == floor(firstCorrectPercentage) ? ".0" : ".2")
        let lastOtherAnswerProbabilityString = lastCorrectPercentage.format(f: lastCorrectPercentage == floor(lastCorrectPercentage) ? ".0" : ".2")
        labels.first(where: { $0.0.stringValue == answer.correctAnswer })?.1?.stringValue = "Probability: \(correctProbabilityString.isEmpty ? "0" : correctProbabilityString)%"
        labels.first(where: { $0.0.stringValue == answer.others.first?.0 })?.1?.stringValue = "Probability: \(firstOtherAnswerProbabilityString.isEmpty ? "0" : firstOtherAnswerProbabilityString)%"
        labels.first(where: { $0.0.stringValue == answer.others.last?.0 })?.1?.stringValue = "Probability: \(lastOtherAnswerProbabilityString.isEmpty ? "0" : lastOtherAnswerProbabilityString)%"
    }
    
    ///Sets the values in UI
    private func setFieldValues(from text: String)
    {
        var splitText = text.split(separator: "\n").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
        guard let questionEnd = splitText.index(where: { string -> Bool in string.contains("?") }) else
        {
            if HQTriviaMaster.debug
            {
                print("Did not find question end")
            }
            return
        }
        let questionArr = splitText[0...questionEnd]
        
        var fixedText = splitText.filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: .illegalCharacters).isEmpty }
        
        let option3 = String(fixedText.removeLast()).fixedText
        let option2 = String(fixedText.removeLast()).fixedText
        let option1 = String(fixedText.removeLast()).fixedText
        let question = String(questionArr.joined(separator: " ")).fixedText
        
        if HQTriviaMaster.debug
        {
            print(question, option1, option2, option3, separator: "\n", terminator: "\n")
        }
        
        updateQuestionType()
        optionOneField.stringValue = option1
        optionTwoField.stringValue = option2
        optionThreeField.stringValue = option3
        questionField.stringValue = question
        if !question.questionType.contains(.correctSpelling)
        {
            self.fixSpelling()
        }
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

