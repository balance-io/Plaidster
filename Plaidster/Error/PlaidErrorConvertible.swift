//
//  PlaidErrorConvertible.swift
//  Plaidster
//
//  Created by Benjamin Baron on 4/13/16.
//  Copyright © 2016 Plaidster. All rights reserved.
//
//  Based on idea in this SO answer by orkoden: http://stackoverflow.com/a/33307946/299262

import Foundation

public protocol PlaidErrorConvertible {
    func errorDomain() -> String
    func errorCode() -> Int
    func errorUserInfo() -> Dictionary<String,String>?
}

public extension PlaidErrorConvertible {
    func cocoaError() -> NSError {
        return NSError(domain: errorDomain(), code: errorCode(), userInfo: errorUserInfo())
    }
}
