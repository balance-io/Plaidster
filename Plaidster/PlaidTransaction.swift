//
//  PlaidTransaction.swift
//  Plaidster
//
//  Created by Willow Bellemore on 2016-01-13.
//  Copyright © 2016 Plaidster. All rights reserved.
//

import Foundation

public struct PlaidTransaction {
    
    // MARK: Properties
    public let account: String
    public let id: String
    public let amount: Double
    public let date: String
    public let name: String
    public let pending: Bool
    
    public let address: String?
    public let city: String?
    public let state: String?
    public let zip: String?
    public let storeNumber: String?
    public let contact: String?
    public let latitude: Double?
    public let longitude: Double?
    
    public let trxnType: String?
    public let locationScoreAddress: Double?
    public let locationScoreCity: Double?
    public let locationScoreState: Double?
    public let locationScoreZip: Double?
    public let nameScore: Double?
    public let category: [String]?
    public let categoryId: Int?
    
    // MARK: Initialisation
    public init(transaction: [String: AnyObject]) throws {
        account = try checkType(transaction, name: "_account")
        id = try checkType(transaction, name: "_id")
        amount = try checkType(transaction, name: "amount")
        date = try checkType(transaction, name: "date")
        name = try checkType(transaction, name: "name")
        pending = try checkType(transaction, name: "pending")
        category = transaction["category"] as? [String]
        if let category_id = transaction["category_id"] as? String {
            categoryId = Int(category_id)
        } else if let category_id = transaction["category_id"] as? Int {
            categoryId = category_id
        } else {
            categoryId = nil
        }
        
        let meta = transaction["meta"] as? [String: AnyObject]
        let location = meta?["location"] as? [String: AnyObject]
        address = location?["address"] as? String
        city = location?["city"] as? String
        state = location?["state"] as? String
        zip = location?["zip"] as? String
        storeNumber = location?["store_number"] as? String
        contact = meta?["contact"] as? String
        
        let coordinates = location?["coordinates"] as? [String: AnyObject]
        latitude = coordinates?["lat"] as? Double
        longitude = coordinates?["lon"] as? Double
        
        let type = transaction["type"] as? [String: AnyObject]
        trxnType = type?["primary"] as? String

        let score = transaction["score"] as? [String: AnyObject]
        nameScore = score?["name"] as? Double
        
        let locationScore = score?["location"] as? [String: AnyObject]
        locationScoreAddress = locationScore?["address"] as? Double
        locationScoreCity = locationScore?["city"] as? Double
        locationScoreState = locationScore?["state"] as? Double
        locationScoreZip = locationScore?["zip"] as? Double
    }
}