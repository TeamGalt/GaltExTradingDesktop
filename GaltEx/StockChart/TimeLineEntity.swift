//
//  YKTimeLineEntity.swift
//  StockChart
//
//  Created by 苏小超 on 16/2/24.
//  Copyright © 2016年 com.jason. All rights reserved.
//

import Foundation

class TimeLineEntity{
    var currtTime   : String?
    var preClosePx  : CGFloat = 0
    var avgPrice    : CGFloat = 0
    var lastPrice   : CGFloat = 0
    var totalVolume : CGFloat = 0
    var volume      : CGFloat = 0
    var trade       : CGFloat = 0
    var rate        : CGFloat?
    
    init() {}
}
