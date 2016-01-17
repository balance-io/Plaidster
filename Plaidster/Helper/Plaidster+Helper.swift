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
            let data = try NSJSONSerialization.dataWithJSONObject(value, options: .PrettyPrinted)
            if let string = String(data: data, encoding: NSUTF8StringEncoding) {
                return string
            }
        } catch {
            print("Something went wrong...")
            debugPrint("JSON parsing error in dictionaryToString(_;)")
        }
        
        return ""
    }
    
}