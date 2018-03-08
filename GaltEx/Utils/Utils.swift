//
//  Utils.swift
//  GaltEx
//
//  Created by Laptop on 2/28/18.
//  Copyright © 2018 GaltBank. All rights reserved.
//

import Cocoa
import Foundation

extension NSColor {
    convenience init(hex: Int) {
        var opacity : CGFloat = 1.0
        
        if hex > 0xffffff {
            opacity = CGFloat((hex >> 24) & 0xff) / 255
        }
        
        let parts = (
            R: CGFloat((hex >> 16) & 0xff) / 255,
            G: CGFloat((hex >> 08) & 0xff) / 255,
            B: CGFloat((hex >> 00) & 0xff) / 255,
            A: opacity
        )
        
        self.init(red: parts.R, green: parts.G, blue: parts.B, alpha: parts.A)
    }
}

extension CGColor {
    static func hex(_ color: Int) -> CGColor {
        var opacity : CGFloat = 1.0
        
        if color > 0xffffff {
            opacity = CGFloat((color >> 24) & 0xff) / 255
        }
        
        let parts = (
            R: CGFloat((color >> 16) & 0xff) / 255,
            G: CGFloat((color >> 08) & 0xff) / 255,
            B: CGFloat((color >> 00) & 0xff) / 255,
            A: opacity
        )
        
        return CGColor(red: parts.R, green: parts.G, blue: parts.B, alpha: parts.A)
        
    }
}

extension NSFont {
    var mono: NSFont {
        let features = [
            [NSFontFeatureTypeIdentifierKey: kNumberSpacingType,
             NSFontFeatureSelectorIdentifierKey: kMonospacedNumbersSelector],
            [NSFontFeatureTypeIdentifierKey: kStylisticAlternativesType,
             NSFontFeatureSelectorIdentifierKey: kStylisticAltSixOnSelector]
        ]
        let descriptor = fontDescriptor.addingAttributes([NSFontFeatureSettingsAttribute: features])
        return NSFont(descriptor: descriptor, size: pointSize) ?? self
    }
}

typealias DataMap = [String: Any]
typealias ListMap = [DataMap]

class JSON {
    static func parse(_ text: String) -> DataMap {
        guard let data = text.data(using: .utf8) else { return DataMap() }
        return parse(data)
    }
    
    static func parseList(_ text: String) -> ListMap {
        guard let data = text.data(using: .utf8) else { return ListMap() }
        return parseList(data)
    }

    static func parse(_ data: Data) -> DataMap {
        var dixy = DataMap()
        
        do {
            dixy = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! DataMap
        } catch {
            print("JSON.error: ", error)
        }
        
        return dixy
    }

    static func parseList(_ data: Data) -> ListMap {
        var dixy = ListMap()
        
        do {
            dixy = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! ListMap
        } catch {
            print("JSON.error: ", error)
        }
        
        return dixy
    }

}


extension Date {
    var epoch: Int {            return Int(self.timeIntervalSince1970)*1000 }  // From instance
    static var epoch:     Int { return Int(Date().timeIntervalSince1970)*1000 }
    static var epoch04h : Int { return Date(timeIntervalSinceNow:   -14400).epoch } //-60*60*04
    static var epoch24h : Int { return Date(timeIntervalSinceNow:   -72000).epoch } //-60*60*24
    static var epoch07d : Int { return Date(timeIntervalSinceNow:  -604800).epoch } //-60*60*24*07
    static var epoch30d : Int { return Date(timeIntervalSinceNow: -2592000).epoch } //-60*60*24*30
    
    var string: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let text = formatter.string(from: self)
        return text
    }
    
    var time: String {
        let calendar = Calendar.current
        let hours    = calendar.component(.hour,   from: self)
        let minutes  = calendar.component(.minute, from: self)
        let seconds  = calendar.component(.second, from: self)

        let time = String(format: "%0.2d:%0.2d.%0.2d", hours, minutes, seconds)
        
        return time
    }
    
    static func fromString(_ text: String, format: String) -> Date {
        var date = Date(timeIntervalSince1970: 0)
        if !text.isEmpty {
            let formatter = DateFormatter()
            formatter.dateFormat = format
            date = formatter.date(from: text)!
        }
        return date
    }
}

extension String {
    
    func subtext(from ini: Int, to end: Int) -> String {
        guard ini >= 0 else { return "" }
        guard end >= 0 else { return "" }
        var fin = end
        if ini > self.characters.count { return  "" }
        if end > self.characters.count { fin = self.characters.count }
        let first = self.index(self.startIndex, offsetBy: ini)
        let last  = self.index(self.startIndex, offsetBy: fin)
        let range = first ..< last
        let text = self.substring(with: range)
        
        return text
    }
    
    var money: String {
        if let num = Double(self) {
            return num.money
        } else {
            return (0.0).money
        }
    }
    
    func toMoney(_ decs: Int, comma: Bool) -> String {
        if let num = Double(self) {
            return num.money
        } else {
            //let zero = 0.0
            return (0.0).money
        }
    }
    
    var dateISO: Date {
        var date = Date(timeIntervalSince1970: 0)
        if !self.isEmpty {
            //let formatter = ISO8601DateFormatter() // Available on macOS 10.12
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
            date = formatter.date(from: self) ?? date
        }
        return date
    }
    
    func ellipsis(_ n: Int) -> String {
        if self.isEmpty { return "" }
        return self.subtext(from: 0, to: n) + "..."
    }
}

extension Int {
    var str: String { return String(describing: self) }
    var on: Bool { return self > 0 }
}

extension Double {
    var int: Int { return Int(self) }
    
    var money: String {
        let value = NSNumber(value: self)
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.alwaysShowsDecimalSeparator = true
        formatter.minimumFractionDigits = 4
        formatter.maximumFractionDigits = 4
        let text = formatter.string(from: value) ?? "0.0000"
        //let text = NumberFormatter.localizedString(from: value, number: .decimal)
        //let text = String(format:"%.2f", self)
        return text
    }
    
    var moneyBlank: String {
        if self == 0.0 { return "" }
        return self.money
    }
    
    func toMoney(_ decs: Int? = 4, comma: Bool? = true) -> String {
        let decs = decs ?? 4
        let value = NSNumber(value: self)
        let formatter = NumberFormatter()
        formatter.numberStyle = NumberFormatter.Style.decimal
        formatter.alwaysShowsDecimalSeparator = (decs > 0)
        formatter.minimumFractionDigits = decs
        formatter.maximumFractionDigits = decs
        let text = formatter.string(from: value) ?? "0.0000"
        //let text = NumberFormatter.localizedString(from: value, number: .decimal)
        //let text = String(format:"%.2f", self)
        return text
    }

}

extension Bool {
    var int: UInt8 { return self ? 0x1 : 0x0 }
}

extension Dictionary where Key == String {
    func str(_ key: String, _ def: String? = "") -> String {
        let def = def ?? ""
        return self[key] as? String ?? def
    }
}

extension Dictionary where Key == String {
    func int(_ key: String, _ def: Int? = 0) -> Int {
        let def = def ?? 0
        if let val = self[key] as? Int { return val }
        return Int(self[key] as? String ?? "") ?? def
    }
}

extension Dictionary where Key == String {
    func dbl(_ key: String, _ def: Double? = 0.0) -> Double {
        let def = def ?? 0.0
        if let val = self[key] as? Double { return val }
        return Double(self[key] as? String ?? "") ?? def
    }
}

extension Dictionary where Key == String {
    func flt(_ key: String, _ def: Float? = 0.0) -> Float {
        let def = def ?? 0.0
        if let val = self[key] as? Float { return val }
        return Float(self[key] as? String ?? "") ?? def
    }
}

extension Dictionary where Key == String {
    func bln(_ key: String, _ def: Bool? = false) -> Bool {
        let def = def ?? false
        if let val = self[key] as? Bool   { return val }
        if let val = self[key] as? Int    { return val==1 }
        if let val = self[key] as? String { return val=="True" || val=="true" || val=="1" }
        return def
    }
}


// json.dix
// json.lst


// END
