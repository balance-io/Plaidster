//
//  PlaidError.swift
//  Plaidster
//
//  Created by Willow Bellemore on 2016-01-17.
//  Copyright © 2016 Plaidster. All rights reserved.
//

import Foundation

public enum PlaidError: Error, PlaidErrorConvertible {
    case badAccessToken
    case missingCredentials(String)
    case invalidCredentials(String)
    case invalidMFA(String)
    case institutionNotAvailable
    case institutionDown
    case itemNotFound
    
    // Used for not yet implemented values
    case genericError(Int, String?)
    
    public func errorDomain() -> String {
        return "PlaidsterErrorDomain"
    }
    
    public func errorCode() -> Int {
        switch self {
        case .badAccessToken:               return PlaidErrorCode.BadAccessToken
        case .missingCredentials:           return PlaidErrorCode.MissingCredentials
        case .invalidCredentials:           return PlaidErrorCode.InvalidCredentials
        case .invalidMFA:                   return PlaidErrorCode.InvalidMFA
        case .institutionNotAvailable:      return PlaidErrorCode.InstitutionNotAvailable
        case .institutionDown:              return PlaidErrorCode.InstitutionDown
        case .itemNotFound:                 return PlaidErrorCode.ItemNotFound
        
        case .genericError(let code, _):    return code
        }
    }
    
    public func errorDescription() -> String {
        switch self {
        case .badAccessToken:
            return "Bad access token"
        case .missingCredentials(let message):
            return "Missing credentials: \(message)"
        case .invalidCredentials(let message):
            return "Invalid credentials: \(message)"
        case .invalidMFA(let message):
            return "Invalid MFA response: \(message)"
        case .institutionNotAvailable:
            return "Institution not available"
        case .institutionDown:
            return "Institution down"
        case .itemNotFound:
            return "Item not found"
            
        case .genericError(_, let message):
            return message ?? "Unknown error"
        }
    }
    
    public func errorUserInfo() -> Dictionary<String,String>? {
        return [NSLocalizedDescriptionKey: errorDescription()]
    }
}

public struct PlaidErrorCode {
    public static let MissingAccessToken = 1000
    public static let MissingType = 1001
    public static let DisallowedAccessToken = 1003
    public static let UnsupportedAccessToken = 1008
    public static let InvalidOptionsFormat = 1004
    public static let MissingCredentials = 1005
    public static let InvalidCredentialsFormat = 1006
    public static let UpdateRequired = 1007
    public static let InvalidContentType = 1009
    public static let MissingClientID = 1100
    public static let MissingSecret = 1101
    public static let InvalidSecretOrClientID = 1102
    public static let UnauthorizedProduct1104 = 1104
    public static let BadAccessToken = 1105
    public static let BadPublicToken = 1106
    public static let MissingPublicToken = 1107
    public static let InvalidType1108 = 1108
    public static let UnauthorizedProduct1109 = 1109
    public static let ProductNotEnabled = 1110
    public static let InvalidUpgrade = 1111
    public static let AdditionLimitExceeded = 1112
    public static let RateLimitExceeded = 1113
    public static let UnauthorizedEnvironment = 1114
    public static let ProductAlreadyEnabled = 1115
    public static let InvalidCredentials = 1200
    public static let InvalidUsername = 1201
    public static let InvalidPassword = 1202
    public static let InvalidMFA = 1203
    public static let InvalidSendMethod = 1204
    public static let AccountLocked = 1205
    public static let AccountNotSetup = 1206
    public static let CountryNotSupported = 1207
    public static let MFANotSupported = 1208
    public static let InvalidPin = 1209
    public static let AccountNotSupported = 1210
    public static let BOFAAccountNotSupported = 1211
    public static let NoAccounts = 1212
    public static let InvalidPatchUsername = 1213
    public static let MFAReset = 1215
    public static let MFANotRequired = 1218
    public static let InstitutionNotAvailable = 1300
    public static let UnableToFindInstitution = 1301
    public static let InstitutionNotResponding = 1302
    public static let InstitutionDown = 1303
    public static let InstitutionNoLongerSupported = 1307
    public static let UnableToFindCategory = 1501
    public static let TypeRequired = 1502
    public static let InvalidType1503 = 1503
    public static let InvalidDate = 1507
    public static let ProductNotFound = 1600
    public static let ProductNotAvailable = 1601
    public static let AccountNotFound = 1606
    public static let ItemNotFound = 1610
    public static let ExtractorError = 1700
    public static let ExtractorErrorRetry = 1701
    public static let PlaidError = 1702
    public static let PlannedMaintenance = 1800
}
