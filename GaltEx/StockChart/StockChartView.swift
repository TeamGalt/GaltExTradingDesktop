//
//  StockChartView.swift
//  TestStockChart
//
//  Created by Laptop on 3/6/18.
//  Copyright © 2018 armonia. All rights reserved.
//

import Cocoa
import Foundation

/* USE
 
 - assign class StockChartView to NSView
 - assign outlet to viewController.chartView as StockChartView
 - extend viewController class with StockChartViewDelegate
 - assign chartView.delegate to viewController
 - on viewDidLoad: chartView.setup()
 - request data from web or local
 -   parse as jsonList (array)
 -   chartView.load(json)
 -     chartView.show() on DispatchQeue.main.async {}
 
 */

@objc protocol StockChartViewDelegate {
    @objc optional func chartValueSelected(_ chartView: StockChartBase, entry: AnyObject, entryIndex: Int)
    @objc optional func chartValueNothingSelected(_ chartView: StockChartBase)
    @objc optional func chartKlineScrollLeft(_ chartView: StockChartBase)
}

class StockChartView: KLineStockChartView {

    var isLandscape = true
    var dataSource: [ChartLineModel] = []

    func setup() {
        //self.userInteractionEnabled = true
        self.setupChartOffsetWithLeft(16, top:10, right:16, bottom:10)
        self.gridBackgroundColor = Theme.color.backDark //NSColor.black
        self.borderColor    = NSColor(red: 203/255.0, green: 215/255.0, blue: 224/255.0, alpha: 1)
        self.borderWidth    = 0.5
        self.candleWidth    = 20  // 8
        self.candleMaxWidth = 40  // 30
        self.candleMinWidth = 1
        self.upperChartHeightScale = 0.7
        self.xAxisHeight    = 25
        self.highlightLineShowEnabled = true
        self.zoomEnabled    = true
        self.scrollEnabled  = true
        
        self.commonInit()
    }
    
    func load(_ json: ListMap) {
        self.dataSource = []

        for item in json {
            var line = ChartLineModel()
            line.dt    = item["dt"]    as? String
            //line.tick  = item["tick"]  as? String
            line.open  = item["open"]  as? Double
            line.close = item["close"] as? Double
            line.high  = item["high"]  as? Double
            line.low   = item["low"]   as? Double
            line.vol   = item["vol"]   as? Double
            //line.inc = item["inc"]   as? Double
            //line.ma  = item["ma"]    as? JSUMAModel
            dataSource.append(line)
        }
    }
    
    func show(data: [ChartLineModel]){
        self.dataSource = data
        self.show()
    }
    
    func show() {
        var array = [KLineEntity]()
        
        for (index, dic) in self.dataSource.enumerated(){
            let entity = KLineEntity()
            if let h = dic.high{
                entity.high = CGFloat(h)
            }
            
            if let o = dic.open{
                entity.open = CGFloat(o)
                if index == 0 {
                    entity.preClosePx = CGFloat(o)
                } else {
                    if let c = self.dataSource[index-1].close {
                        entity.preClosePx = CGFloat(c)
                    } else {
                        entity.preClosePx = CGFloat(o)
                    }
                    
                }
            }
            
            if let l = dic.low {
                entity.low = CGFloat(l)
            }
            
            if let c = dic.close {
                entity.close = CGFloat(c)
            }
            
            if let r = dic.inc {
                entity.rate = CGFloat(r)
            }
            
            if let d = dic.dt {
                entity.date = d
            }
            
            if let ma5 = dic.ma?.MA5 {
                entity.ma5 = CGFloat(ma5)
            }
            
            if let ma10 = dic.ma?.MA10 {
                entity.ma10 = CGFloat(ma10)
            }
            
            if let ma20 = dic.ma?.MA20 {
                entity.ma20 = CGFloat(ma20)
            }
            
            if let v = dic.vol {
                entity.volume = CGFloat(v)
            }
            
            //print(entity.date, entity.close)
            array.append(entity)
        }
        
        // Assign dataset
        let dataSet = KLineDataSet()
        dataSet.data = array
        
        // Final settings
        dataSet.highlightLineColor = NSColor(hex: 0x546679)
        
        // Setup chart
        self.setupData(dataSet)
        //self.chartView.setChartDimens(760, height: 360)
        //self.chartView.setChartDimens(self.chartView.width, height: self.chartView.height) // Force redraw
        self.autoSize()
        self.display()
        //self.chartView.setNeedsDisplay(self.chartView.frame)
        //self.chartView.draw(rect?)
    }

}
