//
//  TableChart.swift
//  GaltEx
//
//  Created by Laptop on 3/3/18.
//  Copyright © 2018 GaltBank. All rights reserved.
//


import Foundation

class TableChart {
    
    //var list: [Candlestick.Ticker] = []
    var list = ChartLineData()

    /*
    struct ChartRow {
        var time   = 0
        var high   = 0.0
        var low    = 0.0
        var open   = 0.0
        var close  = 0.0
        var volume = 0.0
    }
    */
    
    func load(symbol: String, isBase: Bool, period: Int, callback: @escaping Completion) {
        WebController.getChartData(symbol: symbol, isBase: isBase, period: period) { ticker, error in
            if error != nil { callback(false); return }
            self.list = ticker
            callback(true)
        }
    }
    
}
