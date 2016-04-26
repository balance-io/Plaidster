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

private func cocoaErrorFromException(exception: ErrorType) -> NSError {
    if let exception = exception as? PlaidErrorConvertible {
        return exception.cocoaError()
    } else {
        return PlaidsterError.UnknownException(exception: exception).cocoaError()
    }
}

private func throwPlaidsterError(code: Int?, _ message: String?) throws {
    if let code = code {
        switch code {
        case PlaidErrorCode.InstitutionDown: throw PlaidError.InstitutionDown
        case PlaidErrorCode.BadAccessToken: throw PlaidError.BadAccessToken
        case PlaidErrorCode.ItemNotFound: throw PlaidError.ItemNotFound
        default: throw PlaidError.GenericError(code, message)
        }
    }
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
        var parameters = "client_id=\(clientID)&secret=\(secret)&username=\(username.URLQueryParameterEncodedValue)&password=\(password.URLQueryParameterEncodedValue)&type=\(type)&options=\(optionsDictionaryString.URLQueryParameterEncodedValue)"
        if let pin = pin {
            parameters += "&pin=\(pin)"
        }
        
        let URL = NSURL(string: URLString)!
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = HTTPMethod.Post
        request.HTTPBody = parameters.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (maybeData, maybeResponse, maybeError) in
            do {
                // Make sure there's data
                guard let data = maybeData where maybeError == nil else {
                    throw PlaidsterError.JSONEmpty(maybeError?.localizedDescription)
                }
                // Try to parse the JSON
                guard let JSONResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [NSObject: AnyObject] else {
                    throw PlaidsterError.JSONDecodingFailed
                }
                
                // Check for Plaidster errors
                let code = JSONResult["code"] as? Int
                let message = JSONResult["message"] as? String
                try throwPlaidsterError(code, message)
                
                // Check for an access token
                guard let token = JSONResult["access_token"] as? String else {
                    throw PlaidsterError.JSONEmpty("No access token returned")
                }
                
                // Check for an MFA response
                if let MFAResponse = JSONResult["mfa"] as? [[String: AnyObject]] {
                    let MFAType = JSONResult["type"] as? String
                    handler(accessToken: token, MFAType: MFAType, MFA: MFAResponse, accounts: nil, transactions: nil, error: maybeError)
                } else {
                    // Parse accounts if they're included
                    let unmanagedAccounts = JSONResult["accounts"] as? [[String: AnyObject]]
                    var managedAccounts: [PlaidAccount]?
                    if let unmanagedAccounts = unmanagedAccounts {
                        managedAccounts = unmanagedAccounts.map {
                            PlaidAccount(account: $0)
                        }
                    }
                    
                    // Parse transactions if they're included
                    let unmanagedTransactions = JSONResult["transactions"] as? [[String: AnyObject]]
                    var managedTransactions: [PlaidTransaction]?
                    if let unmanagedTransactions = unmanagedTransactions {
                        managedTransactions = unmanagedTransactions.map {
                            PlaidTransaction(transaction: $0)
                        }
                    }
                    
                    // Call the handler
                    handler(accessToken: token, MFAType: nil, MFA: nil, accounts: managedAccounts, transactions: managedTransactions, error: maybeError)
                }
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler(accessToken: nil, MFAType: type, MFA: nil, accounts: nil, transactions: nil, error: cocoaErrorFromException(error))
            }
        }
        
        task.resume()
    }
    
    public func removeUser(accessToken: String, handler: RemoveUserHandler) {
        let URLString = "\(baseURL)connect"
        let parameters = "client_id=\(clientID)&secret=\(secret)&access_token=\(accessToken)"
        
        let URL = NSURL(string: URLString)!
        let request = NSMutableURLRequest(URL: URL)
        request.HTTPMethod = HTTPMethod.Delete
        request.allHTTPHeaderFields = ["Content-Type": "application/x-www-form-urlencoded"]
        request.HTTPBody = parameters.dataUsingEncoding(NSUTF8StringEncoding)
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request) { (maybeData, maybeResponse, maybeError) in
            do {
                // Make sure there's data
                guard let data = maybeData where maybeError == nil else {
                    throw PlaidsterError.JSONEmpty(maybeError?.localizedDescription)
                }
                
                // Try to parse the JSON
                guard let JSONResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [NSObject: AnyObject] else {
                    throw PlaidsterError.JSONDecodingFailed
                }
                
                // Check for Plaidster errors
                let code = JSONResult["code"] as? Int
                let message = JSONResult["message"] as? String
                try throwPlaidsterError(code, message)
                
                // Call the handler
                handler(message: message, error: maybeError)
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler(message: nil, error: cocoaErrorFromException(error))
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
            do {
                guard let data = maybeData where maybeError == nil else {
                    throw PlaidsterError.JSONEmpty(maybeError?.localizedDescription)
                }
                
                guard let JSONResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [NSObject: AnyObject] else {
                    throw PlaidsterError.JSONDecodingFailed
                }
                
                let code = JSONResult["code"] as? Int
                let accounts = JSONResult["accounts"] as? [[String:AnyObject]]
                guard code != PlaidErrorCode.InstitutionDown else { throw PlaidError.InstitutionNotAvailable }
                guard accounts != nil else { throw PlaidsterError.JSONEmpty("No accounts returned") }
                if let resolve = JSONResult["resolve"] as? String {
                    guard code != PlaidErrorCode.InvalidMFA else { throw PlaidError.InvalidMFA(resolve) }
                }
                
                let unmanagedTransactions = JSONResult["transactions"] as! [[String: AnyObject]]
                let managedTransactions = unmanagedTransactions.map { PlaidTransaction(transaction: $0) }
                let unmanagedAccounts = JSONResult["accounts"] as! [[String: AnyObject]]
                let managedAccounts = unmanagedAccounts.map { PlaidAccount(account: $0) }
                handler(accounts: managedAccounts, transactions: managedTransactions, error: maybeError)
            } catch {
                handler(accounts: nil, transactions: nil, error: cocoaErrorFromException(error))
            }
        }
        
        task.resume()
    }
    
    public func fetchUserBalance(accessToken: String, handler: FetchUserBalanceHandler) {
        let URLString = "\(baseURL)balance?client_id=\(clientID)&secret=\(secret)&access_token=\(accessToken)"
        let URL = NSURL(string: URLString)!
        
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithURL(URL) { maybeData, maybeResponse, maybeError in
            do {
                // Make sure there's data
                guard let data = maybeData where maybeError == nil else {
                    throw PlaidsterError.JSONEmpty(maybeError?.localizedDescription)
                }
                
                // Try to parse the JSON
                guard let JSONResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [NSObject: AnyObject] else {
                    throw PlaidsterError.JSONDecodingFailed
                }
                
                // Check for Plaidster errors
                let code = JSONResult["code"] as? Int
                let message = JSONResult["message"] as? String
                try throwPlaidsterError(code, message)
                
                // Check for accounts
                guard let unmanagedAccounts = JSONResult["accounts"] as? [[String:AnyObject]] else {
                    throw PlaidsterError.JSONEmpty("No accounts returned")
                }
                
                // Map the accounts and call the handler
                let managedAccounts = unmanagedAccounts.map {
                    PlaidAccount(account: $0)
                }
                handler(accounts: managedAccounts, error: maybeError)
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler(accounts: [PlaidAccount](), error: cocoaErrorFromException(error))
            }
        }
        
        task.resume()
    }
    
    public func fetchUserTransactions(accessToken: String, showPending: Bool, beginDate: NSDate?, endDate: NSDate?, handler: FetchUserTransactionsHandler) {
        // Process the options dictionary. This parameter is sent as a JSON dictionary.
        var optionsDictionary: [String: AnyObject] = ["pending": true]
        if let beginDate = beginDate {
            optionsDictionary["gte"] = self.dateToJSONString(beginDate)
        }
        if let endDate = endDate {
            optionsDictionary["lte"] = self.dateToJSONString(endDate)
        }
        let optionsDictionaryString = self.dictionaryToString(optionsDictionary)
        
        // Create the URL string including the options dictionary
        let URLString = "\(baseURL)connect?client_id=\(clientID)&secret=\(secret)&access_token=\(accessToken)&options=\(optionsDictionaryString.URLQueryParameterEncodedValue)"
        let URL = NSURL(string: URLString)!
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(URL) { (maybeData, maybeResponse, maybeError) in
            do {
                // Make sure there's data
                guard let data = maybeData where maybeError == nil else {
                    throw PlaidsterError.JSONEmpty(maybeError?.localizedDescription)
                }
                
                // Try to parse the JSON
                guard let JSONResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [NSObject: AnyObject] else {
                    throw PlaidsterError.JSONDecodingFailed
                }
                
                // Check for Plaidster errors
                let code = JSONResult["code"] as? Int
                let message = JSONResult["message"] as? String
                try throwPlaidsterError(code, message)
                
                // Check for transactions
                guard let unmanagedTransactions = JSONResult["transactions"] as? [[String: AnyObject]] else {
                    throw PlaidsterError.JSONEmpty("No transactions returned")
                }
                
                // Map the transactions and call the handler
                let managedTransactions = unmanagedTransactions.map { PlaidTransaction(transaction: $0) }
                handler(transactions: managedTransactions, error: maybeError)
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler(transactions: [PlaidTransaction](), error: cocoaErrorFromException(error))
            }
        }
        
        task.resume()
    }
    
    public func fetchCategories(handler: FetchCategoriesHandler) {
        let URLString = "\(baseURL)categories"
        let URL = NSURL(string: URLString)!
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(URL) { maybeData, maybeResponse, maybeError in
            do {
                // Make sure there's data
                guard let data = maybeData where maybeError == nil else {
                    throw PlaidsterError.JSONEmpty(maybeError?.localizedDescription)
                }
                
                // Try to parse the JSON
                guard let JSONResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [[String: AnyObject]] else {
                    throw PlaidsterError.JSONDecodingFailed
                }
                
                // Map the categories and call the handler
                let managedCategories = JSONResult.map {
                    PlaidCategory(category: $0)
                }
                handler(categories: managedCategories, error: maybeError)
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler(categories: [PlaidCategory](), error: cocoaErrorFromException(error))
            }
        }
        
        task.resume()
    }
    
    public func fetchInstitutions(handler: FetchInstitutionsHandler) {
        let URLString = "\(baseURL)institutions"
        let URL = NSURL(string: URLString)!
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(URL) { (maybeData, maybeResponse, maybeError) in
            do {
                // Make sure there's data
                guard let data = maybeData where maybeError == nil else {
                    throw PlaidsterError.JSONEmpty(maybeError?.localizedDescription)
                }
                
                // Try to parse the JSON
                guard let JSONResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [[String: AnyObject]] else {
                    throw PlaidsterError.JSONDecodingFailed
                }
                
                // Map the institutions and call the handler
                let managedInstitutions = try JSONResult.map { try PlaidInstitution(institution: $0) }
                handler(categories: managedInstitutions, error: maybeError)
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler(categories: [PlaidInstitution](), error: cocoaErrorFromException(error))
            }
        }
        
        task.resume()
    }
    
    public func fetchLongTailInstitutions(count: Int, offset: Int, handler: FetchInstitutionsHandler) {
        let URLString = "\(baseURL)institutions/longtail?client_id=\(clientID)&secret=\(secret)&count=\(count)&offset=\(offset)"
        let URL = NSURL(string: URLString)!
        let session = NSURLSession.sharedSession()
        
        let task = session.dataTaskWithURL(URL) { (maybeData, maybeResponse, maybeError) in
            do {
                // Make sure there's data
                guard let data = maybeData where maybeError == nil else {
                    throw PlaidsterError.JSONEmpty(maybeError?.localizedDescription)
                }
                
                // Try to parse the JSON
                guard let JSONResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [[String: AnyObject]] else {
                    throw PlaidsterError.JSONDecodingFailed
                }
                
                // Map the instututions and call the handler
                let managedInstitutions = try JSONResult.map { try PlaidInstitution(institution: $0) }
                handler(categories: managedInstitutions, error: maybeError)
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler(categories: [PlaidInstitution](), error: cocoaErrorFromException(error))
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
            do {
                // Make sure there's data
                guard let data = maybeData where maybeError == nil else {
                    // For whatever reason, this API returns empty on success when no results are returned,
                    // so in this case it's not an error. Just return an empty set.
                    handler(categories: [PlaidSearchInstitution](), error: nil)
                    return
                }
                
                // Try to parse the JSON
                guard let JSONResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [[String: AnyObject]] else {
                    throw PlaidsterError.JSONDecodingFailed
                }
                
                // Map the instututions and call the handler
                let managedInstitutions = try JSONResult.map { try PlaidSearchInstitution(institution: $0) }
                handler(categories: managedInstitutions, error: maybeError)
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler(categories: [PlaidSearchInstitution](), error: cocoaErrorFromException(error))
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
            do {
                // Make sure there's data
                guard let data = maybeData where maybeError == nil else {
                    throw PlaidsterError.JSONEmpty(maybeError?.localizedDescription)
                }
                
                // Try to parse the JSON
                guard let JSONResult = try NSJSONSerialization.JSONObjectWithData(data, options: .MutableContainers) as? [[String: AnyObject]] else {
                    throw PlaidsterError.JSONDecodingFailed
                }
                
                // Map the instututions and call the handler
                let managedInstitutions = try JSONResult.map { try PlaidSearchInstitution(institution: $0) }
                handler(categories: managedInstitutions, error: maybeError)
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler(categories: [PlaidSearchInstitution](), error: cocoaErrorFromException(error))
            }
        }
        
        task.resume()
        
        return task
    }
}