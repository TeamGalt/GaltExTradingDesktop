//
//  KLineDataSet.swift
//  StockChart
//
//  Created by 苏小超 on 16/2/24.
//  Copyright © 2016年 com.jason. All rights reserved.
//

import Cocoa
import Foundation

class KLineDataSet{
    var data: [KLineEntity]?
    var highlightLineWidth : CGFloat = 1
    var highlightLineColor = NSColor(hex: 0x546679)
    var candleRiseColor    = NSColor(hex: 0x5d9943)  // 0x609648) // 0x6d9953) // 0x6e914f) // 0x1dbf60
    var candleFallColor    = NSColor(hex: 0xa53f4b)  // 0x953f4b) // 0xc55f6b) // 0xf24957
    var avgMA5Color        = NSColor(hex: 0xe8de85)
    var avgMA10Color       = NSColor(hex: 0x6fa8bb)
    var avgMA20Color       = NSColor(hex: 0xdf8fc6)
    var avgLineWidth: CGFloat = 1
    var candleTopBottomLineWidth: CGFloat = 1
    
    init() {}
}
