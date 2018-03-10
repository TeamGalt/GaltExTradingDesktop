//
//  Keychain.swift
//  GaltEx
//
//  Created by Laptop on 3/6/18.
//  Copyright © 2018 GaltBank. All rights reserved.
//

import Foundation
import Security

public class Keychain {
    static let prefix = "galtex.address:"
    
    // let ok = Keychain.save("GA23456789", "SA1234...")
    @discardableResult
    class func save(_ key: String, _ secret: String) -> Bool {
        guard let data = secret.data(using: .utf8) else { return false }
        let tag  = (prefix + key)
        let query: [String: Any] = [
            kSecClass       as String: kSecClassGenericPassword,
            kSecAttrAccount as String: tag,
            kSecValueData   as String: data ]
        
        SecItemDelete(query as CFDictionary)
        let status: OSStatus = SecItemAdd(query as CFDictionary, nil)
        
        return status == noErr
    }
    
    // let secretKey = Keychain.load("GA23456789")
    class func load(_ key: String) -> String {
        let tag = (prefix + key)
        let query: [String: Any] = [
            kSecClass       as String : kSecClassGenericPassword,
            kSecAttrAccount as String : tag,
            kSecReturnData  as String : kCFBooleanTrue,
            kSecMatchLimit  as String : kSecMatchLimitOne ]
        
        var dataTypeRef: CFTypeRef?
        let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)
        
        if status == noErr {
            let data = (dataTypeRef as! Data)
            return String(data: data, encoding: .utf8) ?? ""
        }
        
        return ""
    }
    
    // let ok = Keychain.delete("GA1234...")
    @discardableResult
    class func delete(_ key: String) -> Bool {
        let tag = prefix + key
        
        let query: [String: Any] = [
            kSecClass as String : kSecClassGenericPassword,
            kSecAttrAccount as String : tag
        ]
        
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        //print(status)
        
        //let errorMessage = SecCopyErrorMessageString(status, nil)
        //print(errorMessage ?? "Error ?")
        
        return status == noErr
    }
    
    // let ok = Keychain.clear() // clear all values
    @discardableResult
    class func clear() -> Bool {
        let query = [kSecClass as String: kSecClassGenericPassword]
        let status: OSStatus = SecItemDelete(query as CFDictionary)
        
        return status == noErr
    }
    
}

// END
