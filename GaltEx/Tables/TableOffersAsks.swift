//
//  TableOffersAsks.swift
//  GaltEx
//
//  Created by Laptop on 3/2/18.
//  Copyright © 2018 GaltBank. All rights reserved.
//

import Cocoa
import Foundation
import StellarSDK


class TableOffersAsks: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    struct TableAsksRow {
        let price  : Double
        let amount : Double
        let total  : Double
    }

    var app = NSApp.delegate as! AppDelegate
    var tableView: NSTableView?
    var tableSelection: (_ selected: Int) -> () = { index in }
    var list: [TableAsksRow] = [TableAsksRow]()
    var selected = 0
    
    func assignTableView(_ tableView: NSTableView) {
        self.tableView = tableView
        self.tableView?.target     = self
        self.tableView?.delegate   = self
        self.tableView?.dataSource = self
        self.tableView?.font       = Theme.font.monodigits
    }
    
    func load(_ asks: [TableAsksRow]) {
        list = asks
        DispatchQueue.main.async {
            self.tableView?.reloadData()
        }
    }

    /*
    func loadData(_ asks: [Dixy]) {
        list = [TableAsksRow]()
        var total: Double = 0.0
        for dixy in asks {
            let price  = Double(dixy["price"]  as? String ?? "0.0") ?? 0.0
            let amount = Double(dixy["amount"] as? String ?? "0.0") ?? 0.0
            total += amount
            list.append(TableAsksRow(price: price, amount: amount, total: total))
        }
        
        tableView?.reloadData()
    }
    */

    func numberOfRows(in tableView: NSTableView) -> Int {
        return list.count
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let column = tableColumn else { return nil }
        
        let item = list[row]
        let cellId = column.identifier
        
        var text = ""
        
        switch cellId {
        case "textTotal"  : text = item.total.money; break
        case "textAmount" : text = item.amount.money; break
        case "textPrice"  : text = item.price.money; break
        default           : text = "?"
        }
        
        
        if let cell = tableView.make(withIdentifier: cellId, owner: self) as? NSTableCellView {
            cell.textField?.stringValue = text
            cell.textField?.font = Theme.font.monodigits
            
            if cellId == "textPrice" {
                cell.textField?.textColor = Theme.color.goDn
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
