//
//  TextClick.swift
//  GaltEx
//
//  Created by Laptop on 3/9/18.
//  Copyright © 2018 GaltBank. All rights reserved.
//

import Cocoa
import Foundation

/*
 Subclass TextField to allow MouseClick
 Use Interface Builder for the same result
 label.target = self
 label.action = #selector(onClick(_:))
*/

class TextClick : NSTextField {
    
    override func resetCursorRects() {
        self.addCursorRect(self.bounds, cursor: .pointingHand())
    }
    
    
    override func mouseDown(with event: NSEvent) {
        self.sendAction(self.action, to: self.delegate)
    }
}

// END
