//
//  WebController.swift
//  GaltEx
//
//  Created by Laptop on 2/28/18.
//  Copyright © 2018 GaltBank. All rights reserved.
//

import Foundation

typealias Dixy = [String: Any?]
typealias WebResponse     = (Array<Any>?, Error?) -> Void
typealias WebResponseJson = (Dixy?, Error?) -> Void
typealias JsonResponse    = (Dixy, Error?) -> Void
typealias TickerResponse  = ([TableMarkets.TableMarketsRow], Error?) -> Void
typealias TradesResponse  = ([TableTrades.TableTradesRow], Error?) -> Void
typealias OffersResponse  = (TableOffers.Orderbook, Error?) -> Void
typealias ChartResponse   = (ChartLineData, Error?) -> Void

class WebController {
    private static let serverUrl = "https://horizon-testnet.stellar.org"
    private static let issuer    = "GBANKHXFXNOST75HZRTJGNJWB7QYQ6WWK3PVJKD6VD6ZXPCX3HNNTLLK"
    
    static func getTicker(callback: @escaping JsonResponse) {
        //let url = URL(string: "https://galtbank.com/galtex/data/ticker.json")!
        let url = URL(string: "http://localhost/~home/galtex/data/ticker.json")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { callback([:], error); return }
            let json = JSON.parse(data)
            callback(json, nil)
        }.resume()
    }


    static func getOrderbook(symbol: String, isBase: Bool, callback: @escaping OffersResponse) {
        let baseUrl = serverUrl + "/order_book?buying_asset_type=native&selling_asset_type=credit_alphanum4&selling_asset_code="+symbol+"&selling_asset_issuer="+issuer   // SYM/XLM
        let cntrUrl = serverUrl + "/order_book?buying_asset_type=credit_alphanum4&buying_asset_code="+symbol+"&buying_asset_issuer="+issuer+"&selling_asset_type=native"  // XLM/SYM
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
        let baseUrl = serverUrl + "/trades?base_asset_type=credit_alphanum4&base_asset_code="+symbol+"&base_asset_issuer="+issuer+"&counter_asset_type=native&order=desc&limit=20"
        let cntrUrl = serverUrl + "/trades?base_asset_type=native&counter_asset_type=credit_alphanum4&counter_asset_code="+symbol+"&counter_asset_issuer="+issuer+"&order=desc&limit=20"
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

/*
    static func getMyOrders(address: String, callback: @escaping WebResponse) {
        let uri = serverUrl + "/accounts/"+address+"/offers?order=desc&limit=20"
        let url = URL(string: uri)!
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            print(String(data: data!, encoding: .utf8)!)
            print(response ?? "?")
            print(error ?? "?")
            guard let data = data else { callback(nil, error); return }
            let json = JSON.parse(data)
            print(json["USD"] ?? "?")
            callback(json, nil)
        }.resume()
    }
 */

    static func getChartData(symbol: String, isBase: Bool, period: Int, callback: @escaping ChartResponse) {

        // This works for XLM/SYM, if asset is base use SYM/XLM
        var baseAssetType      = "native"
        var baseAssetCode      = "XLM"
        var baseAssetIssuer    = ""
        var counterAssetType   = "credit_alphanum4"
        let counterAssetCode   = symbol
        let counterAssetIssuer = issuer
        let resolution         = 3600000       // millis 300000|900000|3600000|86400000|604800000 = 5m 15min 1hr 1day 1week
        //var resolution       = chartTicks[state.period] // millis 300000|900000|3600000|86400000|604800000 = 5m 15min 1hr 1day 1week = 48 ticks x 4h 12h 2d 48d 336d
        var startTime          = Date.epoch24h
        let endTime            = Date().epoch  // 1512775500000
        let limit              = 100
        let order              = "asc"
        
        //let period = 1 // state.period
        switch(period){
        case 0:  startTime = Date.epoch04h; break
        case 1:  startTime = Date.epoch24h; break
        case 2:  startTime = Date.epoch07d; break
        case 3:  startTime = Date.epoch30d; break
        default: startTime = Date.epoch24h; break
        }
        
        startTime = Date.epoch07d  // Remove when enough data is available
        //print(startTime)
        
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
        
        //print("Chart url: ", uri)
        let url = URL(string: uri)!
        //let url = URL(string: "http://127.0.0.1/~home/galtex/data/info/chartdata.json")!
        //let url = URL(string: "http://localhost/~home/galtex/data/ticker.json")! // Candlestick lib not used
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            var chartData = ChartLineData()
            guard data != nil else { callback(chartData, error); return }
            //print(String(data: data!, encoding: .utf8) ?? "?")
            
            let json = JSON.parse(data!)
            guard let info = json["_embedded"] as? Dixy   else { print("embed"); callback(chartData, nil); return }
            guard let recs = info["records"]   as? ListMap else { print("recs"); callback(chartData, nil); return }
            
            chartData = ChartLineData(recs)
            //print("Chart data received "+chartData.lines.count.str+" rows")
            
            callback(chartData, nil)
        }.resume()
    }
}
