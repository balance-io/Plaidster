//
//  PlaidsterError.swift
//  Plaidster
//
//  Created by Willow Bellemore on 2016-01-17.
//  Copyright © 2016 Plaidster. All rights reserved.
//

import Foundation

func checkType<T, U>(value: T?, name: String, file: String = #file, line: Int = #line, function: String = #function) throws -> U {
    let fileName = NSURL(fileURLWithPath: file).URLByDeletingPathExtension?.lastPathComponent ?? file
    let functionName = function.componentsSeparatedByString("(").first ?? function
    
    guard let value = value else {
        let message = "[\(fileName):\(line) \(functionName) \"\(name)\"] Expected \(U.self), but value was nil"
        throw PlaidsterError.InvalidType(message)
    }
    
    guard let result = value as? U else {
        let message = "[\(fileName):\(line) \(functionName) \"\(name)\"] Expected \(U.self), but it was an \(value.dynamicType) with value: \(value)"
        throw PlaidsterError.InvalidType(message)
    }
    
    return result
}

func checkType<U>(dict: Dictionary<String, AnyObject>, file: String = #file, name: String, line: Int = #line, function: String = #function) throws -> U {
    let value = dict[name]
    return try checkType(value, name: name, file: file, line: line, function: function)
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
            if let message = message {
                return "JSON response empty: \(message)"
            } else {
                return "JSON response empty"
            }
        case .InvalidType(let exception):
            if let exception = exception {
                return "Invalid type: \(exception)"
            } else {
                return "Invalid type"
            }
        case .UnknownException(let exception):
            return "Unknown exception: \(exception)"
        }
    }
    
    public func errorUserInfo() -> Dictionary<String,String>? {
        return [NSLocalizedDescriptionKey: errorDescription()]
    }
}

extension PlaidsterError: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return errorDescription()
    }
    
    public var debugDescription: String {
        return errorDescription()
    }
}