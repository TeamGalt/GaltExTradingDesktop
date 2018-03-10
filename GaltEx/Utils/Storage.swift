//
//  Storage.swift
//  GaltEx
//
//  Created by Laptop on 2/28/18.
//  Copyright © 2018 GaltBank. All rights reserved.
//

import Foundation

class Storage {
    
    struct Credentials {
        var publicKey = ""
        var secretKey = ""
        var network   = ""
        var isReadOnly: Bool { return secretKey.isEmpty }
    }
    
    //---- One account only
    
    // let credentials = loadAccount()
    static func loadAccount() -> Credentials {
        let defaults = UserDefaults.standard
        let account  = defaults.string(forKey: "account") ?? ""
        var secret   = "" // Secret from keychain
        let network  = defaults.string(forKey: "network") ?? "TEST"
        let access   = defaults.bool(forKey: "access")
        let key10    = account.subtext(from: 0, to: 10)
        if access { secret = Keychain.load(key10) }
        let credentials = Credentials(publicKey: account, secretKey: secret, network: network)
        return credentials
    }
    
    // saveAccount("GA23456789", "SA987...|EMPTY", "TEST|LIVE")
    static func saveAccount(publicKey: String, secretKey: String, network: String) {
        let defaults = UserDefaults.standard
        let access   = !secretKey.isEmpty
        let key10    = publicKey.subtext(from: 0, to: 10)
        defaults.set(publicKey, forKey: "account")
        defaults.set(network,   forKey: "network")
        defaults.set(access,    forKey: "access")
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
