//
//  Plaidster.swift
//  Plaidster
//
//  Created by Willow Bellemore on 2016-01-13.
//  Copyright © 2016 Plaidster. All rights reserved.
//

import Foundation

public typealias LoggingFunction = (_ item: Any) -> (Void)

public enum PlaidProduct: String {
    case Connect = "connect"
    case Auth    = "auth"
}

public enum PlaidEnvironment {
    case production
    case development
}

public enum PlaidMFAType: String {
    case Questions = "questions"    // Question based MFA
    case List      = "list"         // List of device options for code based MFA
    case Device    = "device"       // Code sent to chosen device
}

public enum PlaidMFAResponseType {
    case code
    case question
    case deviceType
    case deviceMask
}

private func cocoaErrorFromException(_ exception: Error) -> NSError {
    if let exception = exception as? PlaidErrorConvertible {
        return exception.cocoaError()
    } else {
        return PlaidsterError.unknownException(exception: exception).cocoaError()
    }
}

private func throwPlaidsterError(_ code: Int?, _ message: String?) throws {
    if let code = code {
        if let plaidError = PlaidError(rawValue: code) {
            throw plaidError
        } else {
            throw PlaidsterError.genericPlaidError(code, message)
        }
    }
}

public struct Plaidster {
    
    //
    // MARK: - Constants -
    //
    
    fileprivate static let DevelopmentBaseURL = "https://tartan.plaid.com/"
    fileprivate static let ProductionBaseURL = "https://api.plaid.com/"
    
    //
    // MARK: - Properties -
    //
    
    fileprivate let session: URLSession
    fileprivate let clientID: String
    fileprivate let secret: String
    fileprivate let baseURL: String
    
    //
    // MARK: - Logging -
    //
    
    // Set to true to debugPrint all raw JSON responses from Plaid
    public var printRawConnections = false
    public var logger: LoggingFunction?
    public var rawConnectionsLogger: LoggingFunction?
    
    // Optionally change the default connection timeout of 60 seconds
    fileprivate static let defaultConnectionTimeout = 60.0
    public var connectionTimeout: TimeInterval = Plaidster.defaultConnectionTimeout
    
    //
    // MARK: - Initialisation -
    //
    
    public init(clientID: String, secret: String, mode: PlaidEnvironment, connectionTimeout: TimeInterval = Plaidster.defaultConnectionTimeout, urlSessionDelegate: URLSessionDelegate? = nil) {
        self.clientID = clientID
        self.secret = secret
        
        switch mode {
        case .development:
            self.baseURL = Plaidster.DevelopmentBaseURL
        case .production:
            self.baseURL = Plaidster.ProductionBaseURL
        }
        
        self.connectionTimeout = connectionTimeout
        
        self.session = URLSession(configuration: .default, delegate: urlSessionDelegate, delegateQueue: nil)
    }
    
    //
    // MARK: - Private Methods -
    //
    
    fileprivate func log(_ item: Any) {
        if let logger = logger {
            logger(item: item)
        } else {
            print(item)
        }
    }
    
    func dictionaryToString(_ value: [String: Any]) -> String {
        guard JSONSerialization.isValidJSONObject(value) else { return "" }
        do {
            let data = try JSONSerialization.data(withJSONObject: value, options: JSONSerialization.WritingOptions(rawValue: 0))
            if let string = String(data: data, encoding: String.Encoding.utf8) {
                return string
            }
        } catch {
            log("Error serializing dictionary: \(error)")
        }
        
        return ""
    }
    
    static fileprivate let JSONDateFormatter: DateFormatter = {
        let JSONDateFormatter = DateFormatter()
        JSONDateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"
        return JSONDateFormatter
    }()
    
    static fileprivate let ISO8601DateFormatter: DateFormatter = {
        let addUserDateFormatter = DateFormatter()
        addUserDateFormatter.dateFormat = "yyyy-MM-dd"
        return addUserDateFormatter
    }()
    
    fileprivate func dateToJSONString(_ date: Date) -> String {
        return Plaidster.JSONDateFormatter.string(from: date)
    }
    
    fileprivate func dateToISO8601String(_ date: Date) -> String {
        return Plaidster.ISO8601DateFormatter.string(from: date)
    }
    
    static fileprivate let printRequestDateFormatter: DateFormatter = {
        let printRequestDateFormatter = DateFormatter()
        printRequestDateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return printRequestDateFormatter
    }()
    
    fileprivate func printRequest(_ request: URLRequest, responseData: Data, function: String = #function) {
        if printRawConnections {
            let url = request.url?.absoluteString ?? "Failed to decode URL"
            var body = ""
            if let HTTPBody = request.httpBody {
                if let HTTPBodyString = NSString(data: HTTPBody, encoding: String.Encoding.utf8.rawValue) {
                    body = HTTPBodyString as String
                }
            }
            let response = NSString(data: responseData, encoding: String.Encoding.utf8.rawValue) ?? "Failed to convert response data to string"
            
            let date = Plaidster.printRequestDateFormatter.string(from: Date())
            let logMessage = "\(date) \(function):\n" +
                             "URL: \(url)\n" +
                             "Body: \(body)\n" +
                             "Response: \(response)"
            
            if let rawConnectionsLogger = rawConnectionsLogger {
                rawConnectionsLogger(item: logMessage)
            } else {
                log(logMessage)
            }
        }
    }
    
    //
    // MARK: - Public Methods -
    //
    
    // If accessToken is included, this is treated as a patch request to update the login credentials
    public func addUser(username: String, password: String, pin: String?, type: String, pending: Bool = false, loginOnly: Bool = false, webhookUrl: String? = nil, startDate: Date? = nil, endDate: Date? = nil, accessToken: String? = nil, handler: @escaping AddUserHandler) {
        let URLString = "\(baseURL)connect"
        
        var optionsDictionary: [String: Any] = ["list": true]
        if pending {
            optionsDictionary["pending"] = true
        }
        if loginOnly {
            optionsDictionary["login_only"] = true
        }
        if let webhookUrl = webhookUrl {
            optionsDictionary["webhook"] = webhookUrl
        }
        if let startDate = startDate {
            optionsDictionary["start_date"] = dateToISO8601String(startDate)
        }
        if let endDate = endDate {
            optionsDictionary["end_date"] = dateToISO8601String(endDate)
        }
        
        
        let optionsDictionaryString = self.dictionaryToString(optionsDictionary)
        var parameters = "client_id=\(clientID)&secret=\(secret)&username=\(username.URLQueryParameterEncodedValue)&password=\(password.URLQueryParameterEncodedValue)&type=\(type)&options=\(optionsDictionaryString.URLQueryParameterEncodedValue)"
        if let pin = pin {
            parameters += "&pin=\(pin)"
        }
        if let accessToken = accessToken {
            parameters += "&access_token=\(accessToken)"
        }
        
        let URL = Foundation.URL(string: URLString)!
        var request = URLRequest(url: URL)
        request.timeoutInterval = connectionTimeout
        request.httpMethod = accessToken == nil ? HTTPMethod.Post : HTTPMethod.Patch
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = parameters.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request, completionHandler: { (maybeData, maybeResponse, maybeError) in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    throw PlaidsterError.jsonEmpty(maybeError?.localizedDescription)
                }
                
                // Print raw connection if option enabled
                self.printRequest(request, responseData: data)
                
                // Try to parse the JSON
                guard let JSONResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] else {
                    throw PlaidsterError.jsonDecodingFailed
                }
                
                // Check for Plaidster errors
                let code = JSONResult["code"] as? Int
                let message = JSONResult["message"] as? String
                try throwPlaidsterError(code, message)
                
                // Check for an access token
                guard let token = JSONResult["access_token"] as? String else {
                    throw PlaidsterError.jsonEmpty("No access token returned")
                }
                
                // Check for an MFA response
                let MFAType = PlaidMFAType(rawValue: JSONResult["type"] as? String ?? "")
                let MFAResponse = JSONResult["mfa"] as? [[String: AnyObject]]
                if (MFAType == nil || MFAResponse == nil) && !(MFAType == nil && MFAResponse == nil) {
                    // This should never happen. It should always return both pieces of data.
                    throw PlaidsterError.jsonEmpty("Missing MFA information")
                }
                
                if let MFAType = MFAType, let MFAResponse = MFAResponse {
                    // Call handler with MFA response
                    handler(token, MFAType, MFAResponse, nil, nil, maybeError)
                } else {
                    // Parse accounts if they're included
                    let unmanagedAccounts = JSONResult["accounts"] as? [[String: AnyObject]]
                    var managedAccounts: [PlaidAccount]?
                    if let unmanagedAccounts = unmanagedAccounts {
                        managedAccounts = [PlaidAccount]()
                        for result in unmanagedAccounts {
                            do {
                                let account = try PlaidAccount(account: result)
                                managedAccounts!.append(account)
                            } catch {
                                self.log(error)
                            }
                        }
                    }
                    
                    // Parse transactions if they're included
                    let unmanagedTransactions = JSONResult["transactions"] as? [[String: AnyObject]]
                    var managedTransactions: [PlaidTransaction]?
                    if let unmanagedTransactions = unmanagedTransactions {
                        managedTransactions = [PlaidTransaction]()
                        for result in unmanagedTransactions {
                            do {
                                let transaction = try PlaidTransaction(transaction: result)
                                managedTransactions!.append(transaction)
                            } catch {
                                self.log(error)
                            }
                        }
                    }
                    
                    // Call the handler
                    handler(token, nil, nil, managedAccounts, managedTransactions, maybeError)
                }
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler(nil, nil, nil, nil, nil, cocoaErrorFromException(error))
            }
        }) 
        
        task.resume()
    }
    
    public func removeUser(_ accessToken: String, handler: @escaping RemoveUserHandler) {
        let URLString = "\(baseURL)connect"
        let parameters = "client_id=\(clientID)&secret=\(secret)&access_token=\(accessToken)"
        
        let URL = Foundation.URL(string: URLString)!
        var request = URLRequest(url: URL)
        request.timeoutInterval = connectionTimeout
        request.httpMethod = HTTPMethod.Delete
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = parameters.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request, completionHandler: { (maybeData, maybeResponse, maybeError) in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    throw PlaidsterError.jsonEmpty(maybeError?.localizedDescription)
                }
                
                // Print raw connection if option enabled
                self.printRequest(request, responseData: data)
                
                // Try to parse the JSON
                guard let JSONResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] else {
                    throw PlaidsterError.jsonDecodingFailed
                }
                
                // Check for Plaidster errors
                let code = JSONResult["code"] as? Int
                let message = JSONResult["message"] as? String
                try throwPlaidsterError(code, message)
                
                // Call the handler
                handler(message, maybeError)
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler(nil, cocoaErrorFromException(error))
            }
        }) 
        
        task.resume()
    }
    
    public func submitMFACodeResponse(accessToken: String, code: String, patch: Bool = false, handler: @escaping SubmitMFAHandler) {
        submitMFAResponse(accessToken: accessToken, responseType: .code, response: code, handler: handler)
    }
    
    public func submitMFAQuestionResponse(accessToken: String, answer: String, patch: Bool = false, handler: @escaping SubmitMFAHandler) {
        submitMFAResponse(accessToken: accessToken, responseType: .question, response: answer, handler: handler)
    }
    
    public func submitMFADeviceType(accessToken: String, device: String, patch: Bool = false, handler: @escaping SubmitMFAHandler) {
        submitMFAResponse(accessToken: accessToken, responseType: .deviceType, response: device, handler: handler)
    }
    
    public func submitMFADeviceMask(accessToken: String, mask: String, patch: Bool = false, handler: @escaping SubmitMFAHandler) {
        submitMFAResponse(accessToken: accessToken, responseType: .deviceMask, response: mask, handler: handler)
    }
    
    public func submitMFAResponse(accessToken: String, responseType: PlaidMFAResponseType, response: String, patch: Bool = false, handler: @escaping SubmitMFAHandler) {
        let URLString = "\(baseURL)connect/step"
        var parameters = "client_id=\(clientID)&secret=\(secret)&access_token=\(accessToken)"
        
        switch responseType {
        case .code, .question:
            parameters += "&mfa=\(response.URLQueryParameterEncodedValue)"
        case .deviceType:
            parameters += "&options={\"send_method\":{\"type\":\"\(response)\"}}"
        case .deviceMask:
            parameters += "&options={\"send_method\":{\"mask\":\"\(response)\"}}"
        }
        
        let URL = Foundation.URL(string: URLString)!
        var request = URLRequest(url: URL)
        request.timeoutInterval = connectionTimeout
        request.httpMethod = patch ? HTTPMethod.Patch : HTTPMethod.Post
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpBody = parameters.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request, completionHandler: { (maybeData, maybeResponse, maybeError) in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    throw PlaidsterError.jsonEmpty(maybeError?.localizedDescription)
                }
                
                // Print raw connection if option enabled
                self.printRequest(request, responseData: data)
                
                // Try to parse the JSON
                guard let JSONResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] else {
                    throw PlaidsterError.jsonDecodingFailed
                }
                
                // Check for Plaidster errors
                let code = JSONResult["code"] as? Int
                let message = JSONResult["message"] as? String
                try throwPlaidsterError(code, message)
                
                // Check for an MFA response
                let MFAType = PlaidMFAType(rawValue: JSONResult["type"] as? String ?? "")
                var MFAResponse = JSONResult["mfa"] as? [[String: AnyObject]]
                if MFAResponse == nil {
                    if let response = JSONResult["mfa"] as? [String: AnyObject] {
                        MFAResponse = [response]
                    }
                }
                
                if let MFAType = MFAType, let MFAResponse = MFAResponse {
                    // Call handler with MFA response
                    handler(MFAType, MFAResponse, nil, nil, maybeError)
                } else {
                    // Parse accounts if they're included
                    let unmanagedAccounts = JSONResult["accounts"] as? [[String: AnyObject]]
                    var managedAccounts: [PlaidAccount]?
                    if let unmanagedAccounts = unmanagedAccounts {
                        managedAccounts = [PlaidAccount]()
                        for result in unmanagedAccounts {
                            do {
                                let account = try PlaidAccount(account: result)
                                managedAccounts!.append(account)
                            } catch {
                                self.log(error)
                            }
                        }
                    }
                    
                    // Parse transactions if they're included
                    let unmanagedTransactions = JSONResult["transactions"] as? [[String: AnyObject]]
                    var managedTransactions: [PlaidTransaction]?
                    if let unmanagedTransactions = unmanagedTransactions {
                        managedTransactions = [PlaidTransaction]()
                        for result in unmanagedTransactions {
                            do {
                                let transaction = try PlaidTransaction(transaction: result)
                                managedTransactions!.append(transaction)
                            } catch {
                                self.log(error)
                            }
                        }
                    }
                    
                    // Call the handler
                    handler(nil, nil, managedAccounts, managedTransactions, maybeError)
                }
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler(nil, nil, nil, nil, cocoaErrorFromException(error))
            }
        }) 
        
        task.resume()
    }
    
    public func fetchUserBalance(_ accessToken: String, handler: @escaping FetchUserBalanceHandler) {
        let URLString = "\(baseURL)balance?client_id=\(clientID)&secret=\(secret)&access_token=\(accessToken)"
        let URL = Foundation.URL(string: URLString)!
        var request = URLRequest(url: URL)
        request.timeoutInterval = connectionTimeout
        
        let task = session.dataTask(with: request, completionHandler: { maybeData, maybeResponse, maybeError in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    throw PlaidsterError.jsonEmpty(maybeError?.localizedDescription)
                }
                
                // Print raw connection if option enabled
                self.printRequest(request, responseData: data)
                
                // Try to parse the JSON
                guard let JSONResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] else {
                    throw PlaidsterError.jsonDecodingFailed
                }
                
                // Check for Plaidster errors
                let code = JSONResult["code"] as? Int
                let message = JSONResult["message"] as? String
                try throwPlaidsterError(code, message)
                
                // Check for accounts
                guard let unmanagedAccounts = JSONResult["accounts"] as? [[String: AnyObject]] else {
                    throw PlaidsterError.jsonEmpty("No accounts returned")
                }
                
                // Map the accounts and call the handler
                var managedAccounts = [PlaidAccount]()
                for result in unmanagedAccounts {
                    do {
                        let account = try PlaidAccount(account: result)
                        managedAccounts.append(account)
                    } catch {
                        self.log(error)
                    }
                }
                handler(managedAccounts, maybeError)
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler([PlaidAccount](), cocoaErrorFromException(error))
            }
        }) 
        
        task.resume()
    }
    
    public func fetchUserTransactions(_ accessToken: String, pending: Bool, beginDate: Date?, endDate: Date?, handler: @escaping FetchUserTransactionsHandler) {
        // Process the options dictionary. This parameter is sent as a JSON dictionary.
        var optionsDictionary: [String: Any] = ["pending": pending]
        if let beginDate = beginDate {
            optionsDictionary["gte"] = self.dateToJSONString(beginDate)
        }
        if let endDate = endDate {
            optionsDictionary["lte"] = self.dateToJSONString(endDate)
        }
        let optionsDictionaryString = self.dictionaryToString(optionsDictionary)
        
        // Create the URL string including the options dictionary
        let URLString = "\(baseURL)connect?client_id=\(clientID)&secret=\(secret)&access_token=\(accessToken)&options=\(optionsDictionaryString.URLQueryParameterEncodedValue)"
        let URL = Foundation.URL(string: URLString)!
        var request = URLRequest(url: URL)
        request.timeoutInterval = connectionTimeout
        
        let task = session.dataTask(with: request, completionHandler: { (maybeData, maybeResponse, maybeError) in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    throw PlaidsterError.jsonEmpty(maybeError?.localizedDescription)
                }
                
                // Print raw connection if option enabled
                self.printRequest(request, responseData: data)
                
                // Try to parse the JSON
                guard let JSONResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] else {
                    throw PlaidsterError.jsonDecodingFailed
                }
                
                // Check for Plaidster errors
                let code = JSONResult["code"] as? Int
                let message = JSONResult["message"] as? String
                try throwPlaidsterError(code, message)
                
                // Check for transactions
                guard let unmanagedTransactions = JSONResult["transactions"] as? [[String: AnyObject]] else {
                    throw PlaidsterError.jsonEmpty("No transactions returned")
                }
                
                // Map the transactions and call the handler
                var managedTransactions = [PlaidTransaction]()
                for result in unmanagedTransactions {
                    do {
                        let transaction = try PlaidTransaction(transaction: result)
                        managedTransactions.append(transaction)
                    } catch {
                        self.log(error)
                    }
                }
                handler(managedTransactions, maybeError)
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler([PlaidTransaction](), cocoaErrorFromException(error))
            }
        }) 
        
        task.resume()
    }
    
    public func fetchCategories(_ handler: @escaping FetchCategoriesHandler) {
        let URLString = "\(baseURL)categories"
        let URL = Foundation.URL(string: URLString)!
        var request = URLRequest(url: URL)
        request.timeoutInterval = connectionTimeout
        
        let task = session.dataTask(with: request, completionHandler: { maybeData, maybeResponse, maybeError in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    throw PlaidsterError.jsonEmpty(maybeError?.localizedDescription)
                }
                
                // Print raw connection if option enabled
                self.printRequest(request, responseData: data)
                
                // Try to parse the JSON
                guard let JSONResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: AnyObject]] else {
                    throw PlaidsterError.jsonDecodingFailed
                }
                
                // Map the categories and call the handler
                var managedCategories = [PlaidCategory]()
                for result in JSONResult {
                    do {
                        let category = try PlaidCategory(category: result)
                        managedCategories.append(category)
                    } catch {
                        self.log(error)
                    }
                }
                
                handler(managedCategories, maybeError)
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler([PlaidCategory](), cocoaErrorFromException(error))
            }
        }) 
        
        task.resume()
    }
    
    @available(*, deprecated)
    public func fetchInstitutions(_ handler: @escaping FetchInstitutionsHandler) {
        let URLString = "\(baseURL)institutions"
        let URL = Foundation.URL(string: URLString)!
        var request = URLRequest(url: URL)
        request.timeoutInterval = connectionTimeout
        
        let task = session.dataTask(with: request, completionHandler: { (maybeData, maybeResponse, maybeError) in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    throw PlaidsterError.jsonEmpty(maybeError?.localizedDescription)
                }
                
                // Print raw connection if option enabled
                self.printRequest(request, responseData: data)
                
                // Try to parse the JSON
                guard let JSONResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: AnyObject]] else {
                    throw PlaidsterError.jsonDecodingFailed
                }
                
                // Map the institutions and call the handler
                var managedInstitutions = [PlaidInstitution]()
                for result in JSONResult {
                    do {
                        let institution = try PlaidInstitution(institution: result)
                        managedInstitutions.append(institution)
                    } catch {
                        self.log(error)
                    }
                }
                handler(managedInstitutions, maybeError)
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler([PlaidInstitution](), cocoaErrorFromException(error))
            }
        }) 
        
        task.resume()
    }
    
    @available(*, deprecated)
    public func fetchLongtailInstitutions(_ count: Int, offset: Int, handler: @escaping FetchLongtailInstitutionsHandler) {
        let URLString = "\(baseURL)institutions/longtail"
        let parameters = "client_id=\(clientID)&secret=\(secret)&count=\(count)&offset=\(offset)"
        let URL = Foundation.URL(string: URLString)!
        var request = URLRequest(url: URL)
        request.timeoutInterval = connectionTimeout
        request.httpMethod = HTTPMethod.Post
        request.httpBody = parameters.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request, completionHandler: { (maybeData, maybeResponse, maybeError) in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    throw PlaidsterError.jsonEmpty(maybeError?.localizedDescription)
                }
                
                // Print raw connection if option enabled
                self.printRequest(request, responseData: data)
                
                // Try to parse the JSON
                guard let JSONResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject], let totalCount = JSONResult["total_count"] as? Int, let results = JSONResult["results"] as? [[String: AnyObject]] else {
                    throw PlaidsterError.jsonDecodingFailed
                }
                
                // Map the instututions and call the handler
                var managedInstitutions = [PlaidInstitution]()
                for result in results {
                    do {
                        let institution = try PlaidInstitution(institution: result)
                        managedInstitutions.append(institution)
                    } catch {
                        self.log(error)
                    }
                }
                handler(managedInstitutions, totalCount, maybeError)
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler([PlaidInstitution](), -1, cocoaErrorFromException(error))
            }
        }) 
        
        task.resume()
    }
    
    @available(*, deprecated)
    public func searchInstitutions(query: String, product: PlaidProduct?, handler: @escaping SearchInstitutionsHandler) -> URLSessionDataTask {
        var URLString = "\(baseURL)institutions/search?q=\(query.URLQueryParameterEncodedValue)"
        if let product = product {
            URLString += "&p=\(product.rawValue)"
        }
       
        let URL = Foundation.URL(string: URLString)!
        var request = URLRequest(url: URL)
        request.timeoutInterval = connectionTimeout
        
        let task = session.dataTask(with: request, completionHandler: { (maybeData, maybeResponse, maybeError) in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    // For whatever reason, this API returns empty on success when no results are returned,
                    // so in this case it's not an error. Just return an empty set.
                    handler([PlaidSearchInstitution](), nil)
                    return
                }
                
                // Print raw connection if option enabled
                self.printRequest(request, responseData: data)
                
                // Try to parse the JSON
                guard let JSONResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: AnyObject]] else {
                    throw PlaidsterError.jsonDecodingFailed
                }
                
                // Map the instututions and call the handler
                var managedInstitutions = [PlaidSearchInstitution]()
                for result in JSONResult {
                    do {
                        let institution = try PlaidSearchInstitution(institution: result)
                        managedInstitutions.append(institution)
                    } catch {
                        self.log(error)
                    }
                }
                handler(managedInstitutions, maybeError)
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler([PlaidSearchInstitution](), cocoaErrorFromException(error))
            }
        }) 
        
        task.resume()
        
        return task
    }
    
    @available(*, deprecated)
    public func searchInstitutions(id: String, handler: @escaping SearchInstitutionsHandler) -> URLSessionDataTask {
        let URLString = "\(baseURL)institutions/search?id=\(id)"
        let URL = Foundation.URL(string: URLString)!
        var request = URLRequest(url: URL)
        request.timeoutInterval = connectionTimeout
        
        let task = session.dataTask(with: request, completionHandler: { (maybeData, maybeResponse, maybeError) in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    // For whatever reason, this API returns empty on success when no results are returned,
                    // so in this case it's not an error. Just return an empty set.
                    handler([PlaidSearchInstitution](), nil)
                    return
                }
                
                // Print raw connection if option enabled
                self.printRequest(request, responseData: data)
                
                // Try to parse the JSON
                guard let JSONResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] else {
                    throw PlaidsterError.jsonDecodingFailed
                }
                
                // Map the institution and call the handler
                let managedInstitution = try PlaidSearchInstitution(institution: JSONResult)
                handler([managedInstitution], maybeError)
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler([PlaidSearchInstitution](), cocoaErrorFromException(error))
            }
        }) 
        
        task.resume()
        
        return task
    }
    
    public func fetchInstitutionsAll(_ count: Int, offset: Int, handler: @escaping FetchLongtailInstitutionsHandler) {
        let URLString = "\(baseURL)institutions/all"
        let parameters = "client_id=\(clientID)&secret=\(secret)&count=\(count)&offset=\(offset)"
        let URL = Foundation.URL(string: URLString)!
        var request = URLRequest(url: URL)
        request.timeoutInterval = connectionTimeout
        request.httpMethod = HTTPMethod.Post
        request.httpBody = parameters.data(using: String.Encoding.utf8)
        
        let task = session.dataTask(with: request, completionHandler: { (maybeData, maybeResponse, maybeError) in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    throw PlaidsterError.jsonEmpty(maybeError?.localizedDescription)
                }
                
                // Print raw connection if option enabled
                self.printRequest(request, responseData: data)
                
                // Try to parse the JSON
                guard let JSONResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject], let totalCount = JSONResult["total_count"] as? Int, let results = JSONResult["results"] as? [[String: AnyObject]] else {
                    throw PlaidsterError.jsonDecodingFailed
                }
                
                // Map the instututions and call the handler
                var managedInstitutions = [PlaidInstitution]()
                for result in results {
                    do {
                        let institution = try PlaidInstitution(institution: result)
                        managedInstitutions.append(institution)
                    } catch {
                        self.log(error)
                    }
                }
                handler(managedInstitutions, totalCount, maybeError)
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler([PlaidInstitution](), -1, cocoaErrorFromException(error))
            }
        })
        
        task.resume()
    }
    
    public func searchInstitutionsAll(query: String, product: PlaidProduct?, handler: @escaping SearchInstitutionsHandler) -> URLSessionDataTask {
        var URLString = "\(baseURL)institutions/all/search?q=\(query.URLQueryParameterEncodedValue)"
        if let product = product {
            URLString += "&p=\(product.rawValue)"
        }
        
        let URL = Foundation.URL(string: URLString)!
        var request = URLRequest(url: URL)
        request.timeoutInterval = connectionTimeout
        
        let task = session.dataTask(with: request, completionHandler: { (maybeData, maybeResponse, maybeError) in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    // For whatever reason, this API returns empty on success when no results are returned,
                    // so in this case it's not an error. Just return an empty set.
                    handler([PlaidSearchInstitution](), nil)
                    return
                }
                
                // Print raw connection if option enabled
                self.printRequest(request, responseData: data)
                
                // Try to parse the JSON
                guard let JSONResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [[String: AnyObject]] else {
                    throw PlaidsterError.jsonDecodingFailed
                }
                
                // Map the instututions and call the handler
                var managedInstitutions = [PlaidSearchInstitution]()
                for result in JSONResult {
                    do {
                        let institution = try PlaidSearchInstitution(institution: result)
                        managedInstitutions.append(institution)
                    } catch {
                        self.log(error)
                    }
                }
                handler(managedInstitutions, maybeError)
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler([PlaidSearchInstitution](), cocoaErrorFromException(error))
            }
        })
        
        task.resume()
        
        return task
    }
    
    public func searchInstitutionsAll(id: String, handler: @escaping SearchInstitutionsHandler) -> URLSessionDataTask {
        let URLString = "\(baseURL)institutions/all/search?id=\(id)"
        let URL = Foundation.URL(string: URLString)!
        var request = URLRequest(url: URL)
        request.timeoutInterval = connectionTimeout
        
        let task = session.dataTask(with: request, completionHandler: { (maybeData, maybeResponse, maybeError) in
            do {
                // Make sure there's data
                guard let data = maybeData, maybeError == nil else {
                    // For whatever reason, this API returns empty on success when no results are returned,
                    // so in this case it's not an error. Just return an empty set.
                    handler([PlaidSearchInstitution](), nil)
                    return
                }
                
                // Print raw connection if option enabled
                self.printRequest(request, responseData: data)
                
                // Try to parse the JSON
                guard let JSONResult = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: AnyObject] else {
                    throw PlaidsterError.jsonDecodingFailed
                }
                
                // Map the institution and call the handler
                let managedInstitution = try PlaidSearchInstitution(institution: JSONResult)
                handler([managedInstitution], maybeError)
            } catch {
                // Convert exceptions into NSErrors for the handler
                handler([PlaidSearchInstitution](), cocoaErrorFromException(error))
            }
        })
        
        task.resume()
        
        return task
    }
}
