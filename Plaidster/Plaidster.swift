//
//  Plaidster.swift
//  Plaidster
//
//  Created by Willow Bumby on 2016-01-13.
//  Copyright © 2016 Willow Bumby. All rights reserved.
//

import Foundation

public enum PlaidEnvironment {
    case Production
    case Development
}

public enum PlaidUserType {
    case Auth
    case Connect
    case Balance
}

public struct Plaidster {
    
    // MARK: Constants
    private static let DevelopmentBaseURL = "https://tartan.plaid.com/"
    private static let ProductionBaseURL = "https://api.plaid.com/"
    
    // MARK: Properties
    let clientID: String
    let secret: String
    let baseURL: NSURL
    
    // MARK: Initialisation
    init(clientID: String, secret: String, mode: PlaidEnvironment) {
        self.clientID = clientID
        self.secret = secret
        
        switch mode {
        case .Development:
            self.baseURL = NSURL(string: Plaidster.DevelopmentBaseURL)!
        case .Production:
            self.baseURL = NSURL(string: Plaidster.ProductionBaseURL)!
        }
    }
    
    // MARK: Methods
    func addUser(userType: PlaidUserType, username: String, password: String, pin: String?, institution: PlaidInstitution, handler: AddUserHandler) {
        let optionsDictionaryString = self.dictionaryToString(["list": true])
        var URLString = "\(baseURL)connect?client_id=\(clientID)&secret=\(secret)&username=\(username)&password=\(password.encodeValue)"
        
        if let pin = pin {
            URLString += "&pin=\(pin)&type=\(institution)&\(optionsDictionaryString.encodeValue)"
        } else {
            URLString += "&type=\(institution)&options=\(optionsDictionaryString.encodeValue)"
        }
        
        let URL = NSURL(string: URLString)!
        let request = NSMutableURLRequest(URL: URL)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = HTTPMethod.Post
        
        let task = session.dataTaskWithRequest(request) { (maybeData, maybeResponse, maybeError) in
            guard let data = maybeData, response = maybeResponse where maybeError == nil else { return }
            do {
                guard let JSONResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [NSObject: AnyObject] else {
                    throw JSONError.DecodingFailed
                }
                
                let code = JSONResult["code"] as? Int
                guard code != PlaidErrorCode.InstitutionDown else { throw PlaidError.InstitutionNotAvailable }
                if let resolve = JSONResult["resolve"] as? String {
                    guard code != PlaidErrorCode.InvalidCredentials else { throw PlaidError.InvalidCredentials(resolve) }
                    guard code != PlaidErrorCode.ProductNotFound else { throw PlaidError.CredentialsMissing(resolve) }
                }
                
                guard let token = JSONResult["access_token"] as? String else { throw JSONError.DecodingFailed }
                guard let MFAResponse = JSONResult["mfa"] as? [[String: AnyObject]] else {
                    let unmanagedTransactions = JSONResult["transactions"] as! [[String: AnyObject]]
                    let managedTransactions = unmanagedTransactions.map { Transaction(transaction: $0) }
                    let unmanagedAccounts = JSONResult["accounts"] as! [[String: AnyObject]]
                    let managedAccounts = unmanagedAccounts.map { Account(account: $0) }
                    handler(response: response, accessToken: token, MFAType: nil, MFA: nil, accounts: managedAccounts, transactions: managedTransactions, error: maybeError)
                    
                    return
                }
                
                var type: String?
                if let MFAType = JSONResult["type"] as? String { type = MFAType }
                handler(response: response, accessToken: token, MFAType: type, MFA: MFAResponse, accounts: nil, transactions: nil, error: maybeError)
            } catch {
                // Handle `throw` statements.
                debugPrint("addUser(_;) Error: \(error)")
            }
        }
        
        task.resume()
    }
    
    func submitMFAResponse(accessToken: String, code: Bool?, response: String, handler: SubmitMFAHandler) {
        let optionsDictionaryString = self.dictionaryToString(["send_method": response])
        var URLString = "\(baseURL)connect/step?client_id=\(clientID)&secret=\(secret)&access_token=\(accessToken)"

        if true == code {
            URLString += "&options=\(optionsDictionaryString.encodeValue)"
        } else {
            URLString += "&mfa=\(response.encodeValue)"
        }
        
        let URL = NSURL(string: URLString)!
        let request = NSMutableURLRequest(URL: URL)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = HTTPMethod.Post
        
        let task = session.dataTaskWithRequest(request) { (maybeData, maybeResponse, maybeError) in
            guard let data = maybeData, response = maybeResponse where maybeError == nil else { return }
            
            do {
                guard let JSONResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [NSObject: AnyObject] else {
                    throw JSONError.DecodingFailed
                }
                
                let code = JSONResult["code"] as? Int
                let accounts = JSONResult["accounts"] as? [[String:AnyObject]]
                guard code != PlaidErrorCode.InstitutionDown else { throw PlaidError.InstitutionNotAvailable }
                guard accounts != nil else { throw JSONError.Empty }
                if let resolve = JSONResult["resolve"] as? String {
                    guard code != PlaidErrorCode.InvalidMFA else { throw PlaidError.InvalidMFA(resolve) }
                }
                
                let unmanagedTransactions = JSONResult["transactions"] as! [[String: AnyObject]]
                let managedTransactions = unmanagedTransactions.map { Transaction(transaction: $0) }
                let unmanagedAccounts = JSONResult["accounts"] as! [[String: AnyObject]]
                let managedAccounts = unmanagedAccounts.map { Account(account: $0) }
                handler(response: response, accounts: managedAccounts, transactions: managedTransactions, error: maybeError)
            } catch {
                // Handle `throw` statements.
                debugPrint("submitMFAResponse(_;) Error: \(error)")
            }
            
        }
        
        task.resume()
    }
}