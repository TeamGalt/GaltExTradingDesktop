//
//  Storage.swift
//  GaltEx
//
//  Created by Laptop on 2/28/18.
//  Copyright © 2018 GaltBank. All rights reserved.
//

import Foundation

class Storage {
    
    struct AccountData {
        var publicKey = ""
        var secretKey = ""
        var network   = ""
        var account   = ""
        var isReadOnly: Bool { return secretKey.isEmpty }
    }
    
    var accounts: [AccountData] = []
    
    func loadAccounts(_ app: AppDelegate) {
        let defaults = UserDefaults.standard
        let numAccounts: Int = defaults.integer(forKey: "num-accounts")
        accounts.removeAll()
        
        if numAccounts < 1 { // Use test account ?
            return
        } else {
            var num = 0
            while let account: String = defaults.string(forKey: "account-"+num.str) {
                let parts = account.components(separatedBy: ":")
                if(parts.count==3){
                    accounts.append(AccountData(publicKey: parts[0], secretKey: "", network: parts[1], account: parts[2]))
                }
                num += 1
            }
        }
    }
    
    func saveAccounts() {
        clearAccounts()
        let defaults = UserDefaults.standard
        for (index, item) in accounts.enumerated() {
            let value = item.publicKey+":"+item.network+":"+item.account
            defaults.set(value, forKey: "account-"+index.str)
        }
        
        defaults.set(accounts.count, forKey: "num-accounts")
        defaults.synchronize()
    }
    
    func clearAccounts() {
        let defaults = UserDefaults.standard
        let dictionary = defaults.dictionaryRepresentation()
        dictionary.keys.forEach { key in
            defaults.removeObject(forKey: key)
        }
    }
    
    func removeAccount(_ key: String) {
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: key)
    }
    
    func printAccounts() {
        for (key, value) in UserDefaults.standard.dictionaryRepresentation() {
            print("\(key) = \(value)")
        }
    }
    
    
    //---- One account
    
    // let (account, secret, network, readonly) = loadAccount()
    static func loadAccount() -> (String, String, String, Bool) {
        let defaults = UserDefaults.standard
        let account  = defaults.string(forKey: "account") ?? ""
        var secret   = "" // Secret from keychain
        let network  = defaults.string(forKey: "network") ?? "TEST"
        let access   = defaults.bool(forKey: "access")
        let key10    = account.subtext(from: 0, to: 10)
        if access { secret = Keychain.load(key10) }
        let readOnly = secret.isEmpty
        return (account, secret, network, readOnly)
    }
    
    // saveAccount("GA23456789", "SA987...|EMPTY", "TEST|LIVE", true)
    static func saveAccount(publicKey: String, secretKey: String, network: String, readOnly: Bool) {
        let defaults = UserDefaults.standard
        let access   = !readOnly
        let key10    = publicKey.subtext(from: 0, to: 10)
        defaults.set(key10,   forKey: "account")
        defaults.set(network, forKey: "network")
        defaults.set(access,  forKey: "access")
        if !secretKey.isEmpty { Keychain.save(key10, secretKey) }
    }

    // clearAccount()
    static func clearAccount(_ publicKey: String) {
        let defaults = UserDefaults.standard
        let key10    = publicKey.subtext(from: 0, to: 10)
        defaults.set("",     forKey: "account")
        defaults.set("TEST", forKey: "network")
        defaults.set(false,  forKey: "access")
        Keychain.delete(key10)
    }

}

// END
