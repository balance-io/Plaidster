//
//  String+Encoding.swift
//
//  Created by Willow Bumby on 2016-01-13.
//  Copyright © 2016 Willow Bumby. All rights reserved.
//

import Foundation

public extension String {
    
    // By default, the URLQueryAllowedCharacterSet is meant to allow encoding of entire query strings. This is 
    // a problem because it won't handle, for example, a password containing an & character. So we need to remove
    // those characters from the character set. Then the stringByAddingPercentEncodingWithAllowedCharacters method
    // will work as expected.
    static private var queryCharSet: NSCharacterSet = NSCharacterSet.URLQueryAllowedCharacterSet()
    static private var queryCharSetToken: dispatch_once_t = 0
    static public var URLQueryEncodedValueAllowedCharacters: NSCharacterSet {
        dispatch_once(&queryCharSetToken) {
            let mutableCharSet = queryCharSet.mutableCopy() as! NSMutableCharacterSet
            mutableCharSet.removeCharactersInString("?&=@+/'")
            queryCharSet = mutableCharSet
        }
        
        return queryCharSet
    }
    
    // Used to encode individual query parameters
    var URLQueryParameterEncodedValue: String {
        if let encodedValue = self.stringByAddingPercentEncodingWithAllowedCharacters(String.URLQueryEncodedValueAllowedCharacters) {
            return encodedValue
        } else {
            return self
        }
    }
    
    // Used to encode entire query strings
    var URLQueryStringEncodedValue: String {
        if let encodedValue = self.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet()) {
            return encodedValue
        } else {
            return self
        }
    }
}