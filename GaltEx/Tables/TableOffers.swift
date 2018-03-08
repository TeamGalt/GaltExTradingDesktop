//
//  TableOrders.swift
//  GaltEx
//
//  Created by Laptop on 3/3/18.
//  Copyright © 2018 GaltBank. All rights reserved.
//

import Cocoa
import Foundation
import StellarSDK


class TableOffers: NSObject {
    
    var orderbook = Orderbook()
    
    struct Orderbook {
        var bids: [TableOffersBids.TableBidsRow]
        var asks: [TableOffersAsks.TableAsksRow]
        
        init() {
            bids = []
            asks = []
        }
        
        init(json: Dixy) {
            self.init()
            if let bids = json["bids"] as? [Dixy] {
                var total = 0.0
                for item in bids {
                    let price  = item.dbl("price")
                    let bid    = item.dbl("amount")
                    let amount = price > 0 ? bid / price : 0.0
                    total += amount
                    let row = TableOffersBids.TableBidsRow(price: price, amount: amount, total: total)
                    self.bids.append(row)
                }
            }
            
            if let asks = json["asks"] as? [Dixy] {
                var total = 0.0
                for item in asks {
                    let price  = item.dbl("price")
                    let amount = item.dbl("amount")
                    total += amount
                    let row = TableOffersAsks.TableAsksRow(price: price, amount: amount, total: total)
                    self.asks.append(row)
                }
            }

        }
    }
    
    func load(symbol: String, isBase: Bool, callback: @escaping Completion) {
        WebController.getOrderbook(symbol: symbol, isBase: isBase) { book, error in
            if error != nil { callback(false); return }
            self.orderbook = book
            callback(true)
        }
    }

}
