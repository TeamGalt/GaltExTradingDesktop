//
//  KLineStockChartViewBase.swift
//  StockChart
//
//  Created by 苏小超 on 16/2/23.
//  Copyright © 2016年 com.jason. All rights reserved.
//

import Cocoa
import Foundation

open class KLineStockChartViewBase: StockChartBase {
    
    var delegate: StockChartViewDelegate?
    var upperChartHeightScale:CGFloat = 1
    var xAxisHeight:CGFloat = 0
    
    var gridBackgroundColor:NSColor = NSColor.white
    var borderColor = NSColor(hex: 0xe4e4e4)
    var borderWidth : CGFloat = 0
    
    var maxPrice  = CGFloat.leastNormalMagnitude
    var minPrice  = CGFloat.greatestFiniteMagnitude
    var maxRatio  = CGFloat.leastNormalMagnitude
    var minRatio  = CGFloat.greatestFiniteMagnitude
    var maxVolume = CGFloat.leastNormalMagnitude
    var candleCoordsScale: CGFloat = 0
    var volumeCoordsScale: CGFloat = 0
    
    var highlightLineCurrentIndex : Int = 0
    var highlightLineCurrentPoint : CGPoint = CGPoint.zero
    var highlightLineCurrentEnabled = false
    var drawLabelPriceInside = true
    var drawLabelRatioInside = true
    var drawVolumeLabel      = false
    var drawMidLabelPrice    = false

    var defaultAttributedDic:[String:AnyObject]{
        get{
            return [NSFontAttributeName:NSFont.systemFont(ofSize: 10),NSBackgroundColorAttributeName:gridBackgroundColor]
        }
    }
    
    var leftYAxisAttributedDic:[String:AnyObject] = [NSFontAttributeName: NSFont.systemFont(ofSize: 9),NSBackgroundColorAttributeName:NSColor.clear,NSForegroundColorAttributeName: NSColor(hex: 0x8695a6)]
    var xAxisAttributedDic = [NSFontAttributeName: NSFont.systemFont(ofSize: 10),NSBackgroundColorAttributeName:NSColor.clear,NSForegroundColorAttributeName: NSColor(hex: 0x8695a6)]
    var highlightAttributedDic = [NSFontAttributeName: NSFont.systemFont(ofSize: 10),NSBackgroundColorAttributeName:NSColor(hex: 0x8695a6),NSForegroundColorAttributeName: NSColor.white]
    
    var highlightLineShowEnabled = true
    var scrollEnabled = false
    var zoomEnabled = false

    

    override init(frame: CGRect) {
        super.init(frame: frame)

    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func hiddenStatusView(){
        //self.act.stopAnimating()
        self.statusView.isHidden = true
    }
    
    func showStatusView(){
        self.statusLabel.stringValue = "数据加载中"
        //self.act.startAnimating()
        self.statusView.isHidden = false
    }
    
    func showFailStatusView(){
        self.statusLabel.stringValue = "数据加载失败"
        //self.act.stopAnimating()
    }
    
    
    
    func drawGridBackground(_ context: CGContext, rect: CGRect){
        context.setFillColor(gridBackgroundColor.cgColor);
        context.fill(rect);
        
        //画外面边框
        context.setLineWidth(self.borderWidth/2);
        context.setStrokeColor(self.borderColor.cgColor);
        context.stroke(CGRect(x: self.contentLeft, y: self.contentTop, width: self.contentWidth, height: (self.upperChartHeightScale * self.contentHeight)));

        self.drawline(context, startPoint: CGPoint(x: self.contentLeft,y: self.contentInnerTop), stopPoint: CGPoint(x: self.contentLeft+self.contentWidth,y: self.contentInnerTop), color: self.borderColor, lineWidth: self.borderWidth/2.0)
        self.drawline(context, startPoint: CGPoint(x: self.contentLeft,y: self.contentInnerTop + (self.upperChartHeightScale * self.contentHeight)-self.contentInnerTop), stopPoint: CGPoint(x: self.contentLeft+self.contentWidth,y: self.contentInnerTop + (self.upperChartHeightScale * self.contentHeight)-self.contentInnerTop), color: self.borderColor, lineWidth: self.borderWidth/2.0)
        
        //画交易量边框
        context.stroke(CGRect(x: self.contentLeft, y: (self.upperChartHeightScale * self.contentHeight)+self.xAxisHeight, width: self.contentWidth, height: (self.contentBottom - (self.upperChartHeightScale * self.contentHeight)-self.xAxisHeight)));
        
        //画中间的线
        self.drawline(context, startPoint: CGPoint(x: self.contentLeft,y: (self.upperChartHeightScale * self.contentHeight)/2.0 + self.contentTop), stopPoint: CGPoint(x: self.contentRight, y: (self.upperChartHeightScale * self.contentHeight)/2.0 + self.contentTop), color: self.borderColor, lineWidth: self.borderWidth/2.0)
        self.drawline(context, startPoint: CGPoint(x: self.contentLeft,y: (self.upperChartHeightScale * self.contentInnerHeight)/4.0 + self.contentInnerTop), stopPoint: CGPoint(x: self.contentRight, y: (self.upperChartHeightScale * self.contentInnerHeight)/4.0 + self.contentInnerTop), color: self.borderColor, lineWidth: self.borderWidth/2.0)
        self.drawline(context, startPoint: CGPoint(x: self.contentLeft,y: (self.upperChartHeightScale * self.contentInnerHeight)*0.75 + self.contentInnerTop), stopPoint: CGPoint(x: self.contentRight, y: (self.upperChartHeightScale * self.contentInnerHeight)*0.75 + self.contentInnerTop), color: self.borderColor, lineWidth: self.borderWidth/2.0)
    }
    
    func drawLabelPrice(_ context:CGContext){
        if !self.highlightLineCurrentEnabled{
            let maxPriceStr = self.handleStrWithPrice(self.maxPrice)
            let maxPriceAttStr = NSMutableAttributedString(string: maxPriceStr, attributes: self.leftYAxisAttributedDic)
            let sizeMaxPriceAttStr = maxPriceAttStr.size()
            var labelX = CGFloat(0)
            if drawLabelPriceInside{
                labelX = self.contentLeft
            }else{
                labelX = self.contentLeft - sizeMaxPriceAttStr.width
            }
            self.drawLabel(context, attributesText: maxPriceAttStr, rect: CGRect(x: labelX, y: self.contentTop, width: sizeMaxPriceAttStr.width, height: sizeMaxPriceAttStr.height))
            
            if drawMidLabelPrice{
                let midPriceStr = self.handleStrWithPrice((self.maxPrice+self.minPrice)/2.0)
                let midPriceAttStr = NSMutableAttributedString(string: midPriceStr, attributes: self.leftYAxisAttributedDic)
                let sizeMidPriceAttStr = midPriceAttStr.size()
                
                if drawLabelPriceInside{
                    labelX = self.contentLeft
                }else{
                    labelX = self.contentLeft - sizeMidPriceAttStr.width
                }
                
                self.drawLabel(context, attributesText: midPriceAttStr, rect: CGRect(x: labelX, y: ((self.upperChartHeightScale * self.contentHeight)/2.0 + self.contentTop)-sizeMidPriceAttStr.height/2.0, width: sizeMidPriceAttStr.width, height: sizeMidPriceAttStr.height))
            }
            
            
            
            let minPriceStr = self.handleStrWithPrice(self.minPrice)
            let minPriceAttStr = NSMutableAttributedString(string: minPriceStr, attributes: self.leftYAxisAttributedDic)
            let sizeMinPriceAttStr = minPriceAttStr.size()
            if drawLabelPriceInside {
                labelX = self.contentLeft
            } else {
                labelX = self.contentLeft - sizeMinPriceAttStr.width
            }
            
            self.drawLabel(context, attributesText: minPriceAttStr, rect: CGRect(x: labelX, y: ((self.upperChartHeightScale * self.contentHeight) + self.contentTop - sizeMinPriceAttStr.height ), width: sizeMinPriceAttStr.width, height: sizeMinPriceAttStr.height))
        }
        
        if drawVolumeLabel {
            let zeroVolumeAttStr =  NSMutableAttributedString(string: self.handleShowWithVolume(self.maxVolume), attributes: self.leftYAxisAttributedDic)
            let zeroVolumeAttStrSize = zeroVolumeAttStr.size()
            self.drawLabel(context, attributesText: zeroVolumeAttStr, rect: CGRect(x: self.contentLeft - zeroVolumeAttStrSize.width, y: self.contentBottom - zeroVolumeAttStrSize.height, width: zeroVolumeAttStrSize.width, height: zeroVolumeAttStrSize.height))
            
            let maxVolumeStr = self.handleShowNumWithVolume(self.maxVolume)
            let maxVolumeAttStr = NSMutableAttributedString(string: maxVolumeStr, attributes: self.leftYAxisAttributedDic)
            let maxVolumeAttStrSize = maxVolumeAttStr.size()
            self.drawLabel(context, attributesText: maxVolumeAttStr, rect: CGRect(x: self.contentLeft - maxVolumeAttStrSize.width, y: (self.upperChartHeightScale * self.contentHeight)+self.xAxisHeight, width: maxVolumeAttStrSize.width, height: maxVolumeAttStrSize.height))
        }
      
        
        
    }
    
    func drawHighlighted(_ context:CGContext, point:CGPoint, idex:Int, value:AnyObject, color:NSColor, lineWidth:CGFloat){
        var leftMarkerStr = ""
        var bottomMarkerStr = ""
        var rightMarkerStr = ""
        
        if value.isKind(of: TimeLineEntity.self) {
            let entity = value as! TimeLineEntity
            
            leftMarkerStr = self.handleStrWithPrice(entity.lastPrice)
            
            if let t = entity.currtTime{
                 bottomMarkerStr = t
            }
           
            if let r = entity.rate{
                rightMarkerStr = r.toStringWithFormat("%.2f")
            }
        } else if value.isKind(of: KLineEntity.self) {
            let entity = value as! KLineEntity
            
                leftMarkerStr = self.handleStrWithPrice(entity.close)
            
                bottomMarkerStr = entity.date
            
                rightMarkerStr = entity.rate.toStringWithFormat("%.2f")
        } else {
            return
        }
        
//        if leftMarkerStr == "" || bottomMarkerStr == "" || rightMarkerStr == "" {
//            return
//        }
        
        bottomMarkerStr = (" " + bottomMarkerStr) + " "
        context.setStrokeColor(color.cgColor);
        context.setLineWidth(lineWidth);
        context.beginPath();
        context.move(to: CGPoint(x: point.x, y: self.contentTop));
        context.addLine(to: CGPoint(x: point.x, y: self.contentBottom));
        context.strokePath();
        
        
        context.beginPath();
        context.move(to: CGPoint(x: self.contentLeft, y: point.y));
        context.addLine(to: CGPoint(x: self.contentRight, y: point.y));
        context.strokePath();
        
        let radius:CGFloat = 3.0;
        context.setFillColor(color.cgColor);
        context.fillEllipse(in: CGRect(x: point.x-(radius/2.0), y: point.y-(radius/2.0), width: radius, height: radius))
        
        let drawAttributes = self.highlightAttributedDic
        
        let leftMarkerStrAtt = NSMutableAttributedString(string: leftMarkerStr, attributes: drawAttributes)
        let leftMarkerStrAttSize = leftMarkerStrAtt.size()
        var labelX = CGFloat(0)
        if drawLabelPriceInside {
            labelX = self.contentLeft
        } else {
           labelX = self.contentLeft - leftMarkerStrAttSize.width
        }
        self.drawLabel(context, attributesText: leftMarkerStrAtt, rect: CGRect(x: labelX,y: point.y - leftMarkerStrAttSize.height/2.0, width: leftMarkerStrAttSize.width, height: leftMarkerStrAttSize.height))
        
        let bottomMarkerStrAtt = NSMutableAttributedString(string: bottomMarkerStr, attributes: drawAttributes)
        let bottomMarkerStrAttSize = bottomMarkerStrAtt.size()
        self.drawLabel(context, attributesText: bottomMarkerStrAtt, rect: CGRect(x: point.x - bottomMarkerStrAttSize.width/2.0,  y: ((self.upperChartHeightScale * self.contentHeight) + self.contentTop), width: bottomMarkerStrAttSize.width, height: bottomMarkerStrAttSize.height))
        
        let rightMarkerStrAtt = NSMutableAttributedString(string: rightMarkerStr, attributes: drawAttributes)
        let rightMarkerStrAttSize = rightMarkerStrAtt.size()
        
        if drawLabelRatioInside {
            labelX = self.contentRight - rightMarkerStrAttSize.width
        } else {
            labelX = self.contentRight
        }
        self.drawLabel(context, attributesText: rightMarkerStrAtt, rect: CGRect(x: labelX, y: point.y - rightMarkerStrAttSize.height/2.0, width: rightMarkerStrAttSize.width, height: rightMarkerStrAttSize.height))
    }
    
    func drawLabel(_ context:CGContext,attributesText:NSAttributedString,rect:CGRect) {
        context.setFillColor(NSColor.clear.cgColor)
        attributesText.draw(in: rect)
    }
    
    func drawRect(_ context:CGContext,rect:CGRect,color:NSColor) {
        if ((rect.origin.x + rect.size.width) > self.contentRight) {
            return;
        }
        context.setFillColor(color.cgColor);
        context.fill(rect);
    }
    
    func drawline(_ context: CGContext, startPoint: CGPoint, stopPoint: CGPoint, color: NSColor, lineWidth: CGFloat){
        if (startPoint.x < self.contentLeft || stopPoint.x > self.contentRight || startPoint.y < self.contentTop || stopPoint.y < self.contentTop) {
            return
        }
        context.setStrokeColor(color.cgColor)
        context.setLineWidth(lineWidth)
        context.beginPath()
        context.move(to: CGPoint(x: startPoint.x, y: startPoint.y))
        context.addLine(to: CGPoint(x: stopPoint.x, y: stopPoint.y))
        context.strokePath()
    }
    
    func handleStrWithPrice(_ price:CGFloat) -> String {
        return NSString(format: "%.2f", price) as String
    }
    
    func handleRateWithPrice(_ price:CGFloat,originPX:CGFloat) -> String {
         return NSString(format: "%.2f",(price - originPX)/originPX * 100.00) as String
    }
    
    func handleShowWithVolume(_ argVolume:CGFloat) -> String {
        let volume = argVolume/100.0
        
        if (volume < 10000.0) {
            return "手 ";
        }else if (volume > 10000.0 && volume < 100000000.0){
            return "万手 ";
        }else{
            return "亿手 ";
        }
    }
    
    func handleShowNumWithVolume(_ argVolume:CGFloat) -> String {
        let volume = argVolume/100.0
        if (volume < 10000.0) {
            return NSString(format: "%.0f", volume) as String
        } else if (volume > 10000.0 && volume < 100000000.0) {
            return NSString(format: "%.2f", volume/10000.0) as String
        } else {
            return NSString(format: "%.2f", volume/100000000.0) as String
        }
    }
    

    
    func getHighlightByTouchPoint(_ point:CGPoint){
        //
    }
    
    /*
    func handleTapGestureAction(_ recognizer:UITapGestureRecognizer){
        if self.highlightLineCurrentEnabled{
            self.highlightLineCurrentEnabled = false
        }
        
        self.setNeedsDisplay()
    }
    */
    
    
}
