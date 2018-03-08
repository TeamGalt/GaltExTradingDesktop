//
//  Types.swift
//  GaltEx
//
//  Created by Laptop on 3/3/18.
//  Copyright © 2018 GaltBank. All rights reserved.
//

import Foundation


typealias Completion = (Bool) -> Void

enum OfferType {
    case ask
    case bid
}

enum PriceChange {
    case none
    case up
    case down
}
