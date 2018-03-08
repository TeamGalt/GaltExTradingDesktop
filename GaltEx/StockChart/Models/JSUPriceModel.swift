//
//  JSUPriceModel.swift
//  JSUStockChartDemo
//
//  Created by 苏小超 on 16/7/4.
//  Copyright © 2016年 com.jason.su. All rights reserved.
//

import Foundation
/*
import ObjectMapper

open class JSUPriceModel :Mappable{
    open var days:[String]?
    open var state:Bool?
    open var close:Double?
    open var max:Double?
    open var min:Double?
    open var shares:[JSUShareModel]?
    
    public init(){
        
    }
    
    required public init?(map: Map) {
        
    }
    
    open func mapping(map: Map) {
        days <- map["days"]
        state <- map["state"]
        close <- map["close"]
        max <- map["max"]
        min <- map["min"]
        shares <- map["shares"]
    }
    
}

open class JSUShareModel:Mappable{
    open var dt:Date?
    open var price:Double?
    open var volume:Double?
    open var amount:Double?
    open var ratio:Double?
    
    public init(){
        
    }
    required public init?(map: Map) {
        
    }
    
    open func mapping(map: Map) {
        dt <- (map["dt"],CSFTransform())
        price <- map["price"]
        volume <- map["volume"]
        amount <- map["amount"]
        ratio <- map["ratio"]
    }
    
}


open class CSFTransform: TransformType {
    public typealias Object = Date
    public typealias JSON = Double
    
    public init() {}
    
    open func transformFromJSON(_ value: Any?) -> Date? {
        if let timeInt = value as? Double {
            return Date(timeIntervalSince1970: TimeInterval(timeInt))
        }else if let timeString = value as? String {
            let dateformatter = DateFormatter()
            dateformatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = dateformatter.date(from: timeString)
            return date
        }
        return nil
    }
    
    open func transformToJSON(_ value: Date?) -> Double? {
        if let date = value {
            return Double(date.timeIntervalSince1970)
        }
        return nil
    }
    
    open func transformToJSON(_ value: AnyObject?) -> Double? {
        if let _ = value as? String {
            
        }
        
        return nil
    }
}
*/
