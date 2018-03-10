//
//  ViewController.swift
//  GaltEx
//
//  Created by Laptop on 2/28/18.
//  Copyright © 2018 GaltBank. All rights reserved.
//

import Cocoa
import StellarSDK

struct GaltBank {
    static let live = "GBANK7OKSC2AVD6HQM65XRBHBH3F76PYDHJCWLVUDR5JBVWFGLVQMPZA"
    static let test = "GBANKHXFXNOST75HZRTJGNJWB7QYQ6WWK3PVJKD6VD6ZXPCX3HNNTLLK"
}

struct Session {
    var xlmPrice    = 0.0
    var galtPrice   = 0.0
    var account     = ""
    var secret      = ""
    var network     = StellarSDK.Horizon.Network.test
    var isReadOnly: Bool { return secret.isEmpty }
}

struct Market {
    var symbol       = "USD"
    var label        = "XLM:USD"
    var isBaseAsset  = false
    var baseAsset    = Asset.Native
    var counterAsset = Asset(assetCode: "USD", issuer: GaltBank.test)!
    var chartPeriod  = 2    // 0:04h 1:24h 2:07d 3:30d
    var issuer       = GaltBank.test
}

class ViewController: NSViewController, StockChartViewDelegate {

    var state  = Session()
    var market = Market()
    
    var marketsController  = TableMarkets()
    var tradesController   = TableTrades()
    var offersController   = TableOffers()
    var bidsController     = TableOffersBids()
    var asksController     = TableOffersAsks()
    var myOffersController = TableMyOffers()
    var chartController    = TableChart()
    
    @IBOutlet      var viewDesktop   : NSView!
    @IBOutlet weak var viewHead      : NSBox!
    @IBOutlet weak var viewIndices   : NSBox!
    @IBOutlet weak var viewMarkets   : NSBox!
    @IBOutlet weak var viewBid       : NSBox!
    @IBOutlet weak var viewAsk       : NSBox!
    @IBOutlet weak var viewChart     : NSBox!
    @IBOutlet weak var viewOrders    : NSBox!
    @IBOutlet weak var viewTrades    : NSBox!
    @IBOutlet weak var tabOrders     : NSTabView!
    
    @IBOutlet weak var statusBar     : NSView!
    @IBOutlet weak var statusBox     : NSBox!
    @IBOutlet weak var statusImage   : NSImageView!
    @IBOutlet weak var statusText    : NSTextField!
    
    @IBOutlet weak var tableMarkets  : NSTableView!
    @IBOutlet weak var tableBids     : NSTableView!
    @IBOutlet weak var tableAsks     : NSTableView!
    @IBOutlet weak var tableTrades   : NSTableView!
    @IBOutlet weak var tableMyOffers : NSTableView!
    
    @IBOutlet weak var textGaltPrice : NSTextField!
    @IBOutlet weak var textVolume    : NSTextField!
    @IBOutlet weak var textMarketCap : NSTextField!
    @IBOutlet weak var textChange01  : NSTextField!
    @IBOutlet weak var textChange24  : NSTextField!
    
    @IBOutlet weak var textBidPrice  : NSTextField!
    @IBOutlet weak var textBidAmount : NSTextField!
    @IBOutlet weak var textBidTotal  : NSTextField!
    @IBOutlet weak var textAskPrice  : NSTextField!
    @IBOutlet weak var textAskAmount : NSTextField!
    @IBOutlet weak var textAskTotal  : NSTextField!

    @IBOutlet weak var labelBid      : NSTextField!
    @IBOutlet weak var labelBidPrice : NSTextField!
    @IBOutlet weak var labelBidAmount: NSTextField!
    @IBOutlet weak var labelBidTotal : NSTextField!
    @IBOutlet weak var labelAsk      : NSTextField!
    @IBOutlet weak var labelAskPrice : NSTextField!
    @IBOutlet weak var labelAskAmount: NSTextField!
    @IBOutlet weak var labelAskTotal : NSTextField!
    @IBOutlet weak var labelChart    : NSTextField!
    
    @IBOutlet weak var labelOrderbook: TextClick!
    @IBOutlet weak var labelMyOrders : TextClick!

    @IBOutlet weak var buttonChart0  : NSButton!
    @IBOutlet weak var buttonChart1  : NSButton!
    @IBOutlet weak var buttonChart2  : NSButton!
    @IBOutlet weak var buttonChart3  : NSButton!
    
    @IBOutlet weak var buttonBid     : NSButton!
    @IBOutlet weak var buttonAsk     : NSButton!
    
    @IBOutlet weak var textLogin     : NSTextField!
    @IBOutlet weak var buttonLogin   : NSButton!
    
    @IBOutlet weak var chartView     : StockChartView!
    
    
    @IBAction func onClearKeychain(_ sender: NSMenuItem) {
        if !state.account.isEmpty {
            Storage.clearAccount(state.account)
            showStatus("Keychain cleared")
            logout()
        } else {
            showStatus("Nothing to clear")
        }
    }

    @IBAction func onLogin(_ sender: Any) {
        if !state.account.isEmpty { logout(); return }
        if textLogin.isHidden {
            textLogin.isHidden = false
            textLogin.becomeFirstResponder()
        } else {
            let net = (state.network == .live ? "LIVE" : "TEST")
            let key = textLogin.stringValue
            if key.isEmpty {
                textLogin.isHidden = true
                return
            }
            if key.characters.count == 56 {
                if key.hasPrefix("G") {
                    state.account = key
                    state.secret = ""    // if publickey, account is read only
                    Storage.saveAccount(publicKey: key, secretKey: "", network: net)
                    showStatus("Logged in read-only mode. Welcome!")
                    loadMyOffersData(key)
                    buttonLoginON()
                } else if key.hasPrefix("S") {
                    if let account = StellarSDK.Account.fromSecret(key) {
                        let pubkey = account.publicKey
                        let secret = account.secretKey
                        state.account = pubkey
                        state.secret  = secret   // if secretkey, account can trade
                        Storage.saveAccount(publicKey: pubkey, secretKey: secret, network: net)
                        showStatus("Logged in. Welcome!")
                        loadMyOffersData(pubkey)
                        buttonLoginON()
                    } else {
                        showWarning("Invalid secret key!")
                        buttonLoginOFF()
                    }
                }
                textLogin.isHidden = true
            } else {
                showWarning("Invalid key!")
                buttonLoginOFF()
            }
        }
    }
    
    @IBAction func onOfferBid(_ sender: Any) {
        offerBid()
    }
    
    @IBAction func onOfferAsk(_ sender: Any) {
        offerAsk()
    }
    
    @IBAction func onChart0(_ sender: Any) {
        chartButton(0)
    }
    
    @IBAction func onChart1(_ sender: Any) {
        chartButton(1)
    }
    
    @IBAction func onChart2(_ sender: Any) {
        chartButton(2)
    }
    
    @IBAction func onChart3(_ sender: Any) {
        chartButton(3)
    }
    
    @IBAction func onOrderbook(_ sender: Any) {
        labelMyOrders.textColor  = Theme.color.labelOff
        labelOrderbook.textColor = Theme.color.labelNormal
        tabOrders.selectTabViewItem(at: 0)
    }
    
    @IBAction func onMyOrders(_ sender: Any) {
        labelOrderbook.textColor = Theme.color.labelOff
        labelMyOrders.textColor  = Theme.color.labelNormal
        tabOrders.selectTabViewItem(at: 1)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewDidAppear() {
        initialize()
        main()
    }

    func initialize() {
        darkTheme()
        loadCredentials()
    }
    
    func loadCredentials() {
        let credentials = Storage.loadAccount()
        state.account   = credentials.publicKey
        state.secret    = credentials.secretKey
        if !state.account.isEmpty { buttonLoginON() }
    }
    
    func logout() {
        Storage.clearAccount(state.account)
        state.account    = ""
        state.secret     = ""
        showStatus("Logged out. Goodbye!")
        buttonLoginOFF()
    }
    
    func main() {
        if state.network == .live {
            showStatus("Ready")
        } else {
            showStatus("Ready on TEST network")
        }
        
        chartView.setup()
        chartView.delegate = self
        buttonChart2.state = 1
            
        marketsController.assignTableView(tableMarkets)
        tradesController.assignTableView(tableTrades)
        bidsController.assignTableView(tableBids)
        asksController.assignTableView(tableAsks)
        myOffersController.assignTableView(tableMyOffers)
        myOffersController.tableCancelOffer = offerCancel
        
        // Initial load
        marketsController.tableSelection = onMarketSelect
        marketsController.load { ok in
            self.state.xlmPrice = self.marketsController.xlmPrice
            self.calcIndices()
            self.loadGaltPrice()
            self.loadTables(symbol: self.market.symbol, isBase: self.market.isBaseAsset, period: self.market.chartPeriod)
            if !self.state.account.isEmpty { self.loadMyOffersData(self.state.account) }
        }
    }
    
    func onMarketSelect(_ index: Int) {
        guard index >= 0 && index < marketsController.list.count else { return }
        market.symbol = marketsController.list[index].symbol
        setMarketLabels(market.symbol, market.isBaseAsset)
        setMarketAssets(market.symbol, market.isBaseAsset)
        loadTables(symbol: market.symbol, isBase: market.isBaseAsset, period: market.chartPeriod)
    }
    
    func setMarketLabels(_ symbol: String, _ isBase: Bool) {
        let labelBase = isBase ? symbol : "XLM"
        let labelCntr = isBase ? "XLM"  : symbol
        market.label  = isBase ? (symbol + ":XLM") : ("XLM:" + symbol)
        labelBid.stringValue       = market.label
        labelBidPrice.stringValue  = "Price "  + labelCntr
        labelBidAmount.stringValue = "Amount " + labelBase
        labelBidTotal.stringValue  = "Total "  + labelCntr
        labelAsk.stringValue       = market.label
        labelAskPrice.stringValue  = "Price "  + labelCntr
        labelAskAmount.stringValue = "Amount " + labelBase
        labelAskTotal.stringValue  = "Total "  + labelCntr
        labelChart.stringValue     = market.label
    }

    func setMarketAssets(_ symbol: String, _ isBase: Bool) {
        if isBase {
            market.baseAsset    = Asset(assetCode: symbol, issuer: market.issuer)!
            market.counterAsset = Asset.Native
        } else {
            market.baseAsset    = Asset.Native
            market.counterAsset = Asset(assetCode: symbol, issuer: market.issuer)!
        }
    }
    
    func loadTables(symbol: String, isBase: Bool, period: Int) {
        setMarketLabels(symbol, isBase)
        loadTradesData(symbol: symbol, isBase: isBase)
        loadOffersData(symbol: symbol, isBase: isBase)
        loadChartData(symbol: symbol, isBase: isBase, period: period)
    }

    func loadTradesData(symbol: String, isBase: Bool) {
        tradesController.load(symbol: symbol, isBase: isBase) { ok in }
    }
    
    func loadOffersData(symbol: String, isBase: Bool) {
        offersController.load(symbol: symbol, isBase: isBase) { ok in
            if ok {
                // Load offer tables
                self.bidsController.load(self.offersController.orderbook.bids)
                self.asksController.load(self.offersController.orderbook.asks)
                // Assign bid/ask prices
                DispatchQueue.main.async {
                    self.textBidPrice.stringValue = self.offersController.orderbook.asks[0].price.money
                    self.textAskPrice.stringValue = self.offersController.orderbook.bids[0].price.money
                }
            }
        }
    }
    
    func loadMyOffersData(_ address: String) {
        myOffersController.load(address: address) { ok in }
    }
    
    func loadChartData(symbol: String, isBase: Bool, period: Int) {
        chartController.load(symbol: symbol, isBase: isBase, period: period) { ok in
            DispatchQueue.main.async {
                self.chartView.dataSource = self.chartController.list.lines
                self.chartView.show()
            }
        }
    }
    
    func loadGaltPrice() {
        WebController.getGaltPrice { price in
            DispatchQueue.main.async {
                self.state.galtPrice = price * self.state.xlmPrice
                self.textGaltPrice.stringValue = "GALT " + self.state.galtPrice.toMoney(4)
            }
        }
    }
    
    func calcIndices() {
        var totVolume    = 0.0
        var totMarketCap = 0.0
        var totChange01  = 0.0
        var totChange24  = 0.0
        
        for item in marketsController.list {
            totVolume    += item.volume;
            totMarketCap += item.marketCap
            totChange01  += item.change01
            totChange24  += item.change24
        }
        
        let n: Double = Double(marketsController.list.count)
        textVolume.stringValue    = "⩙\(totVolume.toMoney(0))"
        textMarketCap.stringValue = "⩙\((totMarketCap/1000000).toMoney(0)) M"
        textChange01.stringValue  = "\((totChange01/n).toMoney(2))%"
        textChange24.stringValue  = "\((totChange24/n).toMoney(2))%"
    }
    
    override func controlTextDidChange(_ obj: Notification) {
        let textField = obj.object as! NSTextField
        let newValue  = textField.doubleValue
        let bidPrice  = textBidPrice.doubleValue
        var bidAmount = textBidAmount.doubleValue 
        var bidTotal  = textBidTotal.doubleValue
        let askPrice  = textAskPrice.doubleValue
        var askAmount = textAskAmount.doubleValue
        var askTotal  = textAskTotal.doubleValue
        
        switch textField.identifier! {
        case "textBidPrice"  : bidTotal  = newValue * bidAmount; textBidTotal.stringValue  = bidTotal.money; break
        case "textBidAmount" : bidTotal  = newValue * bidPrice;  textBidTotal.stringValue  = bidTotal.money; break
        case "textBidTotal"  : bidAmount = newValue * bidPrice;  textBidAmount.stringValue = bidAmount.money; break
        case "textAskPrice"  : askTotal  = newValue * askAmount; textAskTotal.stringValue  = askTotal.money; break
        case "textAskAmount" : askTotal  = newValue * askPrice;  textAskTotal.stringValue  = askTotal.money; break
        case "textAskTotal"  : askAmount = newValue * askPrice;  textAskAmount.stringValue = askAmount.money; break
        default: break
        }
    }

    func offerBid() {
        if state.isReadOnly { showWarning("Must be logged in to make offers"); return }
        showStatus("Making offer, please wait...")
        
        let bidAmount = textBidAmount.doubleValue
        let bidPrice  = textBidPrice.doubleValue
        
        guard bidAmount > 0 else { showWarning("Amount must be greater tan zero"); return }
        guard bidPrice  > 0 else { showWarning("Price must be greater tan zero");  return }

        let amount    = bidAmount * bidPrice
        let price     = StellarSDK.Utils.rationalPrice(bidPrice, reversed: true)
        print(price)
        
        
        buttonBid.isEnabled = false
        let account = StellarSDK.Account.fromSecret(state.secret)
        account?.manageOffer(offerId: 0, buying: market.baseAsset, selling: market.counterAsset, amount: amount, price: price) { response in
            DispatchQueue.main.async {
                self.buttonBid.isEnabled = true
                if response.error {
                    self.showWarning("Error making offer, try again later. " + response.message)
                } else {
                    self.showStatus("Bid offer has been made")
                    self.loadTables(symbol: self.market.symbol, isBase: self.market.isBaseAsset, period: self.market.chartPeriod)
                }
            }
        }
    }
    
    func offerAsk() {
        if state.isReadOnly { showWarning("Must be logged in to make offers"); return }
        showStatus("Making offer, please wait...")
        
        let askAmount = textAskAmount.doubleValue
        let askPrice  = textAskPrice.doubleValue
        let amount    = askAmount
        let price     = StellarSDK.Utils.rationalPrice(askPrice)
        
        buttonAsk.isEnabled = false
        let account = StellarSDK.Account.fromSecret(state.secret)
        account?.manageOffer(offerId: 0, buying: market.counterAsset, selling: market.baseAsset, amount: amount, price: price) { response in
            DispatchQueue.main.async {
                self.buttonAsk.isEnabled = true
                if response.error {
                    self.showWarning("Error making offer, try again later. " + response.message)
                } else {
                    self.showStatus("Ask offer has been made")
                    self.loadTables(symbol: self.market.symbol, isBase: self.market.isBaseAsset, period: self.market.chartPeriod)
                }
            }
        }
    }
    
    func offerCancel(_ offerId: Int) {
        if state.isReadOnly { showWarning("Must be logged in to cancel offers"); return }
        showStatus("Cancelling offer \(offerId), please wait...")
        
        guard let (buyingAsset, sellingAsset) = myOffersController.getOfferAssets(offerId) else {
            showStatus("No assets in offer")
            return
        }
        
        let account = StellarSDK.Account.fromSecret(state.secret)
        
        account?.manageOffer(offerId: offerId, buying: buyingAsset, selling: sellingAsset, amount: 0, price: StellarSDK.Utils.rationalPrice(1.0)) { response in
            DispatchQueue.main.async {
                if response.error {
                    self.showWarning("Error cancelling offer, try again later. " + response.message)
                } else {
                    self.showStatus("Offer has been cancelled")
                    self.loadTables(symbol: self.market.symbol, isBase: self.market.isBaseAsset, period: self.market.chartPeriod)
                    self.loadMyOffersData(self.state.account)
                }
            }
        }
    }
    
    func darkTheme() {
        if let window = self.view.window {
            window.appearance = Theme.dark
        }

        viewDesktop.layer?.backgroundColor              = Theme.color.backLight.cgColor
        viewHead.contentView?.layer?.backgroundColor    = Theme.color.backDark.cgColor
        viewIndices.contentView?.layer?.backgroundColor = Theme.color.backDark.cgColor
        viewMarkets.contentView?.layer?.backgroundColor = Theme.color.backDark.cgColor
        viewBid.contentView?.layer?.backgroundColor     = Theme.color.backDark.cgColor
        viewAsk.contentView?.layer?.backgroundColor     = Theme.color.backDark.cgColor
        viewChart.contentView?.layer?.backgroundColor   = Theme.color.backDark.cgColor
        viewOrders.contentView?.layer?.backgroundColor  = Theme.color.backDark.cgColor
        viewTrades.contentView?.layer?.backgroundColor  = Theme.color.backDark.cgColor
        statusBox.contentView?.layer?.backgroundColor   = Theme.color.backDark.cgColor
        
        tableMarkets.backgroundColor  = NSColor.clear
        tableBids.backgroundColor     = NSColor.clear
        tableAsks.backgroundColor     = NSColor.clear
        tableTrades.backgroundColor   = NSColor.clear
        tableMyOffers.backgroundColor = NSColor.clear
        
        textBidPrice.backgroundColor  = Theme.color.backDark
        textBidAmount.backgroundColor = Theme.color.backDark
        textBidTotal.backgroundColor  = Theme.color.backDark
        textAskPrice.backgroundColor  = Theme.color.backDark
        textAskAmount.backgroundColor = Theme.color.backDark
        textAskTotal.backgroundColor  = Theme.color.backDark
        textLogin.backgroundColor     = Theme.color.backDark
        
        textBidPrice.layer?.borderColor  = NSColor.red.cgColor
        textBidAmount.layer?.borderColor = Theme.color.backLight.cgColor
        textBidTotal.layer?.borderColor  = Theme.color.backLight.cgColor
        textAskPrice.layer?.borderColor  = Theme.color.backLight.cgColor
        textAskAmount.layer?.borderColor = Theme.color.backLight.cgColor
        textAskTotal.layer?.borderColor  = Theme.color.backLight.cgColor
        textLogin.layer?.borderColor     = Theme.color.backLight.cgColor
        
        
        // Buttons
        let style = NSMutableParagraphStyle()
        style.alignment = .center
        
        buttonChart0.attributedTitle = NSAttributedString(string: "4 Hours",  attributes: [NSForegroundColorAttributeName: NSColor.white, NSParagraphStyleAttributeName: style])
        buttonChart1.attributedTitle = NSAttributedString(string: "24 Hours", attributes: [NSForegroundColorAttributeName: NSColor.white, NSParagraphStyleAttributeName: style])
        buttonChart2.attributedTitle = NSAttributedString(string: "7 Days",   attributes: [NSForegroundColorAttributeName: NSColor.white, NSParagraphStyleAttributeName: style])
        buttonChart3.attributedTitle = NSAttributedString(string: "1 Month",  attributes: [NSForegroundColorAttributeName: NSColor.white, NSParagraphStyleAttributeName: style])
        
        buttonBid.attributedTitle = NSAttributedString(string: "Buy",  attributes: [NSForegroundColorAttributeName: NSColor(hex: 0x00DD00), NSParagraphStyleAttributeName: style])
        buttonAsk.attributedTitle = NSAttributedString(string: "Sell", attributes: [NSForegroundColorAttributeName: NSColor(hex: 0xDD0000), NSParagraphStyleAttributeName: style])
    }
    
    func showStatus(_ text: String) {
        statusText.stringValue = text
        statusImage.image = NSImage(named: NSImageNameStatusAvailable)
    }

    func showWarning(_ text: String) {
        statusText.stringValue = text
        statusImage.image = NSImage(named: NSImageNameStatusUnavailable)
    }
    
    func chartButton(_ n: Int) {
        market.chartPeriod = n
        buttonChart0.state = (n==0 ? 1 : 0)
        buttonChart1.state = (n==1 ? 1 : 0)
        buttonChart2.state = (n==2 ? 1 : 0)
        buttonChart3.state = (n==3 ? 1 : 0)
        loadChartData(symbol: market.symbol, isBase: market.isBaseAsset, period: market.chartPeriod)
    }
    
    func buttonLoginON()  { buttonLogin.image = NSImage(named: "icon-key-on")  }
    func buttonLoginOFF() { buttonLogin.image = NSImage(named: "icon-key-off") }
}

// END
