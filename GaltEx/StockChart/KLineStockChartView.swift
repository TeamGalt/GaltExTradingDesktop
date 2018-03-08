//
//  KLineStockChartView.swift
//  StockChart
//
//  Created by 苏小超 on 16/2/24.
//  Copyright © 2016年 com.jason. All rights reserved.
//

import Cocoa
import Foundation


// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l < r
    case (nil, _?):
        return true
    default:
        return false
    }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
    switch (lhs, rhs) {
    case let (l?, r?):
        return l > r
    default:
        return rhs < lhs
    }
}


open class KLineStockChartView: KLineStockChartViewBase {
    
    var dragEnable = true
    var dataSet : KLineDataSet?
    var countOfshowCandle : Int{
        get{
            return Int((self.width - offsetLeft - offsetRight)/(self.candleWidth))
        }
    }
    var _startDrawIndex:Int = 0
    var startDrawIndex : Int{
        get{
            return _startDrawIndex
        }
        set(value){
            var temp = 0
            if (value < 0) {
                temp = 0
            }else{
                temp = value
            }
            if (temp + self.countOfshowCandle > self.dataSet!.data!.count) {
                _startDrawIndex = 0;
            }
            _startDrawIndex = temp;
        }
    }
    var monthLineLimit = 0
    var candleWidth : CGFloat = 5
    var candleMaxWidth : CGFloat?
    var candleMinWidth : CGFloat?
    var avgLabelAttributedDic : [String:AnyObject] = [NSFontAttributeName: NSFont.systemFont(ofSize: 8), NSBackgroundColorAttributeName: NSColor.clear, NSForegroundColorAttributeName: NSColor(hex: 0x8695a6)]
    /*
    var panGesture : UIPanGestureRecognizer{
        get{
            return UIPanGestureRecognizer(target: self, action: #selector(handlePanGestureAction(_:)))
        }
    }
    var pinGesture : UIPinchGestureRecognizer{
        get{
            return UIPinchGestureRecognizer(target: self, action: #selector(handlePinGestureAction(_:)))
        }
    }
    var longPressGesture : UILongPressGestureRecognizer{
        get{
            return UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureAction(_:)))
        }
    }
    var tapGesture : UITapGestureRecognizer{
        get{
            return UITapGestureRecognizer(target: self, action: #selector(handleTapGestureAction(_:)))
        }
    }
     */
    
    var lastPinScale : CGFloat = 0
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }


    func commonInit(){
        self.candleCoordsScale = 0
        if scrollEnabled {
            //self.addGestureRecognizer(self.panGesture)
        }
        
        if zoomEnabled {
            //self.addGestureRecognizer(self.pinGesture)
        }
        //self.addGestureRecognizer(self.longPressGesture)
    }
    
    func setupData(_ dataSet:KLineDataSet){
        if let d = dataSet.data, self.countOfshowCandle > 0 {
            self.hiddenStatusView()
            
            dataSet.data = [KLineEntity](d)

            self.dataSet = dataSet
            
            if d.count > self.countOfshowCandle{
                self.startDrawIndex = d.count - self.countOfshowCandle
            }
           
            self.notifyDataSetChanged()
        }
        else{
            self.showFailStatusView()
        }
       
    }
    
    func addDataSetWithArray(_ array:[KLineEntity]){
        for (index,item) in array.enumerated(){
            self.dataSet?.data?.insert(item, at: index)
        }
        self.startDrawIndex = self.startDrawIndex + array.count
        self.setNeedsDisplay(self.frame)
    }
    
    func setCurrentDataMaxAndMin(){
        self.maxPrice  = CGFloat.leastNormalMagnitude
        self.minPrice  = CGFloat.greatestFiniteMagnitude
        self.maxVolume = CGFloat.leastNormalMagnitude
        
        if let data = self.dataSet?.data, data.count > 0{
            let idx = self.startDrawIndex
            if let count = self.dataSet?.data?.count {
            for i in idx ..< count {
                let entity = data[i]
                self.minPrice = self.minPrice < entity.low ? self.minPrice : entity.low
                self.maxPrice = self.maxPrice > entity.high ? self.maxPrice : entity.high
                self.maxVolume = self.maxVolume > entity.volume ? self.maxVolume : entity.volume
            }
            }
        }
        
    }
    
    override open func draw(_ rect: CGRect) {
        
        super.draw(rect)
        
        if let d  = self.dataSet?.data, d.count > 0{
            self.setCurrentDataMaxAndMin()
            let optionalContext = NSGraphicsContext.current()
            if let context = optionalContext?.cgContext {
                self.drawGridBackground(context, rect: rect)
                self.drawLabelPrice(context)
                self.drawCandle(context)
            }

        }
        
    }
    
    func drawAvgMarker(_ context:CGContext,idex:Int){
        var entity : KLineEntity?
        if idex == 0{
            entity = self.dataSet?.data?.last
        }else{
            entity = self.dataSet?.data?[idex]
        }
        
        if let e = entity, self.highlightLineCurrentEnabled{
            let drawAttributes = self.avgLabelAttributedDic
            
            let radius:CGFloat = 4.0
            let space:CGFloat = 4.0
            var startP = CGPoint(x: self.contentLeft, y: self.contentTop)
            
            context.setFillColor((self.dataSet?.avgMA5Color.cgColor)!)
            context.fillEllipse(in: CGRect(x: startP.x+(radius/2.0), y: startP.y+(radius), width: radius, height: radius))
            startP.x += (radius+space)
            let ma5Str = NSString(format: "MA5:%.2f", e.ma5) as String
            let ma5StrAtt = NSMutableAttributedString(string: ma5Str , attributes: drawAttributes)
            let ma5StrAttSize = ma5StrAtt.size()
            self.drawLabel(context, attributesText: ma5StrAtt, rect: CGRect(x: startP.x, y: startP.y+radius/3.0, width: ma5StrAttSize.width, height: ma5StrAttSize.height))
            
            startP.x += ma5StrAttSize.width + space
            context.setFillColor((self.dataSet?.avgMA10Color.cgColor)!)
            context.fillEllipse(in: CGRect(x: startP.x+(radius/2.0), y: startP.y+(radius), width: radius, height: radius))
            startP.x += (radius+space)
            let ma10Str = NSString(format: "MA10:%.2f", e.ma10) as String
            let ma10StrAtt = NSMutableAttributedString(string: ma10Str , attributes: drawAttributes)
            let ma10StrAttSize = ma10StrAtt.size()
            self.drawLabel(context, attributesText: ma10StrAtt, rect: CGRect(x: startP.x, y: startP.y+radius/3.0, width: ma10StrAttSize.width, height: ma10StrAttSize.height))
            
            
            startP.x += ma10StrAttSize.width + space
            context.setFillColor((self.dataSet?.avgMA20Color.cgColor)!)
            context.fillEllipse(in: CGRect(x: startP.x+(radius/2.0), y: startP.y+(radius), width: radius, height: radius))
            startP.x += (radius+space)
            let ma20Str = NSString(format: "MA20:%.2f", e.ma20) as String
            let ma20StrAtt = NSMutableAttributedString(string: ma20Str , attributes: drawAttributes)
            let ma20StrAttSize = ma10StrAtt.size()
            self.drawLabel(context, attributesText: ma20StrAtt, rect: CGRect(x: startP.x, y: startP.y+radius/3.0, width: ma20StrAttSize.width, height: ma20StrAttSize.height))
            
        }
        
    }
    
    func drawCandle(_ context:CGContext){
        context.saveGState()
        let idex = self.startDrawIndex
        self.candleCoordsScale = (self.upperChartHeightScale * self.contentHeight - 20) / (self.maxPrice-self.minPrice)
        self.volumeCoordsScale = (self.contentInnerHeight - (self.upperChartHeightScale * self.contentInnerHeight) - self.xAxisHeight) / (self.maxVolume - 0)
        var oldDate :Date?
        
        if let data = self.dataSet?.data, data.count > 0 {
            for i in idex ..< data.count {
                let entity = data[i]
                let open   = ((self.maxPrice - entity.open)  * self.candleCoordsScale) + self.contentInnerTop
                let close  = ((self.maxPrice - entity.close) * self.candleCoordsScale) + self.contentInnerTop
                let high   = ((self.maxPrice - entity.high)  * self.candleCoordsScale) + self.contentInnerTop
                let low    = ((self.maxPrice - entity.low)   * self.candleCoordsScale) + self.contentInnerTop
                let left   = (self.candleWidth * CGFloat(i - idex) + self.contentLeft) + self.candleWidth / 6.0
                
                let candleWidth = self.candleWidth - self.candleWidth / 6.0
                let startX = left + candleWidth/2.0
                
                //画竖线
                
                if let date = entity.date.toDate("yyyy-MM-dd") {
                    if oldDate == nil {
                        oldDate = date
                    }
                    if date.year > oldDate?.year || date.month > oldDate!.month + monthLineLimit {
                        self.drawline(context, startPoint: CGPoint(x: startX, y: self.contentTop), stopPoint: CGPoint(x: startX,  y: (self.upperChartHeightScale * self.contentHeight) + self.contentTop), color: self.borderColor, lineWidth: 0.5)
                        self.drawline(context, startPoint: CGPoint(x: startX, y: (self.upperChartHeightScale * self.contentHeight) + self.xAxisHeight), stopPoint: CGPoint(x: startX,y: self.contentBottom), color: self.borderColor, lineWidth: 0.5)
                        
                        if !self.highlightLineCurrentEnabled {
                            let drawAttributes = self.xAxisAttributedDic
                            let dateStrAtt = NSMutableAttributedString(string: date.toString("yyyy-MM"), attributes: drawAttributes)
                            let dateStrAttSize = dateStrAtt.size()
                            self.drawLabel(context, attributesText: dateStrAtt, rect: CGRect(x: startX - dateStrAttSize.width/2,y: ((self.upperChartHeightScale * self.contentHeight) + self.contentTop), width: dateStrAttSize.width, height: dateStrAttSize.height))
                        }
                        
                        oldDate = date
                    }
                }
                
                var color = self.dataSet?.candleRiseColor
                
                if open < close {
                    color = self.dataSet?.candleFallColor
                    self.drawRect(context, rect: CGRect(x: left, y: open, width: candleWidth, height: close-open), color: color!)
                    self.drawline(context, startPoint: CGPoint(x: startX, y: high), stopPoint: CGPoint(x: startX, y: low), color: color!, lineWidth: self.dataSet!.candleTopBottomLineWidth)
                } else if open == close {
                    if i > 1{
                        let lastEntity = data[i-1]
                        if lastEntity.close > entity.close {
                            color = self.dataSet?.candleFallColor
                        }
                    }
                    
                    self.drawRect(context, rect: CGRect(x: left, y: open, width: candleWidth, height: 1.5), color: color!)
                    self.drawline(context, startPoint: CGPoint(x: startX, y: high), stopPoint: CGPoint(x: startX, y: low), color: color!, lineWidth: self.dataSet!.candleTopBottomLineWidth)
                } else {
                    color = self.dataSet?.candleRiseColor
                    self.drawRect(context, rect: CGRect(x: left, y: close, width: candleWidth, height: open-close), color: color!)
                    self.drawline(context, startPoint: CGPoint(x: startX, y: high), stopPoint: CGPoint(x: startX, y: low), color: color!, lineWidth: self.dataSet!.candleTopBottomLineWidth)
                }
                
                if i > 0 {
                    let lastEntity = data[i-1]
                    let lastX = startX - self.candleWidth
                    
                    // Hack to avoid ma lines coming from baseline
                    if entity.ma5 <= 0 { entity.ma5 = entity.close }
                    if lastEntity.ma5 <= 0 { lastEntity.ma5 = lastEntity.close }
                    if entity.ma10 <= 0 { entity.ma10 = entity.close }
                    if lastEntity.ma10 <= 0 { lastEntity.ma10 = lastEntity.close }
                    if entity.ma20 <= 0 { entity.ma20 = entity.close }
                    if lastEntity.ma20 <= 0 { lastEntity.ma20 = lastEntity.close }
                    
                    
                    let lastY5 = (self.maxPrice - lastEntity.ma5) * self.candleCoordsScale + self.contentTop;
                    let  y5 = (self.maxPrice - entity.ma5) * self.candleCoordsScale  + self.contentTop;
                    self.drawline(context, startPoint: CGPoint(x: lastX, y: lastY5), stopPoint: CGPoint(x: startX, y: y5), color: self.dataSet!.avgMA5Color, lineWidth: self.dataSet!.avgLineWidth)

                    let lastY10 = (self.maxPrice - lastEntity.ma10) * self.candleCoordsScale  + self.contentTop;
                    let  y10 = (self.maxPrice - entity.ma10) * self.candleCoordsScale  + self.contentTop;
                    self.drawline(context, startPoint: CGPoint(x: lastX, y: lastY10) , stopPoint: CGPoint(x: startX, y: y10), color: self.dataSet!.avgMA10Color, lineWidth: self.dataSet!.avgLineWidth)
                    
                    let lastY20 = (self.maxPrice - lastEntity.ma20) * self.candleCoordsScale  + self.contentTop;
                    let  y20 = (self.maxPrice - entity.ma20) * self.candleCoordsScale  + self.contentTop;
                    self.drawline(context, startPoint: CGPoint(x: lastX, y: lastY20), stopPoint: CGPoint(x: startX, y: y20), color: self.dataSet!.avgMA20Color, lineWidth: self.dataSet!.avgLineWidth)
                    
                    //成交量
                    let volume = ((entity.volume - 0) * self.volumeCoordsScale)
                    self.drawRect(context,rect:CGRect(x: left, y: self.contentBottom - volume , width: candleWidth, height: volume) ,color:color!)
                }
            }
            
            for i in idex  ..< data.count  {
                let entity = data[i]
                let close = ((self.maxPrice - entity.close) * self.candleCoordsScale) + self.contentTop
                let left = (self.candleWidth * CGFloat(i - idex) + self.contentLeft) + self.candleWidth / 6.0
                
                let candleWidth = self.candleWidth - self.candleWidth / 6.0
                let startX = left + candleWidth/2.0
                
                if self.highlightLineCurrentEnabled {
                    if i == self.highlightLineCurrentIndex {
                        var entity:KLineEntity?
                        if i < data.count {
                            entity = data[i]
                        }
                        
                        self.drawHighlighted(context, point: CGPoint(x: startX, y: close), idex: idex, value:entity!, color: self.dataSet!.highlightLineColor, lineWidth: self.dataSet!.highlightLineWidth)
                        self.drawAvgMarker(context, idex: i)
                        if delegate != nil {
                            self.delegate!.chartValueSelected?(self, entry: entity!, entryIndex: i)
                        }
                        
                    }
                }
                
            }
            
            if !self.highlightLineCurrentEnabled {
                self.drawAvgMarker(context, idex: 0)
            }
            
            context.restoreGState()
        }
    }
    /*
    func handlePanGestureAction(_ recognizer:UIPanGestureRecognizer){
        if !self.scrollEnabled{
            return
        }
        
        self.highlightLineCurrentEnabled = false
        
        var isPanRight = false
        let point = recognizer.translation(in: self)
        
        if (recognizer.state == UIGestureRecognizerState.began) {
        }
        if (recognizer.state == UIGestureRecognizerState.changed) {
        }
        
        let offset = point.x
        
        if point.x > 0{
            let temp = offset/self.candleWidth
            var moveCount = 0
            if temp <= 1{
                moveCount = 1
            }else{
                moveCount = Int(temp)
            }

            self.startDrawIndex = self.startDrawIndex - moveCount
            
            if self.startDrawIndex < 10{
                if self.delegate != nil{
                    self.delegate?.chartKlineScrollLeft!(self)
                }
            }
            
            
        }else{
            let count = Int(CGFloat(self.startDrawIndex + self.countOfshowCandle) - (+offset)/self.candleWidth)
            if count > self.dataSet?.data?.count{
                isPanRight = true
            }
            
            let temp = (-offset)/self.candleWidth
            var moveCount = 0
            if temp <= 1{
                moveCount = 1
            }else{
                moveCount = Int(temp)
            }
            
            
            
            self.startDrawIndex = self.startDrawIndex + moveCount
        }
        
        if recognizer.state == UIGestureRecognizerState.ended{
            if isPanRight{
                self.startDrawIndex = self.dataSet!.data!.count - self.countOfshowCandle
                self.notifyDataSetChanged()
            }
        }
        
        self.setNeedsDisplay()
        recognizer.setTranslation(CGPoint(x: 0, y: 0), in: self)
    }
    
    func handlePinGestureAction(_ recognizer:UIPinchGestureRecognizer){
        if !self.zoomEnabled{
            return
        }
        
        self.highlightLineCurrentEnabled = false
        
        recognizer.scale = recognizer.scale - self.lastPinScale + 1
        
        self.candleWidth = recognizer.scale * self.candleWidth
        
        if self.candleWidth > self.candleMaxWidth{
            self.candleWidth = self.candleMaxWidth!
        }
        
        if self.candleWidth < self.candleMinWidth{
            self.candleWidth = self.candleMinWidth!
        }
        
        self.startDrawIndex = self.dataSet!.data!.count - self.countOfshowCandle
        self.setNeedsDisplay()
        self.lastPinScale = recognizer.scale
        
    }

    
    func handleLongPressGestureAction(_ recognizer:UIPanGestureRecognizer){
        if !self.highlightLineShowEnabled{
            return
        }
        
        
        let point = recognizer.location(in: self)
        
        if recognizer.state == UIGestureRecognizerState.began{
            
            if point.x > self.contentLeft && point.x < self.contentRight && point.y > self.contentTop && point.y < self.contentBottom{
                self.highlightLineCurrentEnabled = true
                self.getHighlightByTouchPoint(point)
            }
            if self.highlightLineCurrentIndex < self.dataSet?.data?.count{
            NotificationCenter.default.post(name: Notification.Name(rawValue: JSUNotificationKLineLongPress), object: self.dataSet?.data?[self.highlightLineCurrentIndex])
                NotificationCenter.default.post(name: Notification.Name(rawValue: JSUNotificationLandKLineLongPress), object: self.dataSet?.data?[self.highlightLineCurrentIndex])
            }
        }
        
        if recognizer.state == UIGestureRecognizerState.ended{
            self.highlightLineCurrentEnabled = false;
            self.setNeedsDisplay()
            if self.highlightLineCurrentIndex < self.dataSet?.data?.count{
            NotificationCenter.default.post(name: Notification.Name(rawValue: JSUNotificationKLineLongUnPress), object: self.dataSet?.data?[self.highlightLineCurrentIndex])
            NotificationCenter.default.post(name: Notification.Name(rawValue: JSUNotificationLandKLineLongUnPress), object: self.dataSet?.data?[self.highlightLineCurrentIndex])
            }
        }
        
        if recognizer.state == UIGestureRecognizerState.changed{
            if (point.x > self.contentLeft && point.x < self.contentRight && point.y > self.contentTop && point.y<self.contentBottom) {
                self.highlightLineCurrentEnabled = true;
                self.getHighlightByTouchPoint(point)
            }
            if self.highlightLineCurrentIndex < self.dataSet?.data?.count{
                NotificationCenter.default.post(name: Notification.Name(rawValue: JSUNotificationKLineLongPress), object: self.dataSet?.data?[self.highlightLineCurrentIndex])
                NotificationCenter.default.post(name: Notification.Name(rawValue: JSUNotificationLandKLineLongPress), object: self.dataSet?.data?[self.highlightLineCurrentIndex])
            }
        }
    }
    */
    
    
    override func getHighlightByTouchPoint(_ point:CGPoint){
        self.highlightLineCurrentIndex = self.startDrawIndex + Int((point.x - self.contentLeft)/self.candleWidth)
        self.setNeedsDisplay(self.frame)
    }
    

    override func notifyDataSetChanged() {
        super.notifyDataSetChanged()
        self.setNeedsDisplay(self.frame)
        
    }
    
    override func notifyDeviceOrientationChanged() {
        super.notifyDeviceOrientationChanged()
        //self.startDrawIndex = self.dataSet!.data!.count - self.countOfshowCandle
    }
    
}
