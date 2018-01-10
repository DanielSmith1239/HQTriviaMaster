//
//  InteractableWindow.swift
//  HQ Trivia Master
//
//  Created by Michael Schloss on 12/30/17.
//  Copyright © 2017 Daniel Smith. All rights reserved.
//

import Cocoa

protocol InteractableWindowDelegate : class
{
    func drew(rect: NSRect)
}

/**
 The window where the user chooses the part of the screen to be watched for questions popping up
 */
class InteractableWindow : NSPanel
{
    weak var interactableWindowDelegate: InteractableWindowDelegate?
    override var acceptsFirstResponder : Bool { return true }
    
    private lazy var view : NSBox = {
        let view = NSBox()
        view.title = ""
        view.titlePosition = .noTitle
        view.boxType = .custom
        view.borderType = .noBorder
        view.fillColor = NSColor.selectedControlColor.withAlphaComponent(0.5)
        contentView?.addSubview(view)
        return view
    }()
    
    private var origin = NSPoint.zero
    
    ///Sets up the UI for the interactable window
    func setup()
    {
        titleVisibility = .hidden
        titlebarAppearsTransparent = true
        isOpaque = false
        backgroundColor = NSColor.black.withAlphaComponent(0.5)
        isMovable = false
        styleMask.remove(.resizable)
        styleMask.insert(.borderless)
        standardWindowButton(.closeButton)?.isHidden = true
        standardWindowButton(.miniaturizeButton)?.isHidden = true
        standardWindowButton(.zoomButton)?.isHidden = true
        
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
        
        contentView = view
    }
    
    override func mouseDown(with event: NSEvent)
    {
        super.mouseDown(with: event)
        if HQTriviaMaster.debug
        {
            print("Mouse Pressed Down")
        }
        origin = NSEvent.mouseLocation
        view.frame = NSRect(x: origin.x, y: origin.y, width: 0.0, height: 0.0)
        view.alphaValue = 1.0
    }
    
    override func mouseDragged(with event: NSEvent)
    {
        super.mouseDragged(with: event)
        let location = NSEvent.mouseLocation
        var xShouldInvert = false
        var yShouldInvert = false
        if location.x < origin.x
        {
            xShouldInvert = true
        }
        if location.y < origin.y
        {
            yShouldInvert = true
        }
        
        view.frame = NSRect(x: xShouldInvert ? location.x : origin.x, y: yShouldInvert ? location.y : origin.y, width: xShouldInvert ? origin.x - location.x : location.x - origin.x, height: yShouldInvert ? origin.y - location.y : location.y - origin.y)
    }
    
    override func mouseUp(with event: NSEvent)
    {
        if HQTriviaMaster.debug
        {
            print("Mouse Released")
            print(view.convert(view.bounds, to: nil))
        }
        interactableWindowDelegate?.drew(rect: view.convert(view.bounds, to: nil))
        view.alphaValue = 0.0
        super.mouseUp(with: event)
    }
}
