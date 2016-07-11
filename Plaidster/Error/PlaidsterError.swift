//
//  PlaidsterError.swift
//  Plaidster
//
//  Created by Willow Bellemore on 2016-01-17.
//  Copyright © 2016 Plaidster. All rights reserved.
//

import Foundation

public enum PlaidsterError: ErrorType, PlaidErrorConvertible {
    case JSONEncodingFailed
    case JSONDecodingFailed
    case JSONEmpty(String?)
    case UnknownException(exception: ErrorType)
    
    public func errorDomain() -> String {
        return "PlaidsterErrorDomain"
    }
    
    public func errorCode() -> Int {
        switch self {
        case .JSONEncodingFailed:   return 1
        case .JSONDecodingFailed:   return 2
        case .JSONEmpty:            return 3
        case .UnknownException:     return 4
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
        case .UnknownException(let exception):
            return "Unknown exception: \(exception)"
        }
    }
    
    public func errorUserInfo() -> Dictionary<String,String>? {
        return [NSLocalizedDescriptionKey: errorDescription()]
    }
}