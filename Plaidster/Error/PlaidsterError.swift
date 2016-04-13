//
//  PlaidsterError.swift
//  Plaidster
//
//  Created by Willow Bumby on 2016-01-17.
//  Copyright © 2016 Willow Bumby. All rights reserved.
//

import Foundation

public enum PlaidsterError: ErrorType, PlaidErrorConvertible {
    case JSONEncodingFailed
    case JSONDecodingFailed
    case JSONEmpty
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
        case .JSONEmpty:
            return "JSON response empty"
        case .UnknownException(let exception):
            return "Unknown exception: \(exception)"
        }
    }
    
    public func errorUserInfo() -> Dictionary<String,String>? {
        return [NSLocalizedDescriptionKey: errorDescription()]
    }
}