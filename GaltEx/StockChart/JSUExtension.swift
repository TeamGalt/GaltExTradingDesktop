//
//  JSUExtension.swift
//  csfsamradar
//
//  Created by hengchengfei on 15/7/22.
//  Copyright (c) 2015年 vsto. All rights reserved.
//

import Cocoa
import Foundation

public extension NSView {

    public var width: CGFloat! {
        get {
            return self.frame.width
        }
        set(newValue){
            var frame = self.frame
            frame.size.width = newValue
            self.frame = frame
        }
    }
    
    public var height: CGFloat! {
        get {
            return self.frame.height
        }
        set(newValue){
            var frame = self.frame
            frame.size.height = newValue
            self.frame = frame
        }
    }
    
    public var x: CGFloat! {
        get {
            return self.frame.origin.x
        }
        set(newValue){
            var frame = self.frame
            frame.origin.x = newValue
            self.frame = frame
        }
    }
    
    public var y: CGFloat! {
        get {
            return self.frame.origin.y
        }
        set(newValue){
            var frame = self.frame
            frame.origin.y = newValue
            self.frame = frame
        }
    }
}


//---- UTILS

public extension NSColor {
    /*
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
 */
    convenience init(red: Int, green: Int, blue: Int, al: CGFloat) {
        assert(red   >= 0 && red   <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue  >= 0 && blue  <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: al)
    }
    
/*
    /**
     返回UIColor对象
     
     - parameter netHex: 16进制
     - parameter alpha:  透明度
     
     - returns: UIColor
     */
    convenience init(netHex:Int, alpha: CGFloat) {
        self.init(red:(netHex >> 16) & 0xff, green:(netHex >> 8) & 0xff, blue:netHex & 0xff, al: alpha)
    }
*/
}

extension Double{
    public func toDate() -> Date {
        let d:TimeInterval  = self/1000
        
        return Date(timeIntervalSince1970: d)
    }
}

extension String {
    
    //48-57num  65-90A 97-122a
    func allCharacter() -> Bool {
        if let asciiString = self.cString(using: String.Encoding.ascii){
            for v in 0 ..< asciiString.count - 1 {
                if (asciiString[v] >= 48 && asciiString[v] <= 57) || (asciiString[v] >= 65 && v <= 90) || (asciiString[v] >= 97 && asciiString[v] <= 122) {
                    return false
                }
            }
            return true
        }else{
            return true
        }
    }
    
    func allNumber() -> Bool {
        if let asciiString = self.cString(using: String.Encoding.ascii){
            for v in 0 ..< asciiString.count - 1 {
                if !(asciiString[v] >= 48 && asciiString[v] <= 57){
                    return false
                }
            }
            return true
        }else{
            return true
        }
    }
    
    func allLetter() -> Bool {
        if let asciiString = self.cString(using: String.Encoding.ascii){
            for v in 0 ..< asciiString.count - 1 {
                if !((asciiString[v] >= 65 && asciiString[v] <= 90) || (asciiString[v] >= 97 && asciiString[v] <= 122)) {
                    return false
                }
            }
            return true
        }else{
            return true
        }
    }
    
    func toInt()->Int{
        return (self as NSString).integerValue
    }
    
    func escapeSpaceTillCahractor()->String{
        return self.stringEscapeHeadTail(strs:["\r", " ", "\n"])
    }
    func escapeHeadStr(_ str:String)->(String, Bool){
        var result = self as NSString
        var findAtleastOne = false
        while( true ){
            let range = result.range(of: str)
            if range.location == 0 && range.length == 1 {
                result = result.substring(from: range.length) as NSString
                findAtleastOne = true
            }else{
                break
            }
        }
        return (result as String, findAtleastOne)
    }
    func escapeSpaceTillCahractor(strs:[String])->String{
        var result = self
        while( true ){
            var findAtleastOne = false
            for str in strs {
                var found:Bool = false
                (result, found) = result.escapeHeadStr(str)
                if found {
                    findAtleastOne = true
                    break  //for循环
                }
            }
            if findAtleastOne == false {
                break
            }
        }
        return result as String
    }
    func reverse()->String{
        var inReverse = ""
        for letter in self.characters {
            inReverse = "\(letter)" + inReverse
        }
        return inReverse
    }
    
    func escapeHeadTailSpace()->String{
        return self.escapeSpaceTillCahractor().reverse().escapeSpaceTillCahractor().reverse()
    }
    
    func stringEscapeHeadTail(strs:[String])->String{
        return self.escapeSpaceTillCahractor(strs:strs).reverse().escapeSpaceTillCahractor(strs:strs).reverse()
    }
    
    func toDate(_ format:String) -> Date? {
        let dateformatter = DateFormatter()
        dateformatter.timeZone=TimeZone.autoupdatingCurrent
        dateformatter.dateFormat = format
        
        return dateformatter.date(from: self)
    }
    
    func toDouble() -> Double {
        return (self as NSString).doubleValue
    }
    
    func toRatioAttributedString(_ isChangeColor:Bool = true,isPlusShow:Bool = false,isSubShow:Bool = false) -> NSMutableAttributedString {
        let d = self.toDouble()
        
        if d > 0 {
            var s = "\(self)%"
            if isPlusShow {
                s = "+\(self)%"
            }
            
            let attr = NSMutableAttributedString(string: "\(s)")
            if isChangeColor {
                //NSMakeRange(<#T##loc: Int##Int#>, <#T##len: Int##Int#>)
                
                attr.addAttribute(NSForegroundColorAttributeName, value: NSColor(hex: 0xff6262), range: NSMakeRange(0, s.characters.count))
            }
            
            return attr
        } else {
            var s = "\(self)%"
            if isSubShow {
                s = "-\(self)%"
            }
            let attr = NSMutableAttributedString(string: "\(s)")
            if isChangeColor {
                attr.addAttribute(NSForegroundColorAttributeName, value: NSColor(hex: 0x1dbf60), range: NSMakeRange(0, s.characters.count))
            }
            
            return attr
        }
    }
    
    func toRatioAttributedString(_ format:String,isChangeColor:Bool = true,isPlusShow:Bool = false,isSubShow:Bool = false) -> NSMutableAttributedString {
        
        
        let d = self.toDouble()
        
        if d > 0 {
            var s = "\(d.toStringWithFormat(format))%"
            if isPlusShow {
                s = "+\(d.toStringWithFormat(format))%"
            }
            
            let attr = NSMutableAttributedString(string: "\(s)")
            if isChangeColor {
                attr.addAttribute(NSForegroundColorAttributeName, value: NSColor(hex: 0xff6262), range: NSMakeRange(0, s.characters.count))
            }
            
            return attr
        } else {
            var s = "\(d.toStringWithFormat(format))%"
            if isSubShow {
                s = "-\(d.toStringWithFormat(format))%"
            }
            let attr = NSMutableAttributedString(string: "\(s)")
            if isChangeColor {
                attr.addAttribute(NSForegroundColorAttributeName, value: NSColor(hex: 0x1dbf60), range: NSMakeRange(0, s.characters.count))
            }
            
            return attr
        }
    }
    
    func stringByAppendingPathComponent(_ pathComponent: String) -> String {
        return (self as NSString).appendingPathComponent(pathComponent)
    }
    
}

extension Date {
    
    func addYear(_ year:Int) -> Date{
        return (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.year, value: year, to: Date(), options: NSCalendar.Options.init(rawValue: 0))!
    }
    
    func addMonth(_ mon:Int) -> Date{
        return (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.month, value: mon, to: self, options: NSCalendar.Options.init(rawValue: 0))!
    }
    
    func addDay(_ day:Int) -> Date{
        return (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.day, value: day, to: self, options: NSCalendar.Options.init(rawValue: 0))!
    }
    
    func addHour(_ hour:Int) -> Date{
        return (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.hour, value: hour, to: self, options: NSCalendar.Options.init(rawValue: 0))!
    }
    
    func addMin(_ min:Int) -> Date{
        return (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.minute, value: min, to: self, options: NSCalendar.Options.init(rawValue: 0))!
    }
    
    func addSecond(_ second:Int) -> Date{
        return (Calendar.current as NSCalendar).date(byAdding: NSCalendar.Unit.second, value: second, to: self, options: NSCalendar.Options.init(rawValue: 0))!
    }
    
    func toString(_ format:String) -> String {
        let dateformatter = DateFormatter()
        dateformatter.timeZone = TimeZone.autoupdatingCurrent
        dateformatter.dateFormat = format
        return dateformatter.string(from: self)
    }
    
    var second:Int{
        get{
            return (Calendar.current as NSCalendar).components([.day,.month,.year,.hour,.minute,.second], from: self).second!
        }
    }
    
    var min:Int{
        get{
            return (Calendar.current as NSCalendar).components([.day,.month,.year,.hour,.minute,.second], from: self).minute!
        }
    }
    
    var hour:Int{
        get{
            return (Calendar.current as NSCalendar).components([.day,.month,.year,.hour,.minute,.second], from: self).hour!
        }
    }
    
    var day:Int{
        get{
            return (Calendar.current as NSCalendar).components([.day,.month,.year,.hour,.minute,.second], from: self).day!
        }
    }
    
    var month:Int{
        get{
            return (Calendar.current as NSCalendar).components([.day,.month,.year,.hour,.minute,.second], from: self).month!
        }
    }
    
    var year:Int{
        get{
            return (Calendar.current as NSCalendar).components([.day,.month,.year,.hour,.minute,.second], from: self).year!
        }
    }
    
    // @Brief 判断时间是否为交易时间
    func isTradingTime() -> Bool {
        let calendar = Calendar.current
        let components = (calendar as NSCalendar).components([.hour,.minute], from: self)
        
        let hour = components.hour
        let minutes = components.minute
        let is1 = hour! >= 9 && hour! < 10 && minutes! >= 15
        let is2 = hour! >= 10 && hour! <= 11
        let is3 = hour! > 11  && hour! < 11 && minutes! <= 31
        let is4 = hour! >= 13 && hour! < 14
        let is5 = hour! >= 14 && hour! < 15
        let is6 = hour! >= 15 && minutes! <= 1
        
        
        if is1 || is2 || is3 || is4 || is5 || is6 {
            return true
        } else  {
            return false
        }
    }
    
    func isToday() ->Bool{
        let calender = Calendar.current
        let selfCmps = (calender as NSCalendar).components([.day,.month,.year], from: self)
        let nowCmps = (calender as NSCalendar).components([.day,.month,.year], from: Date())
        if selfCmps.year == nowCmps.year && selfCmps.month == nowCmps.month && selfCmps.day == nowCmps.day {
            return true
        }else{
            return false
        }
    }
    
    //是否交易日且开市
    //    func isRest() ->Bool{
    //        var companyDate = NSDate().isToday()
    //        var companyTime = NSDate().isTradingTime()
    //        if companyDate {
    //            if companyTime {
    //                return true
    //            }
    //        }
    //        return false
    //    }
    //是否新股
    func isNewStock(_ lsdt:Date) ->Bool{
        
        let nowTimeDifference = self.timeIntervalSince1970
        let lsdtTimeDifference = lsdt.timeIntervalSince1970
        
        let timeChange = nowTimeDifference - lsdtTimeDifference
        if timeChange/86400 <= 10{
            return true
        }else{
            return false
        }
    }
    
}

extension CGFloat{
    /// %.2f 不带科学计数
    func toStringWithFormat(_ format:String) -> String! {
        return NSString(format: format as NSString, self) as String
    }
    
    /// "###,##0.00"
    /// "0.00"
    /// 科学计数
    func toStringWithFormat1(_ format:String) -> String! {
        let nsnumberformatter = NumberFormatter()
        nsnumberformatter.positiveFormat = format
        nsnumberformatter.locale = Locale.current
        let BB = nsnumberformatter.string(from: NSNumber(value: Float(self)))! //NSNumber(self))!
        
        return BB
    }
}

extension Double {
    
    /// %.2f 不带科学计数
    func toStringWithFormat(_ format:String) -> String! {
        return NSString(format: format as NSString, self) as String
    }
    
    /// "###,##0.00"
    /// "0.00"
    /// 科学计数
    func toStringWithFormat1(_ format:String) -> String! {
        let nsnumberformatter = NumberFormatter()
        nsnumberformatter.positiveFormat = format
        nsnumberformatter.locale = Locale.current
        let BB = nsnumberformatter.string(from: NSNumber(value: self))!
        
        return BB
    }
    
    
    func toRatioAttributedString(_ isChangeColor:Bool = true,isPlusShow:Bool = true,isSubShow:Bool = true) -> NSMutableAttributedString {
        let d = self
        
        if d > 0 {
            var s = "\(d)%"
            if isPlusShow {
                s = "+\(d)%"
            }
            
            let attr = NSMutableAttributedString(string: "\(s)")
            if isChangeColor {
                attr.addAttribute(NSForegroundColorAttributeName, value: NSColor(hex: 0xff6262), range: NSMakeRange(0, s.characters.count))
            }
            
            return attr
        } else {
            var s = "\(d)%"
            if isSubShow {
                s = "-\(d)%"
            }
            let attr = NSMutableAttributedString(string: "\(s)")
            if isChangeColor {
                attr.addAttribute(NSForegroundColorAttributeName, value: NSColor(hex: 0x1dbf60), range: NSMakeRange(0,s.characters.count))
            }
            
            return attr
        }
    }
}

/*
extension UIImage{
    class func imageWithColor(_ color:UIColor) -> UIImage
    {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context?.setFillColor(color.cgColor)
        context?.fill(rect)
        
        let theImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return theImage!
    }
}
*/

//
//extension UILabel{
//    func getLabelHeight() -> CGFloat{
//        let constraint = CGSizeMake(self.frame.size.width, 99999)
//        let context = NSStringDrawingContext()
//        if let t = self.text{
//            let boundingBox = (t as NSString).boundingRectWithSize(constraint, options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:self.font], context: context).size
//            let size = CGSizeMake(ceil(boundingBox.width), ceil(boundingBox.height))
//            return size.height
//        }
//        return 0
//    }
//}

/*
extension UILabel {
    func heightWithWidth(_ width: CGFloat) -> CGFloat {
        guard let text = text else {
            return 0
        }
        return text.heightWithWidth(width, font: font)
    }
    
    func heightWithAttributedWidth(_ width: CGFloat) -> CGFloat {
        guard let attributedText = attributedText else {
            return 0
        }
        return attributedText.heightWithWidth(width)
    }
}
*/

extension String {
    func heightWithWidth(_ width: CGFloat, font: NSFont) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = self.boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], attributes: [NSFontAttributeName: font], context: nil)
        return actualSize.height
    }
}

extension NSAttributedString {
    func heightWithWidth(_ width: CGFloat) -> CGFloat {
        let maxSize = CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)
        let actualSize = boundingRect(with: maxSize, options: [.usesLineFragmentOrigin], context: nil)
        return actualSize.height
    }
}

/*
extension UIFont {
    func sizeOfString(_ string:String,constrainedToWidth width: CGFloat) -> CGSize {
        return NSString(string: string).boundingRect(with: CGSize(width: width, height: 9999), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSFontAttributeName:self], context: nil).size
    }
}
*/



// END
