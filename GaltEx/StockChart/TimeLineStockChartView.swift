//
//  TimeLineStockChartView.swift
//  StockChart
//
//  Created by 苏小超 on 16/2/25.
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


open class TimeLineStockChartView:KLineStockChartViewBase{

    ///是否画均线
    var drawAvgLine = true
    var countOfTimes = 0
    var endPointShowEnabled = false
    var offsetMaxPrice : CGFloat = 0
    var showFiveDayLabel = false
    var volumeWidth : CGFloat {
        return self.contentWidth/CGFloat(self.countOfTimes)
    }
    var dataSet : TimeDataset?
    //var longPressGesture : UILongPressGestureRecognizer{
    //    return UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGestureAction(_:)))
    //}
    //var tapGesture : UITapGestureRecognizer{
    //    return UITapGestureRecognizer(target: self, action: #selector(handleTapGestureAction(_:)))
    //}
    var _breathingPoint : CALayer?
    var breathingPoint : CALayer{
        if let b = _breathingPoint{
            return b
        }
        
        _breathingPoint = CALayer()
        self.layer?.addSublayer(_breathingPoint!)
        _breathingPoint!.backgroundColor = self.dataSet!.priceLineCorlor.cgColor
        _breathingPoint!.cornerRadius = 2;
        
        let opacityLayer = CALayer()
        opacityLayer.frame = CGRect(x: 0, y: 0, width: 4, height: 4)
        opacityLayer.backgroundColor = self.dataSet!.priceLineCorlor.cgColor
        opacityLayer.cornerRadius = 2;
        opacityLayer.add(self.breathingLight(2), forKey: "breathingPoint")
        _breathingPoint?.addSublayer(opacityLayer)
        
        return _breathingPoint!
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.commonInit()
    }
    

    
    func commonInit(){
        self.candleCoordsScale = 0
        //self.addGestureRecognizer(longPressGesture)
        //self.act.startAnimating()
        
    }
    
    override open func draw(_ rect: CGRect) {
        super.draw(rect)
        
        if let d = self.dataSet?.data, d.count > 0{
            self.setCurrentDataMaxAndMin()
            let context = NSGraphicsContext.current() as! CGContext
            self.drawGridBackground(context, rect:rect)
            self.drawLabelPrice(context)
            self.drawLabelRatio(context)
            self.drawTimeLabel(context)
            self.drawTimeLine(context)
        }
    }
    
    func setupData(_ dataSet:TimeDataset){
        if let d = dataSet.data, d.count > 0{
            self.hiddenStatusView()
            self.dataSet = dataSet
            self.notifyDataSetChanged()
        }else{
            self.showFailStatusView()
        }
    }
    
    func drawLabelRatio(_ context:CGContext){
        
        let maxRatioStr = self.handleStrWithPrice(self.maxRatio) + "%"
        let maxRatioAttStr = NSMutableAttributedString(string: maxRatioStr, attributes: self.leftYAxisAttributedDic)
        let sizeMaxRatioAttStr = maxRatioAttStr.size()
        var labelX = CGFloat(0)
        if drawLabelRatioInside{
            labelX = self.contentRight - sizeMaxRatioAttStr.width
        }else{
            labelX = self.contentRight
        }
        
        self.drawLabel(context, attributesText: maxRatioAttStr, rect: CGRect(x: labelX, y: self.contentTop, width: sizeMaxRatioAttStr.width, height: sizeMaxRatioAttStr.height))
        
        
        
        let minRatioStr = self.handleStrWithPrice(self.minRatio) + "%"
        let minRatioAttStr = NSMutableAttributedString(string: minRatioStr, attributes: self.leftYAxisAttributedDic)
        let sizeMinRatioAttStr = minRatioAttStr.size()
        if drawLabelRatioInside{
            labelX = self.contentRight - sizeMinRatioAttStr.width
        }else{
            labelX = self.contentRight
        }
        
        self.drawLabel(context, attributesText: minRatioAttStr, rect: CGRect(x: labelX, y: ((self.upperChartHeightScale * self.contentHeight) + self.contentTop - sizeMinRatioAttStr.height ), width: sizeMinRatioAttStr.width, height: sizeMinRatioAttStr.height))
    }
    
    func setCurrentDataMaxAndMin(){
        if let data = self.dataSet?.data, data.count > 0{
            self.maxPrice = -9999
            self.minPrice = 9999
            self.maxRatio = -9999
            self.minRatio = 9999
            self.maxVolume = 0
            self.offsetMaxPrice = -9999
            
            for i in 0 ..< data.count {
                let entity = data[i]
                self.offsetMaxPrice = self.offsetMaxPrice > fabs(entity.lastPrice - entity.preClosePx) ? self.offsetMaxPrice:fabs(entity.lastPrice-entity.preClosePx)
                self.maxVolume = self.maxVolume > entity.volume ? self.maxVolume : entity.volume
                
                if let r = entity.rate{
                    self.maxRatio = self.maxRatio > fabs(r) ? self.maxRatio : r
                    self.minRatio = self.minRatio < fabs(r) ? self.minRatio : r
                }
                
              
            }
            
            self.maxPrice = data.first!.preClosePx + self.offsetMaxPrice
            self.minPrice = data.first!.preClosePx - self.offsetMaxPrice
            
            if self.minPrice >= self.maxPrice{
                
                self.maxPrice = self.maxPrice * 1.02
                self.minPrice = self.minPrice * 0.98
                
            }
            
            for i in 0 ..< data.count {
                let entity = data[i]
                entity.avgPrice = entity.avgPrice < self.minPrice ? self.minPrice : entity.avgPrice
                entity.avgPrice = entity.avgPrice > self.maxPrice ? self.maxPrice : entity.avgPrice
            }
        }
    }
    
    
    override func drawGridBackground(_ context:CGContext,rect:CGRect){
        super.drawGridBackground(context, rect: rect)
        self.drawline(context, startPoint: CGPoint(x: self.contentWidth/2.0 + self.contentLeft, y: self.contentTop), stopPoint: CGPoint(x: self.contentWidth/2.0 + self.contentLeft,y: (self.upperChartHeightScale * self.contentHeight)+self.contentTop), color: self.borderColor , lineWidth: self.borderWidth/2.0)
    }
    
    func drawTimeLabel(_ context:CGContext){
        
        if !self.highlightLineCurrentEnabled{
            
            if let d = self.dataSet?.days, showFiveDayLabel{
                
                let width = self.contentWidth / 5
                for (index,day) in d.enumerated(){
                    let drawAttributes = self.xAxisAttributedDic
                    let startTimeAttStr = NSMutableAttributedString(string: day, attributes: drawAttributes)
                    let sizeStartTimeAttStr = startTimeAttStr.size()
                    self.drawLabel(context, attributesText: startTimeAttStr, rect: CGRect(x: self.contentLeft + (width - sizeStartTimeAttStr.width) / 2 + width * CGFloat(index), y: (self.upperChartHeightScale * self.contentHeight+self.contentTop), width: sizeStartTimeAttStr.width, height: sizeStartTimeAttStr.height))
                }
                
                
                
                

            }else{
                let drawAttributes = self.xAxisAttributedDic
                let startTimeAttStr = NSMutableAttributedString(string: "9:30", attributes: drawAttributes)
                let sizeStartTimeAttStr = startTimeAttStr.size()
                self.drawLabel(context, attributesText: startTimeAttStr, rect: CGRect(x: self.contentLeft, y: (self.upperChartHeightScale * self.contentHeight+self.contentTop), width: sizeStartTimeAttStr.width, height: sizeStartTimeAttStr.height))
                
                let midTimeAttStr = NSMutableAttributedString(string: "11:30/13:00", attributes: drawAttributes)
                let sizeMidTimeAttStr = midTimeAttStr.size()
                self.drawLabel(context, attributesText: midTimeAttStr, rect: CGRect(x: self.contentWidth/2.0 + self.contentLeft - sizeMidTimeAttStr.width/2.0, y: (self.upperChartHeightScale * self.contentHeight+self.contentTop), width: sizeMidTimeAttStr.width, height: sizeMidTimeAttStr.height))
                
                let stopTimeAttStr = NSMutableAttributedString(string: "15:00", attributes: drawAttributes)
                let sizeStopTimeAttStr = stopTimeAttStr.size()
                self.drawLabel(context, attributesText: stopTimeAttStr, rect: CGRect(x: self.contentRight - sizeStopTimeAttStr.width, y: (self.upperChartHeightScale * self.contentHeight+self.contentTop), width: sizeStopTimeAttStr.width, height: sizeStopTimeAttStr.height))
            }
           
        }
       
        
        
    }
    
    
    func drawTimeLine(_ context:CGContext){
        context.saveGState();

        self.candleCoordsScale = (self.upperChartHeightScale * self.contentInnerHeight)/(self.maxPrice-self.minPrice);
        self.volumeCoordsScale = (self.contentHeight - (self.upperChartHeightScale * self.contentHeight)-self.xAxisHeight)/(self.maxVolume - 0);
        
        let fillPath = CGMutablePath();
        
        if let data = self.dataSet?.data, data.count > 0{
            for i in 0 ..< data.count {
                let entity = data[i]
                let left = (self.volumeWidth * CGFloat(i) + self.contentLeft) + self.volumeWidth / 6.0;
                
                let candleWidth = self.volumeWidth - self.volumeWidth / 6.0;
                let startX = left + candleWidth/2.0
                var yPrice:CGFloat = 0;
                
                var color = self.dataSet!.volumeRiseColor
                
                if i > 0 {
                    let lastEntity = data[i-1]
                    let lastX:CGFloat = startX - self.volumeWidth
                    let lastYPrice = (self.maxPrice - lastEntity.lastPrice) * self.candleCoordsScale + self.contentInnerTop
                    yPrice = (self.maxPrice - entity.lastPrice) * self.candleCoordsScale + self.contentInnerTop
                    //画分时线
                    self.drawline(context, startPoint: CGPoint(x: lastX, y: lastYPrice), stopPoint: CGPoint(x: startX,y: yPrice), color: self.dataSet!.priceLineCorlor, lineWidth: self.dataSet!.lineWidth)
                    
                    
                    if drawAvgLine {
                        //画均线
                        let lastYAvg = (self.maxPrice - lastEntity.avgPrice)*self.candleCoordsScale  + self.contentInnerTop;
                        let yAvg = (self.maxPrice - entity.avgPrice)*self.candleCoordsScale  + self.contentInnerTop;
                        
                        self.drawline(context, startPoint: CGPoint(x: lastX, y: lastYAvg), stopPoint: CGPoint(x: startX, y: yAvg), color: self.dataSet!.avgLineCorlor, lineWidth: self.dataSet!.lineWidth)
                    }
                  
                    
                    
                    if (entity.lastPrice > lastEntity.lastPrice) {
                        color = self.dataSet!.volumeRiseColor;
                    }else if (entity.lastPrice < lastEntity.lastPrice){
                        color = self.dataSet!.volumeFallColor;
                    }else{
                        color = self.dataSet!.volumeTieColor;
                    }
    /* TODO: FIX!!!
                     
                    // NEW!
                    //let path = CGMutablePath()
                    //path.move(to: CGPoint(x: lineFrame.midX, y: lineFrame.midY))
                    //path.addLine(to: CGPoint(x: lineFrame.origin.x + lineFrame.width / 2, y: lineFrame.origin.y))
                     
                    // OLD!
                    if (1 == i) {
                        CGPathMoveToPoint(fillPath, nil, self.contentLeft, (self.upperChartHeightScale * self.contentHeight) + self.contentInnerTop / 2 );
                        CGPathAddLineToPoint(fillPath, nil, self.contentLeft,lastYPrice);
                        CGPathAddLineToPoint(fillPath, nil, lastX, lastYPrice);
                    }else{
                        CGPathAddLineToPoint(fillPath, nil, startX, yPrice);
                    }
                    if ((data.count - 1) == i) {
                        CGPathAddLineToPoint(fillPath, nil, startX, yPrice);
                        CGPathAddLineToPoint(fillPath, nil, startX, (self.upperChartHeightScale * self.contentHeight) + self.contentInnerTop / 2);
                        fillPath.closeSubpath();
                    }
    */
                }
                
                //成交量
                let volume = ((entity.volume - 0) * self.volumeCoordsScale);
                self.drawRect(context, rect: CGRect(x: left, y: self.contentBottom - volume , width: candleWidth, height: volume), color: color)
                
                //十字线
                if (self.highlightLineCurrentEnabled) {
                    if (i == self.highlightLineCurrentIndex) {
                        if (i == 0) {
                            yPrice = (self.maxPrice - entity.lastPrice)*self.candleCoordsScale  + self.contentTop;
                        }
                        
                        self.drawHighlighted(context, point: CGPoint(x: startX, y: yPrice), idex: i, value:entity, color: self.dataSet!.highlightLineColor, lineWidth: self.dataSet!.highlightLineWidth)
                        
                        if self.delegate != nil{
                            self.delegate?.chartValueSelected!(self, entry: entity, entryIndex: i)
                        }
                    }
                }
                
                if (self.endPointShowEnabled) {
                    if (i == data.count - 1) {
                        self.breathingPoint.frame = CGRect(x: startX-4/2, y: yPrice-4/2,width: 4,height: 4);
                    }
                }

            }
            
            if (self.dataSet!.drawFilledEnabled && data.count > 0) {
                self.drawLinearGradient(context, path: fillPath, alpha: self.dataSet!.fillAlpha, startColor: self.dataSet!.fillStartColor.cgColor, endColor: self.dataSet!.fillStopColor.cgColor)
            }
            
            context.restoreGState();
        }
    }
    
    func drawLinearGradient(_ context:CGContext,path:CGPath,alpha:CGFloat,startColor:CGColor,endColor:CGColor){
        let colorSpace = CGColorSpaceCreateDeviceRGB();
        
        let locations:[CGFloat] = [ 0.0, 1.0 ]
        
        let colors = [startColor,endColor]
        
        let gradient = CGGradient(colorsSpace: colorSpace, colors: colors as CFArray, locations: locations);
    
        
        let pathRect = path.boundingBox;
        
        //具体方向可根据需求修改
        let startPoint = CGPoint(x: pathRect.midX, y: pathRect.minY);
        let endPoint = CGPoint(x: pathRect.midX, y: pathRect.maxY);
        
        context.saveGState();
        context.addPath(path);
        context.clip();
        context.setAlpha(self.dataSet!.fillAlpha)
        context.drawLinearGradient(gradient!, start: startPoint, end: endPoint, options: CGGradientDrawingOptions.drawsBeforeStartLocation)
        context.restoreGState()
    }
    /*
    func handleLongPressGestureAction(_ recognizer:UIPanGestureRecognizer){
        if !self.highlightLineShowEnabled{
            return
        }
        
        if (recognizer.state == UIGestureRecognizerState.began) {
            let  point = recognizer.location(in: self)
            
            if (point.x > self.contentLeft && point.x < self.contentRight && point.y > self.contentTop && point.y<self.contentBottom) {
                self.highlightLineCurrentEnabled = true;
                self.getHighlightByTouchPoint(point)
                
            }
            if self.highlightLineCurrentIndex < self.dataSet?.data?.count{
                NotificationCenter.default.post(name: Notification.Name(rawValue: JSUNotificationTimeLineLongPress), object: self.dataSet?.data?[self.highlightLineCurrentIndex])
                NotificationCenter.default.post(name: Notification.Name(rawValue: JSUNotificationLandTimeLineLongPress), object: self.dataSet?.data?[self.highlightLineCurrentIndex])
            }
            
        }
        if (recognizer.state == UIGestureRecognizerState.ended) {
            self.highlightLineCurrentEnabled = false
            self.setNeedsDisplay()
            NotificationCenter.default.post(name: Notification.Name(rawValue: JSUNotificationKLineLongUnPress), object: nil)
            if self.highlightLineCurrentIndex < self.dataSet?.data?.count{
            NotificationCenter.default.post(name: Notification.Name(rawValue: JSUNotificationLandKLineLongUnPress), object: self.dataSet?.data?[self.highlightLineCurrentIndex])
            }
        }
        if (recognizer.state == UIGestureRecognizerState.changed) {
            
            let  point = recognizer.location(in: self)
            
            if (point.x > self.contentLeft && point.x < self.contentRight && point.y > self.contentTop && point.y<self.contentBottom) {
                self.highlightLineCurrentEnabled = true;
                self.getHighlightByTouchPoint(point)
               
                
            }
            
            if self.highlightLineCurrentIndex < self.dataSet?.data?.count{
                NotificationCenter.default.post(name: Notification.Name(rawValue: JSUNotificationTimeLineLongPress), object: self.dataSet?.data?[self.highlightLineCurrentIndex])
                NotificationCenter.default.post(name: Notification.Name(rawValue: JSUNotificationLandTimeLineLongPress), object: self.dataSet?.data?[self.highlightLineCurrentIndex])
            }
            
            
        }
    }
    
    override func handleTapGestureAction(_ recognizer:UITapGestureRecognizer){
        super.handleTapGestureAction(recognizer)
    }
    */
    override func getHighlightByTouchPoint(_ point: CGPoint) {
        self.highlightLineCurrentIndex = Int((point.x - self.contentLeft)/self.volumeWidth);
        self.setNeedsDisplay(self.frame)
    }
    
    override func notifyDataSetChanged() {
        super.notifyDataSetChanged()
        self.setNeedsDisplay(self.frame)
    }
    
    override func notifyDeviceOrientationChanged() {
        super.notifyDeviceOrientationChanged()
    }
    
    func breathingLight(_ time:Double)->CAAnimationGroup{
 
        let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")
        scaleAnimation.fromValue = 1
        scaleAnimation.toValue = 3
        scaleAnimation.autoreverses = false
        scaleAnimation.isRemovedOnCompletion = true;
        scaleAnimation.repeatCount = MAXFLOAT
        scaleAnimation.duration = time
        
        let opacityAnimation = CABasicAnimation(keyPath:"opacity")
        opacityAnimation.fromValue = 1.0
        opacityAnimation.toValue = 0
        opacityAnimation.autoreverses = false;
        opacityAnimation.duration = time
        opacityAnimation.repeatCount = MAXFLOAT;
        opacityAnimation.isRemovedOnCompletion = true;
        opacityAnimation.fillMode = kCAFillModeForwards;
        
        let group = CAAnimationGroup()
        group.duration = time
        group.autoreverses = false
        group.isRemovedOnCompletion = true
        group.fillMode = kCAFillModeForwards
        group.animations = [scaleAnimation,opacityAnimation]
        group.repeatCount = MAXFLOAT
        
        return group
    }
}
