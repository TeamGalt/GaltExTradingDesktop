//
//  WebController.swift
//  GaltEx
//
//  Created by Laptop on 2/28/18.
//  Copyright © 2018 GaltBank. All rights reserved.
//

import Foundation

typealias Dixy = [String: Any?]
typealias WebResponse      = (Array<Any>?, Error?) -> Void
typealias WebResponseJson  = (Dixy?, Error?) -> Void
typealias JsonResponse     = (Dixy, Error?) -> Void
typealias GaltResponse     = (Double) -> Void
typealias TickerResponse   = ([TableMarkets.TableMarketsRow], Error?) -> Void
typealias TradesResponse   = ([TableTrades.TableTradesRow], Error?) -> Void
typealias MyOffersResponse = ([TableMyOffers.TableMyOffersRow], Error?) -> Void
typealias OffersResponse   = (TableOffers.Orderbook, Error?) -> Void
typealias ChartResponse    = (ChartLineData, Error?) -> Void

class WebController {
    private static let serverUrl = "https://horizon-testnet.stellar.org"
    private static let issuer    = "GBANKHXFXNOST75HZRTJGNJWB7QYQ6WWK3PVJKD6VD6ZXPCX3HNNTLLK"
    
    static func getTicker(callback: @escaping JsonResponse) {
        let url = URL(string: "https://galtbank.com/galtex/data/ticker.json")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { callback([:], error); return }
            let json = JSON.parse(data)
            callback(json, nil)
        }.resume()
    }

    static func getOrderbook(symbol: String, isBase: Bool, callback: @escaping OffersResponse) {
        let baseUrl = serverUrl + "/order_book?buying_asset_type=native&selling_asset_type=credit_alphanum4&selling_asset_code="+symbol+"&selling_asset_issuer="+issuer+"&limit=30"   // SYM/XLM
        let cntrUrl = serverUrl + "/order_book?buying_asset_type=credit_alphanum4&buying_asset_code="+symbol+"&buying_asset_issuer="+issuer+"&selling_asset_type=native&limit=30"     // XLM/SYM
        let uri = (isBase ? baseUrl : cntrUrl)
        let url = URL(string: uri)!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { callback(TableOffers.Orderbook(), error); return }
            let json = JSON.parse(data)
            let book = TableOffers.Orderbook(json: json)
            callback(book, nil)
        }.resume()
    }

    static func getTradeHistory(symbol: String, isBase: Bool, callback: @escaping TradesResponse) {
        let baseUrl = serverUrl + "/trades?base_asset_type=credit_alphanum4&base_asset_code="+symbol+"&base_asset_issuer="+issuer+"&counter_asset_type=native&order=desc&limit=30"
        let cntrUrl = serverUrl + "/trades?base_asset_type=native&counter_asset_type=credit_alphanum4&counter_asset_code="+symbol+"&counter_asset_issuer="+issuer+"&order=desc&limit=30"
        let uri = (isBase ? baseUrl : cntrUrl)
        let url = URL(string: uri)!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { callback([], error); return }
            let json = JSON.parse(data)
            var list: [TableTrades.TableTradesRow] = []
            guard let info = json["_embedded"] as? Dixy   else { print("embed"); callback(list, nil); return }
            guard let recs = info["records"]   as? [Dixy] else { print("recs"); callback(list, nil); return }
            
            for item in recs {
                let baseAmount = item.dbl("base_amount")
                let cntrAmount = item.dbl("counter_amount")
                let time   = item.str("ledger_close_time", "0").dateISO.time
                let price  = baseAmount > 0 ? cntrAmount / baseAmount : 0.0
                let amount = baseAmount
                let base   = item.int("base_is_seller")
                var type   = OfferType.ask
                if base == 1 { type = OfferType.bid }
                let row = TableTrades.TableTradesRow(type: type, time: time, price: price, amount: amount)
                list.append(row)
            }
            callback(list, nil)
        }.resume()
    }

    static func getMyOffers(address: String, callback: @escaping MyOffersResponse) {
        let uri = serverUrl + "/accounts/"+address+"/offers?order=desc&limit=20"
        let url = URL(string: uri)!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { callback([], error); return }
            let json = JSON.parse(data)
            var list: [TableMyOffers.TableMyOffersRow] = []
            guard let info = json["_embedded"] as? Dixy   else { print("embed"); callback(list, nil); return }
            guard let recs = info["records"]   as? [Dixy] else { print("recs"); callback(list, nil); return }
            
            for item in recs {
                let orderId    = item.int("id")
                let seller     = item.str("seller")
                let amount     = item.dbl("amount")
                let price      = item.dbl("price")
                let buying     = item["buying"]  as! Dixy
                let selling    = item["selling"] as! Dixy
                let baseCode   = buying.str("asset_code")
                let baseType   = buying.str("asset_type")
                let baseIssuer = buying.str("asset_issuer")
                let cntrCode   = selling.str("asset_code")
                let cntrType   = selling.str("asset_type")
                let cntrIssuer = selling.str("asset_issuer")
                let market     = baseCode+":"+cntrCode
                let type       = baseType == "native" ? OfferType.bid : OfferType.ask
                let row        = TableMyOffers.TableMyOffersRow(
                    type: type,
                    orderId: orderId,
                    seller: seller,
                    amount: amount,
                    price: price,
                    baseCode: baseCode,
                    baseType: baseType,
                    baseIssuer: baseIssuer,
                    cntrCode: cntrCode,
                    cntrType: cntrType,
                    cntrIssuer: cntrIssuer,
                    market: market
                )
                list.append(row)
            }
            callback(list, nil)
        }.resume()
    }

    static func getChartData(symbol: String, isBase: Bool, period: Int, callback: @escaping ChartResponse) {
        let ChartTicks = [300000, 900000, 3600000, 86400000, 604800000]  // 5m 15m 1h 1d 1w = 48 ticks x 4h 12h 48h 48d 336d
        
        // TODO: Get latest ticks for a week ordered desc, then get the top 48 and reorder asc
        
        var baseAssetType      = "native"
        var baseAssetCode      = "XLM"
        var baseAssetIssuer    = ""
        var counterAssetType   = "credit_alphanum4"
        let counterAssetCode   = symbol
        let counterAssetIssuer = issuer
        //let resolution       = 3600000  // millis 300000|900000|3600000|86400000|604800000
        let resolution         = ChartTicks[period]
        var startTime          = Date.epoch24h
        let endTime            = Date().epoch
        let limit              = 100
        let order              = "desc"
        
        //let period = 1 // state.period
        switch(period){
        case 0:  startTime = Date.epoch04h; break //  5m x  4h =  48 ticks
        case 1:  startTime = Date.epoch24h; break // 15m x 24h =  96 ticks  | 12h = 48 ticks
        case 2:  startTime = Date.epoch07d; break //  1h x  7d = 168 ticks  | 48h = 48 ticks
        case 3:  startTime = Date.epoch30d; break //  1d x 30d =  30 ticks  | 48d = 48 ticks
        default: startTime = Date.epoch24h; break
        }
        
        startTime = Date.epoch07d  // TODO: Remove when enough data is available
        
        var uri = serverUrl+"/trade_aggregations?"
        uri += "base_asset_type="+baseAssetType
        uri += "&counter_asset_type="+counterAssetType
        uri += "&counter_asset_code="+counterAssetCode
        uri += "&counter_asset_issuer="+counterAssetIssuer
        uri += "&start_time="+startTime.str
        uri += "&end_time="+endTime.str
        uri += "&resolution="+resolution.str
        uri += "&limit="+limit.str
        uri += "&order="+order

        if(isBase){
            baseAssetType    = "credit_alphanum4"
            baseAssetCode    = symbol
            baseAssetIssuer  = issuer
            counterAssetType = "native"

            uri  = serverUrl+"/trade_aggregations?"
            uri += "base_asset_type="+baseAssetType
            uri += "&base_asset_code="+baseAssetCode
            uri += "&base_asset_issuer="+baseAssetIssuer
            uri += "&counter_asset_type="+counterAssetType
            uri += "&start_time="+startTime.str
            uri += "&end_time="+endTime.str
            uri += "&resolution="+resolution.str
            uri += "&limit="+limit.str
            uri += "&order="+order
        }
        
        let url = URL(string: uri)!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            var chartData = ChartLineData()
            guard data != nil else { callback(chartData, error); return }
            
            let json = JSON.parse(data!)
            guard let info = json["_embedded"] as? Dixy   else { print("embed"); callback(chartData, nil); return }
            guard let recs = info["records"]   as? ListMap else { print("recs"); callback(chartData, nil); return }
            
            var ticks = ListMap()
            var n = 0
            for item in recs.reversed() {
                ticks.append(item)
                n += 1
                //if n > 48 { break }
            }
            
            chartData = ChartLineData(ticks)
            callback(chartData, nil)
        }.resume()
    }
    
    static func getGaltPrice(callback: @escaping GaltResponse) {
        //let isBase  = true  // true 0.05 | false 1/0.05
        let symbol  = "GALT"
        let baseUrl = serverUrl + "/order_book?buying_asset_type=native&selling_asset_type=credit_alphanum4&selling_asset_code="+symbol+"&selling_asset_issuer="+issuer   // SYM/XLM
        //let cntrUrl = serverUrl + "/order_book?buying_asset_type=credit_alphanum4&buying_asset_code="+symbol+"&buying_asset_issuer="+issuer+"&selling_asset_type=native"  // XLM/SYM
        //let uri = (isBase ? baseUrl : cntrUrl)
        let url = URL(string: baseUrl)!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { callback(0.0); return }
            let json  = JSON.parse(data)
            let book  = TableOffers.Orderbook(json: json)
            var price = 0.0
            if book.asks.count > 0 {
                price = book.asks[0].price
            }
            callback(price)
        }.resume()
    }

}

// END
