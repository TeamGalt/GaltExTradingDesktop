//
//  KTimeDataset.swift
//  StockChart
//
//  Created by 苏小超 on 16/2/24.
//  Copyright © 2016年 com.jason. All rights reserved.
//

import Cocoa
import Foundation

class TimeDataset {
    var days: [String]?
    var data: [TimeLineEntity]?
    var highlightLineWidth: CGFloat = 0
    var highlightLineColor = NSColor.blue
    var lineWidth: CGFloat = 1
    var priceLineCorlor    = NSColor.gray
    var avgLineCorlor      = NSColor.yellow
    var volumeRiseColor    = NSColor.red
    var volumeFallColor    = NSColor.green
    var volumeTieColor     = NSColor.gray
    var drawFilledEnabled  = false
    var fillStartColor     = NSColor.orange
    var fillStopColor      = NSColor.black
    var fillAlpha: CGFloat = 0.5
}
