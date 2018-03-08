//
//  JSUKLineModel.swift
//  JSUStockChartDemo
//
//  Created by 苏小超 on 16/7/4.
//  Copyright © 2016年 com.jason.su. All rights reserved.
//


import Foundation
//import ObjectMapper


/*
open class JSUKLineMessage: Mappable {
    open var message: [JSUKLineModel]?
    
    required public init?(map: Map) {}
    
    open func mapping(map: Map) {
        message <- map["message"]
    }
}
*/

struct ChartLineData {
    var lines: [ChartLineModel] = []
    
    init() {}
    
    init(_ json: ListMap){
        self.lines = []
        for item in json {
            let time   = item.int("timestamp")
            let open   = item.dbl("open")
            let close  = item.dbl("close")
            let low    = item.dbl("low")
            let high   = item.dbl("high")
            let volume = item.dbl("base_volume") // XLM, if asset use counter_volume
            
            let date = Date(timeIntervalSince1970: TimeInterval(time/1000))
            let dt = date.toString("yyyy-MM-dd")
            //print(time, dt, open, close, low, high, volume)

            let row: ChartLineModel = ChartLineModel(dt: dt, open: open, close: close, high: high, low: low, inc: nil, vol: volume, ma: nil)
            //print(row)
            self.lines.append(row)
        }
        self.calcMovingAverage()
    }
    
    mutating func calcMovingAverage() {
        func avg(_ array: [Double]) -> Double {
            var sum = 0.0
            for item in array { sum += item }
            return sum / Double(array.count)
        }
        
        var ma05: Double? = nil
        var ma10: Double? = nil
        var ma20: Double? = nil
        
        var n = 0
        
        var sum05:[Double] = []
        var sum10:[Double] = []
        var sum20:[Double] = []
        
        for item in lines {
            if n > 4  { ma05 = avg(sum05); sum05.removeFirst() }
            if n > 9  { ma10 = avg(sum10); sum10.removeFirst() }
            if n > 19 { ma20 = avg(sum20); sum20.removeFirst() }
            lines[n].ma = MAModel(MA5: ma05, MA10: ma10, MA20: ma20)
            //if n > 4  { lines[n].ma = MAModel(MA5: ma05, MA10: ma10, MA20: ma20) }
            //else { lines[n].ma = MAModel(MA5: item.close ?? 0.0, MA10: item.close ?? 0.0, MA20: item.close ?? 0.0) }
            sum05.append(item.close ?? 0.0)
            sum10.append(item.close ?? 0.0)
            sum20.append(item.close ?? 0.0)
            n += 1
        }
        //print(lines)
    }
}

struct ChartLineModel {
    var dt    : String?
    //var tick  : String?
    var open  : Double?
    var close : Double?
    var high  : Double?
    var low   : Double?
    var inc   : Double?
    var vol   : Double?
    var ma    : MAModel?
}

struct MAModel {
    var MA5  : Double?
    var MA10 : Double?
    var MA20 : Double?
}
