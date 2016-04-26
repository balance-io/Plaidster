//
//  Plaidster+Helper.swift
//  Plaidster
//
//  Created by Willow Bumby on 2016-01-13.
//  Copyright © 2016 Willow Bumby. All rights reserved.
//

import Foundation

public extension Plaidster {
    
    func dictionaryToString(value: AnyObject) -> String {
        guard NSJSONSerialization.isValidJSONObject(value) else { return "" }
        do {
            let data = try NSJSONSerialization.dataWithJSONObject(value, options: NSJSONWritingOptions(rawValue: 0))
            if let string = String(data: data, encoding: NSUTF8StringEncoding) {
                return string
            }
        } catch {
            debugPrint("Error serializing dictionary: \(error)")
        }
        
        return ""
    }
    
    static private let JSONDateFormatter = NSDateFormatter()
    static private var JSONDateFormatterToken: dispatch_once_t = 0
    func dateToJSONString(date: NSDate) -> String {
        dispatch_once(&Plaidster.JSONDateFormatterToken) {
            Plaidster.JSONDateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
        }
        
        return Plaidster.JSONDateFormatter.stringFromDate(date)
    }
}