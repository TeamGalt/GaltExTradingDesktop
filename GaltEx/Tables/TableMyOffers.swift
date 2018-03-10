//
//  TableMyOffers.swift
//  GaltEx
//
//  Created by Laptop on 3/9/18.
//  Copyright © 2018 GaltBank. All rights reserved.
//

import Cocoa
import Foundation
import StellarSDK


class TableMyOffers: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    
    struct TableMyOffersRow {
        let type       : OfferType
        let orderId    : Int
        let seller     : String
        let amount     : Double
        let price      : Double
        let baseCode   : String
        let baseType   : String
        let baseIssuer : String
        let cntrCode   : String
        let cntrType   : String
        let cntrIssuer : String
        let market     : String
    }
    
    
    var app = NSApp.delegate as! AppDelegate
    var list: [TableMyOffersRow] = [TableMyOffersRow]()
    var selected = 0
    var tableView: NSTableView?
    var tableSelection: (_ selected: Int) -> () = { index in }
    var tableCancelOffer: (_ id: Int) -> () = { id in }
    
    func assignTableView(_ tableView: NSTableView) {
        self.tableView = tableView
        self.tableView?.target     = self
        self.tableView?.delegate   = self
        self.tableView?.dataSource = self
        self.tableView?.font       = Theme.font.monodigits
        self.tableView?.action     = #selector(onItemClicked(_:))
    }
    
    func load(address: String, callback: @escaping Completion) {
        WebController.getMyOffers(address: address) { myoffers, error in
            if error != nil { callback(false); return }
            self.list = myoffers
            DispatchQueue.main.async {
                self.tableView?.reloadData()
                callback(true)
            }
        }
    }
    
    func onItemClicked(_ sender: Any) {
        guard let tableView = sender as? NSTableView else { print("No table"); return }
        let row = tableView.clickedRow
        let col = tableView.clickedColumn
        guard row >= 0 && row < self.list.count else { return }
        let cellId  = tableView.tableColumns[col].identifier
        let orderId = self.list[row].orderId

        if cellId == "textAction" {
            print("Cancel", orderId)
            tableCancelOffer(orderId)
        }
    }
    
    func getOfferAssets(_ orderId: Int) -> (Asset, Asset)? {
        print("Cancel", orderId)
        let item = self.list.first { $0.orderId == orderId }
        if item == nil { return nil }
        
        let buyingAsset: Asset?
        let sellingAsset: Asset?

        if item!.baseType == "native" {
            buyingAsset  = Asset.Native
            sellingAsset = Asset(assetCode: item!.cntrCode, issuer: item!.cntrIssuer)
        } else {
            buyingAsset  = Asset(assetCode: item!.baseCode, issuer: item!.baseIssuer)
            sellingAsset = Asset.Native
        }
        
        if buyingAsset == nil || sellingAsset == nil { return nil }
        
        return (buyingAsset!, sellingAsset!)
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
        case "textOrderId" : text = item.orderId.str; break
        case "textAmount"  : text = item.amount.money; break
        case "textBuying"  : text = (item.baseType == "native" ? "XLM" : item.baseCode); break
        case "textSelling" : text = (item.cntrType == "native" ? "XLM" : item.cntrCode); break
        case "textPrice"   : text = item.price.money; break
        case "textAction"  : text = "Cancel"; break  // Cancel only if logged in and not read only
        default            : text = "?"
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
