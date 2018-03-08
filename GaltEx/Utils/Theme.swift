//
//  Theme.swift
//  GaltEx
//
//  Created by Laptop on 2/28/18.
//  Copyright © 2018 GaltBank. All rights reserved.
//

import Cocoa
import Foundation


// 17262d Dark
// 263942 Light
// a8b3ce Secondary text


// 1e1e1e
// 212121

struct Theme {
    static let dark  = NSAppearance(named: NSAppearanceNameVibrantDark)
    static let light = NSAppearance(named: NSAppearanceNameVibrantLight)
    
    struct color {
        static let goUp = NSColor(hex: 0x6e914f) //0x00CC00)
        static let goDn = NSColor(hex: 0xa55f6b) //0xCC0000)
        static let goNo = NSColor(hex: 0xaaaaaa)
        
        //static let backLight = NSColor(hex: 0x2a3038)
        //static let backDark  = NSColor(hex: 0x1a2028)
        static let backLight = NSColor(hex: 0x282828)
        static let backDark  = NSColor(hex: 0x1a1a1a)
    }
    
    struct font {
        static let monodigits = NSFont.monospacedDigitSystemFont(ofSize: 12.0, weight: NSFontWeightRegular)
        //static let monodigits = NSFont.mono
    }
}

extension NSView {
    static let themeDark = NSAppearance(named: NSAppearanceNameVibrantDark)
    /*
    var backgroundColor: CGColor? {
        get {
            return self.layer?.backgroundColor
        }
        
        set(newValue) {
            self.layer?.backgroundColor = newValue
        }
    }
    */
}
