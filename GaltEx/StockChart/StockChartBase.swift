//
//  StockChartBase.swift
//  StockChart
//
//  Created by 苏小超 on 16/2/23.
//  Copyright © 2016年 com.jason. All rights reserved.
//

import Cocoa
import Foundation

let JSUNotificationKLineLongPress        = "JSUNotificationKLineLongPress"
let JSUNotificationLandKLineLongPress    = "JSUNotificationLandKLineLongPress"
let JSUNotificationKLineLongUnPress      = "JSUNotificationKLineLongUnPress"
let JSUNotificationLandKLineLongUnPress  = "JSUNotificationLandKLineLongUnPress"
let JSUNotificationTimeLineLongPress     = "JSUNotificationTimeLineLongPress"
let JSUNotificationLandTimeLineLongPress = "JSUNotificationLandTimeLineLongPress"

/* 
// Moved to StochChartViewDelegate
@objc protocol KLineChartViewDelegate{
    @objc optional func chartValueSelected(_ chartView: StockChartBase, entry: AnyObject, entryIndex: Int)
    @objc optional func chartValueNothingSelected(_ chartView: StockChartBase)
    @objc optional func chartKlineScrollLeft(_ chartView: StockChartBase)
}
*/

open class StockChartBase: NSView {
    
    override open var isFlipped: Bool { return true } // Flip coord system
    
    var statusView  = NSView()
    var statusLabel = NSTextField()
    //var act = NSActivityIndicatorView()
    var contentRect: CGRect      = CGRect.zero
    var contentInnerRect: CGRect = CGRect.zero
    var chartHeight  : CGFloat = 0
    var chartWidth   : CGFloat = 0
    var offsetLeft   : CGFloat = 10
    var offsetTop    : CGFloat = 10
    var offsetRight  : CGFloat = 10
    var offsetBottom : CGFloat = 10
    
    var contentInnerTop:CGFloat{
        get{
            return contentInnerRect.origin.y
        }
    }
    
    var contentInnerBottom:CGFloat{
        get{
            return contentInnerRect.origin.y + contentInnerRect.size.height;
        }
    }
    
    var contentInnerHeight:CGFloat{
        get{
            return contentInnerRect.size.height
        }
    }
    
    var contentTop:CGFloat{
        get{
            return contentRect.origin.y
        }
    }
    
    var contentLeft:CGFloat{
        get{
            return contentRect.origin.x
        }
    }
    
    var contentRight:CGFloat{
        get{
            return contentRect.origin.x + contentRect.size.width;
        }
    }
    
    var contentBottom:CGFloat{
        get{
            return contentRect.origin.y + contentRect.size.height;
        }
    }
    
    var contentWidth:CGFloat{
        get{
            return contentRect.size.width
        }
    }
    
    var contentHeight:CGFloat{
        get{
            return contentRect.size.height
        }
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.addObserver()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addObserver()
    }
    
    deinit{
        self.removeObserver(self, forKeyPath: "bounds")
        self.removeObserver(self, forKeyPath: "frame")
    }
    
    func addObserver(){
        self.addObserver(self, forKeyPath: "bounds", options: NSKeyValueObservingOptions.new, context: nil)
        self.addObserver(self, forKeyPath: "frame",  options: NSKeyValueObservingOptions.new, context: nil)
        
        //UIDevice.current.beginGeneratingDeviceOrientationNotifications()
        //NotificationCenter.default.addObserver(self, selector: #selector(deviceOrientationDidChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil)
    }
    
    override open func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "bounds" || keyPath == "frame"{
            let bounds = self.bounds
            if ((bounds.size.width != self.chartWidth)||(bounds.size.height != self.chartHeight)){
                self.setChartDimens(bounds.size.width, height: bounds.size.height)
                self.notifyDataSetChanged()
            }
        }
    }
    
    func notifyDeviceOrientationChanged(){
        
    }
    
    func notifyDataSetChanged(){
        
    }
    
    //func deviceOrientationDidChange(_ notification:Notification){
    //    if UIDevice.current.orientation != UIDeviceOrientation.unknown{
    //        self.notifyDeviceOrientationChanged()
    //    }
    //}
    
    func setupChartOffsetWithLeft(_ left: CGFloat, top: CGFloat, right: CGFloat, bottom: CGFloat){
        self.offsetLeft = left
        self.offsetRight = right
        self.offsetTop = top
        self.offsetBottom = bottom
    }

    func autoSize() {
        self.setChartDimens(width, height: height)
    }

    func setChartDimens(_ width: CGFloat, height: CGFloat){
        self.chartHeight = height;
        self.chartWidth = width;
        self.restrainViewPort(offsetLeft, offsetTop: offsetTop, offsetRight: offsetRight, offsetBottom: offsetBottom)
    }
    
    func restrainViewPort(_ offsetLeft: CGFloat, offsetTop: CGFloat, offsetRight: CGFloat, offsetBottom: CGFloat){
        contentRect.origin.x = offsetLeft;
        contentRect.origin.y = offsetTop;
        contentRect.size.width = self.chartWidth - offsetLeft - offsetRight;
        contentRect.size.height = self.chartHeight - offsetBottom - offsetTop;
        
        contentInnerRect = CGRect(x: contentRect.origin.x, y: contentRect.origin.y + 10, width: contentRect.width, height: contentRect.height - 20)
        statusView.frame = CGRect(x: contentRect.midX-60, y: contentRect.midY-50, width: 120, height: 30)
        statusLabel.frame = CGRect(x: 0,y: 5, width: statusView.width, height: 20)
        //act.frame = CGRect(x: 6,y: 10, width: 10, height: 10)
        
    }
    
    func isInBoundsX(_ x:CGFloat) -> Bool{
        if self.isInBoundsLeft(x) && self.isInBoundsLeft(x) {
            return true
        }else{
            return false
        }
    }
    
    func isInBoundsY(_ y:CGFloat) -> Bool{
        if self.isInBoundsTop(y) && self.isInBoundsBottom(y) {
            return true
        }else{
            return false
        }
    }
    
    func isInBoundsX(_ x:CGFloat,y:CGFloat)-> Bool{
        if self.isInBoundsX(x) && isInBoundsY(y){
            return true
        }else{
            return false
        }
    }
    
    func isInBoundsLeft(_ x:CGFloat) -> Bool{
        return contentRect.origin.x <= x ? true : false
    }
    
    func isInBoundsRight(_ x:CGFloat) -> Bool{
        let normalizedX = Int(x * CGFloat(100)/CGFloat(100))
        return Int(contentRect.origin.x + contentRect.size.width) >= normalizedX ? true : false
    }
    
    func isInBoundsTop(_ y:CGFloat) -> Bool{
        return contentRect.origin.y <= y ? true : false
    }
    
    func isInBoundsBottom(_ y:CGFloat) -> Bool{
        let normalizedY = Int(y * CGFloat(100)/CGFloat(100))
        return Int(contentRect.origin.y + contentRect.size.height) >= normalizedY ? true : false;
    }
}
