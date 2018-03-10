//
//  TableMarkets.swift
//  GaltEx
//
//  Created by Laptop on 2/28/18.
//  Copyright © 2018 GaltBank. All rights reserved.
//

import Cocoa
import Foundation
import StellarSDK


class TableMarkets: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    struct TableMarketsRow {
        let symbol    : String
        let name      : String
        let rank      : String
        let priceUsd  : Double
        let priceXlm  : Double
        let volume    : Double
        let marketCap : Double
        let change01  : Double
        let change24  : Double
        let supply    : Double
        let available : Double
        let avg       : Double
        let high      : Double
        let low       : Double
        let open      : Double
        let close     : Double
        let inactive  : Bool
    }
    
    
    var app = NSApp.delegate as! AppDelegate
    var tableView: NSTableView?
    var tableSelection: (_ selected: Int) -> () = { index in }
    var list: [TableMarketsRow] = [TableMarketsRow]()
    var selected = 0
    var address  = ""
    var xlmPrice = 0.0
    
    func assignTableView(_ tableView: NSTableView) {
        self.tableView = tableView
        self.tableView?.target     = self
        self.tableView?.delegate   = self
        self.tableView?.dataSource = self
        self.tableView?.font       = Theme.font.monodigits
    }
    
    func parseTable(_ json: Dixy) {
        list = []
        for (key, val) in json {
            guard let dixy = val as? Dixy else { continue }
            if dixy.bln("inactive") { continue }

            let symbol    = key
            let name      = dixy.str("name")
            let rank      = dixy.str("rank")
            let priceUsd  = dixy.dbl("priceusd")
            let priceXlm  = dixy.dbl("pricexlm")
            let change01  = dixy.dbl("change01h")
            let change24  = dixy.dbl("change24h")
            let volume    = dixy.dbl("volume")
            let marketCap = dixy.dbl("marketcap")
            let avg       = dixy.dbl("avg")
            let high      = dixy.dbl("high")
            let low       = dixy.dbl("low")
            let open      = dixy.dbl("open")
            let close     = dixy.dbl("close")
            let supply    = dixy.dbl("supply")
            let available = dixy.dbl("available")
            let inactive  = dixy.bln("inactive")

            let item = TableMarkets.TableMarketsRow(
                symbol    : symbol,
                name      : name,
                rank      : rank,
                priceUsd  : priceUsd,
                priceXlm  : priceXlm,
                volume    : volume,
                marketCap : marketCap,
                change01  : change01,
                change24  : change24,
                supply    : supply,
                available : available,
                avg       : avg,
                high      : high,
                low       : low,
                open      : open,
                close     : close,
                inactive  : inactive
            )
            if symbol == "USD" { self.xlmPrice = priceXlm }
            list.append(item)
        }
        list.sort(by: { $1.symbol > $0.symbol })
    }
    
    func load(callback: @escaping Completion) {
        WebController.getTicker { json, error in
            if error != nil { callback(false); return }
            self.parseTable(json)
            DispatchQueue.main.async {
                self.tableView?.reloadData()
                self.tableView?.font = Theme.font.monodigits
                callback(true)
            }
        }
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn else { return nil }
        
        let item = list[row]
        let cellId = column.identifier
        
        var text = ""
        
        switch cellId {
        case "textSymbol"   : text = item.symbol; break
        case "textPriceUsd" : text = item.priceUsd.money; break
        case "textPriceXlm" : text = item.priceXlm.money; break
        case "textChange01" : text = item.change01.money; break
        case "textChange24" : text = item.change24.money; break
        default             : text = "?"
        }
        
        
        if let cell = tableView.make(withIdentifier: cellId, owner: self) as? NSTableCellView {
            cell.textField?.stringValue = text

            if cellId == "textPriceUsd" {
                cell.textField?.font = Theme.font.monodigits
            }
            
            if cellId == "textPriceXlm" {
                cell.textField?.font = Theme.font.monodigits
            }
            
            if cellId == "textChange01" {
                cell.textField?.font = Theme.font.monodigits
                if item.change01 < 0 { cell.textField?.textColor = Theme.color.goDn }
                else if item.change01 > 0 { cell.textField?.textColor = Theme.color.goUp }
                else { cell.textField?.textColor = Theme.color.goNo }
            }
            
            if cellId == "textChange24" {
                cell.textField?.font = Theme.font.monodigits
                if item.change24 < 0 { cell.textField?.textColor = Theme.color.goDn }
                else if item.change24 > 0 { cell.textField?.textColor = Theme.color.goUp }
                else { cell.textField?.textColor = Theme.color.goNo }
            }
            
            return cell
        }
        
        return nil
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if let sel = tableView?.selectedRow {
            self.selected = sel
            tableSelection(sel)
        }
    }
    
    func selectFirstRow() {
        if let nrows = tableView?.numberOfRows, nrows > 0 {
            tableView?.selectRowIndexes([0], byExtendingSelection: false)
        }
    }
    
    
    func tableView(_ tableView: NSTableView, rowViewForRow row: Int) -> NSTableRowView? {
        return GreyRowView()
    }

    
}

class GreyRowView: NSTableRowView {
    override func drawSelection(in dirtyRect: NSRect) {
        NSColor(hex: 0x333333).setFill()
        NSRectFill(dirtyRect)
    }
}


// END
