//
//  Transaction.swift
//  Plaidster
//
//  Created by Willow Bumby on 2016-01-13.
//  Copyright © 2016 Willow Bumby. All rights reserved.
//

import Foundation

public struct Transaction {
    
    // MARK: Properties
    let account: String
    let id: String
    let amount: Double
    let date: String
    let name: String
    let pending: Bool
    
    let address: String?
    let city: String?
    let state: String?
    let zip: String?
    let storeNumber: String?
    let latitude: Double?
    let longitude: Double?
    
    let trxnType: String?
    let locationScoreAddress: Double?
    let locationScoreCity: Double?
    let locationScoreState: Double?
    let locationScoreZip: Double?
    let nameScore: Double?
    let category: NSArray?
    
    // MARK: Initialisation
    public init(transaction: [String:AnyObject]) {
        
        account = transaction["_account"] as! String
        id = transaction["_id"] as! String
        amount = transaction["amount"] as! Double
        date = transaction["date"] as! String
        name = transaction["name"] as! String
        pending = transaction["pending"] as! Bool
        category = transaction["category"] as? NSArray
        
        let meta = transaction["meta"] as! [String:AnyObject]
        let location = meta["location"] as? [String:AnyObject]
        address = location?["address"] as? String
        city = location?["city"] as? String
        state = location?["state"] as? String
        zip = location?["zip"] as? String
        storeNumber = location?["store_number"] as? String
        
        let coordinates = location?["coordinates"] as? [String:AnyObject]
        latitude = coordinates?["lat"] as? Double
        longitude = coordinates?["lon"] as? Double
        
        let type = transaction["type"] as? [String:AnyObject]
        trxnType = type?["primary"] as? String

        let score = transaction["score"] as? [String:AnyObject]
        nameScore = score?["name"] as? Double
        
        let locationScore = score?["location"] as? [String:AnyObject]
        locationScoreAddress = locationScore?["address"] as? Double
        locationScoreCity = locationScore?["city"] as? Double
        locationScoreState = locationScore?["state"] as? Double
        locationScoreZip = locationScore?["zip"] as? Double

    }
}