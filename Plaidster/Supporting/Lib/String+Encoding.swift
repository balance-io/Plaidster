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
    static public var URLQueryEncodedValueAllowedCharacters: CharacterSet = {
        var charSet = CharacterSet.urlQueryAllowed
        charSet.remove(charactersIn: "?&=@+/'")
        return charSet
    }()
    
    // Used to encode individual query parameters
    var URLQueryParameterEncodedValue: String {
        return self.addingPercentEncoding(withAllowedCharacters: String.URLQueryEncodedValueAllowedCharacters) ?? self
    }
    
    // Used to encode entire query strings
    var URLQueryStringEncodedValue: String {
        return self.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) ?? self
    }
}
