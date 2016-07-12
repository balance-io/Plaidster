//
//  PlaidsterError.swift
//  Plaidster
//
//  Created by Willow Bellemore on 2016-01-17.
//  Copyright © 2016 Plaidster. All rights reserved.
//

import Foundation

func checkType<T, U>(value: T?, name: String) throws -> U {
    guard let value = value else {
        let message = "[\(name)] Expected \(U.self), but value was nil"
        throw PlaidsterError.InvalidType(message)
    }
    
    guard let result = value as? U else {
        let message = "[\(name)] Expected \(U.self), but it was an \(value.dynamicType) with value: \(value)"
        throw PlaidsterError.InvalidType(message)
    }
    
    return result
}

func checkType<U>(dictionary: Dictionary<String, Any>, name: String) throws -> U {
    let value = dictionary[name]
    return try checkType(value, name: name)
}

public enum PlaidsterError: ErrorType, PlaidErrorConvertible {
    case JSONEncodingFailed
    case JSONDecodingFailed
    case JSONEmpty(String?)
    case InvalidType(String?)
    case UnknownException(exception: ErrorType)
    
    public func errorDomain() -> String {
        return "PlaidsterErrorDomain"
    }
    
    public func errorCode() -> Int {
        switch self {
        case .JSONEncodingFailed:   return 1
        case .JSONDecodingFailed:   return 2
        case .JSONEmpty:            return 3
        case .InvalidType:          return 4
        case .UnknownException:     return Int.max
        }
    }
    
    public func errorDescription() -> String {
        switch self {
        case .JSONEncodingFailed:
            return "JSON encoding failed"
        case .JSONDecodingFailed:
            return "JSON decoding failed"
        case .JSONEmpty(let message):
            if message == nil {
                return "JSON response empty"
            } else {
                return "JSON response empty: \(message)"
            }
        case .InvalidType(let exception):
            return "Invalid type: \(exception)"
        case .UnknownException(let exception):
            return "Unknown exception: \(exception)"
        }
    }
    
    public func errorUserInfo() -> Dictionary<String,String>? {
        return [NSLocalizedDescriptionKey: errorDescription()]
    }
}