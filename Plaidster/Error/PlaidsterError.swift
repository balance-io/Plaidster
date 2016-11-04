//
//  PlaidsterError.swift
//  Plaidster
//
//  Created by Willow Bellemore on 2016-01-17.
//  Copyright © 2016 Plaidster. All rights reserved.
//

import Foundation

func checkType<T, U>(_ value: T?, name: String, file: String = #file, line: Int = #line, function: String = #function) throws -> U {
    let fileName = NSURL(fileURLWithPath: file).deletingPathExtension?.lastPathComponent ?? file
    let functionName = function.components(separatedBy: "(").first ?? function
    
    guard let value = value else {
        let message = "[\(fileName):\(line) \(functionName) \"\(name)\"] Expected \(U.self), but value was nil"
        throw PlaidsterError.invalidType(message)
    }
    
    guard let result = value as? U else {
        let message = "[\(fileName):\(line) \(functionName) \"\(name)\"] Expected \(U.self), but it was an \(type(of: value)) with value: \(value)"
        throw PlaidsterError.invalidType(message)
    }
    
    return result
}

func checkType<U>(_ dict: Dictionary<String, AnyObject>, file: String = #file, name: String, line: Int = #line, function: String = #function) throws -> U {
    let value = dict[name]
    return try checkType(value, name: name, file: file, line: line, function: function)
}

public enum PlaidsterError: Error, PlaidErrorConvertible {
    case jsonEncodingFailed
    case jsonDecodingFailed
    case jsonEmpty(String?)
    case invalidType(String?)
    case unknownException(exception: Error)
    
    public func errorDomain() -> String {
        return "PlaidsterErrorDomain"
    }
    
    public func errorCode() -> Int {
        switch self {
        case .jsonEncodingFailed:   return 1
        case .jsonDecodingFailed:   return 2
        case .jsonEmpty:            return 3
        case .invalidType:          return 4
        case .unknownException:     return Int.max
        }
    }
    
    public func errorDescription() -> String {
        switch self {
        case .jsonEncodingFailed:
            return "JSON encoding failed"
        case .jsonDecodingFailed:
            return "JSON decoding failed"
        case .jsonEmpty(let message):
            if let message = message {
                return "JSON response empty: \(message)"
            } else {
                return "JSON response empty"
            }
        case .invalidType(let exception):
            if let exception = exception {
                return "Invalid type: \(exception)"
            } else {
                return "Invalid type"
            }
        case .unknownException(let exception):
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
