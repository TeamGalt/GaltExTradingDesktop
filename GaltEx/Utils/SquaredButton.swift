//
//  SquaredButton.swift
//  GaltEx
//
//  Created by Laptop on 3/2/18.
//  Copyright © 2018 GaltBank. All rights reserved.
//

import Cocoa

class SquaredButton: NSButton {

    var text = "Click"
    var bgColor: NSColor = NSColor.black
    var fgColor: NSColor = NSColor.white
    let style = NSMutableParagraphStyle()

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
        // Drawing code here.
        self.layer?.cornerRadius = 2
        self.layer?.masksToBounds = true
        self.layer?.backgroundColor = bgColor.cgColor
        bgColor.setFill()
        NSRectFill(dirtyRect)
        style.alignment = .center
        self.attributedTitle = NSAttributedString(string: self.text, attributes: [NSForegroundColorAttributeName: self.fgColor, NSParagraphStyleAttributeName: style])
    }
}
