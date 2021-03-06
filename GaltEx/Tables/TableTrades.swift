//
//  TableTrades.swift
//  GaltEx
//
//  Created by Laptop on 3/3/18.
//  Copyright © 2018 GaltBank. All rights reserved.
//

import Cocoa
import Foundation
import StellarSDK


class TableTrades: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    struct TableTradesRow {
        let type   : OfferType
        let time   : String
        let price  : Double
        let amount : Double
    }
    
    
    var app = NSApp.delegate as! AppDelegate
    var tableView: NSTableView?
    var tableSelection: (_ selected: Int) -> () = { index in }
    var list: [TableTradesRow] = [TableTradesRow]()
    var selected = 0
    
    func assignTableView(_ tableView: NSTableView) {
        self.tableView = tableView
        self.tableView?.target     = self
        self.tableView?.delegate   = self
        self.tableView?.dataSource = self
        self.tableView?.font       = Theme.font.monodigits
    }
    
    func load(symbol: String, isBase: Bool, callback: @escaping Completion) {
        WebController.getTradeHistory(symbol: symbol, isBase: isBase) { trades, error in
            if error != nil { callback(false); return }
            self.list = trades
            DispatchQueue.main.async {
                self.tableView?.reloadData()
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
        case "textTime"   : text = item.time; break
        case "textPrice"  : text = item.price.money; break
        case "textAmount" : text = item.amount.money; break
        default           : text = "?"
        }
        
        
        if let cell = tableView.make(withIdentifier: cellId, owner: self) as? NSTableCellView {
            cell.textField?.stringValue = text
            cell.textField?.font = Theme.font.monodigits
            
            if cellId == "textPrice" {
                if item.type == .ask { cell.textField?.textColor = Theme.color.goDn }
                else { cell.textField?.textColor = Theme.color.goUp }
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


// END
