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

class InteractableWindow : NSWindow
{
    weak var interactableWindowDelegate: InteractableWindowDelegate?
    
    private lazy var view : NSBox = {
        let view = NSBox()
        view.titlePosition = .noTitle
        view.boxType = .custom
        view.borderType = .noBorder
        view.fillColor = NSColor.selectedControlColor.withAlphaComponent(0.5)
        contentView?.addSubview(view)
        return view
    }()
    
    private var origin = NSPoint.zero
    
    override func mouseDown(with event: NSEvent)
    {
        super.mouseDown(with: event)
        if HQTriviaMaster.debug
        {
            print("Mouse Pressed Down")
        }
        origin = NSEvent.mouseLocation
        view.frame = NSRect(x: origin.x, y: origin.y, width: 0.0, height: 0.0)
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
        view.frame = .zero
        super.mouseUp(with: event)
    }
}
