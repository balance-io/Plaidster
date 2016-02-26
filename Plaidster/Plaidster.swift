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
    let baseURL: String
    
    // MARK: Initialisation
    public init(clientID: String, secret: String, mode: PlaidEnvironment) {
        self.clientID = clientID
        self.secret = secret
        
        switch mode {
        case .Development:
            self.baseURL = Plaidster.DevelopmentBaseURL
        case .Production:
            self.baseURL = Plaidster.ProductionBaseURL
        }
    }
    
    // MARK: Methods
    public func addUser(userType: PlaidUserType, username: String, password: String, pin: String?, type: String, handler: AddUserHandler) {
        let URLString = "\(baseURL)connect"
        
        
        let optionsDictionaryString = self.dictionaryToString(["list": true])
        var parameters = "client_id=\(clientID)&secret=\(secret)&username=\(username.URLQueryParameterEncodedValue)&password=\(password.URLQueryParameterEncodedValue)"
        
        if let pin = pin {
            parameters += "&pin=\(pin)&type=\(type)&\(optionsDictionaryString.URLQueryParameterEncodedValue)"
        } else {
            parameters += "&type=\(type)&options=\(optionsDictionaryString.URLQueryParameterEncodedValue)"
        }
        
        let URL = NSURL(string: URLString)!
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = HTTPMethod.Post
        request.HTTPBody = parameters.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
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
                    let managedTransactions = unmanagedTransactions.map { PlaidTransaction(transaction: $0) }
                    let unmanagedAccounts = JSONResult["accounts"] as! [[String: AnyObject]]
                    let managedAccounts = unmanagedAccounts.map { PlaidAccount(account: $0) }
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
    
    public func submitMFAResponse(accessToken: String, code: Bool?, response: String, handler: SubmitMFAHandler) {
        let optionsDictionaryString = self.dictionaryToString(["send_method": response])
        var URLString = "\(baseURL)connect/step?client_id=\(clientID)&secret=\(secret)&access_token=\(accessToken)"

        if true == code {
            URLString += "&options=\(optionsDictionaryString.URLQueryParameterEncodedValue)"
        } else {
            URLString += "&mfa=\(response.URLQueryParameterEncodedValue)"
        }
        
        let URL = NSURL(string: URLString)!
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = HTTPMethod.Post
        
        let session = NSURLSession.sharedSession()
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
                let managedTransactions = unmanagedTransactions.map { PlaidTransaction(transaction: $0) }
                let unmanagedAccounts = JSONResult["accounts"] as! [[String: AnyObject]]
                let managedAccounts = unmanagedAccounts.map { PlaidAccount(account: $0) }
                handler(response: response, accounts: managedAccounts, transactions: managedTransactions, error: maybeError)
            } catch {
                // Handle `throw` statements.
                debugPrint("submitMFAResponse(_;) Error: \(error)")
            }
        }
        
        task.resume()
    }
    
    public func fetchUserBalance(accessToken: String, handler: FetchUserBalanceHandler) {
        let URLString = "\(baseURL)balance?client_id=\(clientID)&secret=\(secret)&access_token=\(accessToken)"
        let URL = NSURL(string: URLString)!
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(URL) { (maybeData, maybeResponse, maybeError) in
            guard let data = maybeData, response = maybeResponse where maybeError == nil else { return }
            
            do {
                guard let JSONResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [NSObject: AnyObject] else {
                    throw JSONError.DecodingFailed
                }
                
                let code = JSONResult["code"] as? Int
                guard code != PlaidErrorCode.InstitutionDown else { throw PlaidError.InstitutionNotAvailable }
                guard code != PlaidErrorCode.BadAccessToken else { throw PlaidError.BadAccessToken }
                guard let unmanagedAccounts = JSONResult["accounts"] as? [[String:AnyObject]] else { throw JSONError.Empty }
                let managedAccounts = unmanagedAccounts.map { PlaidAccount(account: $0) }
                handler(response: response, accounts: managedAccounts, error: maybeError)
            } catch {
                // Handle `throw` statements.
                debugPrint("fetchUserBalance(_;) Error: \(error)")
            }
        }
        
        task.resume()
    }
    
    public func fetchUserTransactions(accessToken: String, showPending: Bool, beginDate: String?, endDate: String?, handler: FetchUserTransactionsHandler) {
        var optionsDictionary: [String: AnyObject] = ["pending": true]
        if let beginDate = beginDate { optionsDictionary["gte"] = beginDate }
        if let endDate = endDate { optionsDictionary["lte"] = endDate }
        
        let optionsDictionaryString = self.dictionaryToString(optionsDictionary)
        let URLString = "\(baseURL)connect?client_id=\(clientID)&secret=\(secret)&access_token=\(accessToken)&\(optionsDictionaryString.URLQueryParameterEncodedValue)"
        let URL = NSURL(string: URLString)!
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(URL) { (maybeData, maybeResponse, maybeError) in
            guard let data = maybeData, response = maybeResponse where maybeError == nil else { return }
            
            do {
                guard let JSONResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [NSObject: AnyObject] else {
                    throw JSONError.DecodingFailed
                }
                
                guard JSONResult["code"] as? Int != PlaidErrorCode.InstitutionDown else { throw PlaidError.InstitutionNotAvailable }
                guard let unmanagedTransactions = JSONResult["transactions"] as? [[String: AnyObject]] else { throw JSONError.Empty }
                let managedTransactions = unmanagedTransactions.map { PlaidTransaction(transaction: $0) }
                handler(response: response, transactions: managedTransactions, error: maybeError)
            } catch {
                // Handle `throw` statements.
                debugPrint("fetchUserTransactions(_;) Error: \(error)")
            }
        }
        
        task.resume()
    }
    
    public func fetchCategories(handler: FetchCategoriesHandler) {
        let URLString = "\(baseURL)categories"
        let URL = NSURL(string: URLString)!
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(URL) { (maybeData, maybeResponse, maybeError) in
            guard let data = maybeData, response = maybeResponse where maybeError == nil else { return }
            
            do {
                guard let JSONResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [[String: AnyObject]] else {
                    throw JSONError.DecodingFailed
                }
                
                let managedCategories = JSONResult.map { PlaidCategory(category: $0) }
                handler(response: response, categories: managedCategories, error: maybeError)
            } catch {
                // Handle `throw` statements.
                debugPrint("fetchCategories(_;) Error: \(error)")
            }
        }
        
        task.resume()
    }
    
    public func fetchInstitutions(handler: FetchInstitutionsHandler) {
        let URLString = "\(baseURL)institutions"
        let URL = NSURL(string: URLString)!
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(URL) { (maybeData, maybeResponse, maybeError) in
            guard let data = maybeData, response = maybeResponse where maybeError == nil else { return }
            
            do {
                guard let JSONResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [[String: AnyObject]] else {
                    throw JSONError.DecodingFailed
                }
                
                let managedInstitutions = try JSONResult.map { try PlaidInstitution(institution: $0) }
                handler(response: response, categories: managedInstitutions, error: maybeError)
            } catch {
                // Handle `throw` statements.
                debugPrint("fetchInstitutions(_;) Error: \(error)")
            }
        }
        
        task.resume()
    }
    
    public func fetchLongTailInstitutions(count: Int, offset: Int, handler: FetchInstitutionsHandler) {
        let URLString = "\(baseURL)institutions/longtail?client_id=\(clientID)&secret=\(secret)&count=\(count)&offset=\(offset)"
        let URL = NSURL(string: URLString)!
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(URL) { (maybeData, maybeResponse, maybeError) in
            guard let data = maybeData, response = maybeResponse where maybeError == nil else { return }
            
            do {
                guard let JSONResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [[String: AnyObject]] else {
                    throw JSONError.DecodingFailed
                }
                
                let managedInstitutions = try JSONResult.map { try PlaidInstitution(institution: $0) }
                handler(response: response, categories: managedInstitutions, error: maybeError)
            } catch {
                // Handle `throw` statements.
                debugPrint("fetchLongTailInstitutions(_;) Error: \(error)")
            }
        }
        
        task.resume()
    }
    
    public func searchInstitutions(query: String, product: String?, handler: SearchInstitutionsHandler) -> NSURLSessionDataTask {
        var URLString = "\(baseURL)institutions/search?q=\(query.URLQueryParameterEncodedValue)"
        if product != nil {
            URLString += "p=\(product)"
        }
        let URL = NSURL(string: URLString)!
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(URL) { (maybeData, maybeResponse, maybeError) in
            guard let data = maybeData, response = maybeResponse where maybeError == nil else { return }
            
            do {
                guard let JSONResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [[String: AnyObject]] else {
                    throw JSONError.DecodingFailed
                }
                
                let managedInstitutions = try JSONResult.map { try PlaidSearchInstitution(institution: $0) }
                handler(response: response, categories: managedInstitutions, error: maybeError)
            } catch {
                // Handle `throw` statements.
                debugPrint("searchLongTailInstitutions(_;) Error: \(error)")
            }
        }
        
        task.resume()
        
        return task
    }
    
    public func searchInstitutions(id: String, handler: SearchInstitutionsHandler) -> NSURLSessionDataTask {
        let URLString = "\(baseURL)institutions/search?id=\(id)"
        let URL = NSURL(string: URLString)!
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(URL) { (maybeData, maybeResponse, maybeError) in
            guard let data = maybeData, response = maybeResponse where maybeError == nil else { return }
            
            do {
                guard let JSONResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [[String: AnyObject]] else {
                    throw JSONError.DecodingFailed
                }
                
                let managedInstitutions = try JSONResult.map { try PlaidSearchInstitution(institution: $0) }
                handler(response: response, categories: managedInstitutions, error: maybeError)
            } catch {
                // Handle `throw` statements.
                debugPrint("searchLongTailInstitutions(_;) Error: \(error)")
            }
        }
        
        task.resume()
        
        return task
    }
}