//
//  String+Encoding.swift
//
//  Created by Willow Bellemore on 2016-01-13.
//  Copyright © 2016 Plaidster. All rights reserved.
//

import Foundation

public extension String {
    
    // By default, the URLQueryAllowedCharacterSet is meant to allow encoding of entire query strings. This is 
    // a problem because it won't handle, for example, a password containing an & character. So we need to remove
    // those characters from the character set. Then the stringByAddingPercentEncodingWithAllowedCharacters method
    // will work as expected.
    static fileprivate var queryCharSet: CharacterSet = CharacterSet.urlQueryAllowed
    static fileprivate var queryCharSetToken: Int = 0
    static public var URLQueryEncodedValueAllowedCharacters: CharacterSet = {
        let mutableCharSet = (queryCharSet as NSCharacterSet).mutableCopy() as! NSMutableCharacterSet
        mutableCharSet.removeCharacters(in: "?&=@+/'")
        queryCharSet = mutableCharSet as CharacterSet
        return queryCharSet
    }()
    
    // Used to encode individual query parameters
    var URLQueryParameterEncodedValue: String {
        if let encodedValue = self.addingPercentEncoding(withAllowedCharacters: String.URLQueryEncodedValueAllowedCharacters) {
            return encodedValue
        } else {
            return self
        }
    }
    
    // Used to encode entire query strings
    var URLQueryStringEncodedValue: String {
        if let encodedValue = self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
            return encodedValue
        } else {
            return self
        }
    }
}
