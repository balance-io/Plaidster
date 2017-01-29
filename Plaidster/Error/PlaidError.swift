//
//  PlaidError.swift
//  Plaidster
//
//  Created by Willow Bellemore on 2016-01-17.
//  Copyright © 2016 Plaidster. All rights reserved.
//

import Foundation

let plaidErrorDomain = "PlaidErrorDomain"

public enum PlaidError: Int, Error, PlaidErrorConvertible {
    case missingAccessToken           = 1000
    case missingType                  = 1001
    case disallowedAccessToken        = 1003
    case invalidOptionsFormat         = 1004
    case missingCredentials           = 1005
    case invalidCredentialsFormat     = 1006
    case updateRequired               = 1007
    case unsupportedAccessToken       = 1008
    case invalidContentType           = 1009
    case missingClientID              = 1100
    case missingSecret                = 1101
    case invalidSecretOrClientID      = 1102
    case unauthorizedProduct1104      = 1104
    case badAccessToken               = 1105
    case badPublicToken               = 1106
    case missingPublicToken           = 1107
    case invalidType1108              = 1108
    case unauthorizedProduct1109      = 1109
    case productNotEnabled            = 1110
    case invalidUpgrade               = 1111
    case additionLimitExceeded        = 1112
    case rateLimitExceeded            = 1113
    case unauthorizedEnvironment      = 1114
    case productAlreadyEnabled        = 1115
    case invalidCredentials           = 1200
    case invalidUsername              = 1201
    case invalidPassword              = 1202
    case invalidMFA                   = 1203
    case invalidSendMethod            = 1204
    case accountLocked                = 1205
    case accountNotSetup              = 1206
    case countryNotSupported          = 1207
    case mfaNotSupported              = 1208
    case invalidPin                   = 1209
    case accountNotSupported          = 1210
    case bofaAccountNotSupported      = 1211
    case noAccounts                   = 1212
    case invalidPatchUsername         = 1213
    case mfaReset                     = 1215
    case mfaNotRequired               = 1218
    case wellsAccountNotSupported     = 1219
    case institutionNotAvailable      = 1300
    case unableToFindInstitution      = 1301
    case institutionNotResponding     = 1302
    case institutionDown              = 1303
    case institutionNoLongerSupported = 1307
    case unableToFindCategory         = 1501
    case typeRequired                 = 1502
    case invalidType1503              = 1503
    case invalidDate                  = 1507
    case productNotFound              = 1600
    case productNotAvailable          = 1601
    case accountNotFound              = 1606
    case itemNotFound                 = 1610
    case extractorError               = 1700
    case extractorErrorRetry          = 1701
    case plaidError                   = 1702
    case plannedMaintenance           = 1800
    
    public func errorDomain() -> String {
        return plaidsterErrorDomain
    }
    
    public func errorCode() -> Int {
        return self.rawValue
    }
    
    public func errorUserInfo() -> Dictionary<String,String>? {
        return [NSLocalizedDescriptionKey: errorDescription()]
    }
    
    public func errorDescription() -> String {
        switch self {
        case .missingAccessToken: return "You need to include the access_token that you received from the original submit call."
        case .missingType: return "You need to include a type parameter. Ex. bofa, wells, amex, chase, citi, etc."
        case .disallowedAccessToken: return "You included an access_token on a submit call - this is only allowed on step and get routes."
        case .unsupportedAccessToken: return "This access token format is no longer supported. Contact support to resolve."
        case .invalidOptionsFormat: return "Options need to be JSON or stringified JSON."
        case .missingCredentials: return "Provide username, password, and pin if appropriate."
        case .invalidCredentialsFormat: return "Credentials need to be JSON or stringified JSON."
        case .updateRequired: return "In order to upgrade an account, an upgrade_to field is required , ex. connect"
        case .invalidContentType: return "Valid 'Content-Type' headers are 'application/json' and 'application/x-www-form-urlencoded' with an optional 'UTF-8' charset."
        case .missingClientID: return "Include your Client ID so we know who you are."
        case .missingSecret: return "Include your Secret so we can verify your identity."
        case .invalidSecretOrClientID: return "The Client ID does not exist or the Secret does not match the Client ID you provided."
        case .unauthorizedProduct1104: return "Your Client ID does not have access to this product. Contact us to purchase this product."
        case .badAccessToken: return "This access_token appears to be corrupted."
        case .badPublicToken: return "This public_token is corrupt or does not exist in our database. See the Link docs."
        case .missingPublicToken: return "Include the public_token received from the Plaid Link module. See the Link docs."
        case .invalidType1108: return "This institution is not currently supported."
        case .unauthorizedProduct1109: return "The sandbox client_id and secret can only be used with sandbox credentials and access tokens. See the Sandbox docs."
        case .productNotEnabled: return "This product is not enabled for this item. Use the upgrade route to add it."
        case .invalidUpgrade: return "Specify a valid product to upgrade this item to."
        case .additionLimitExceeded: return "You have reached the maximum number of additions. Contact us to raise your limit."
        case .rateLimitExceeded: return "You have exceeded your request rate limit for this product. Try again soon."
        case .unauthorizedEnvironment: return "Your Client ID is not authorized to access this API environment. Contact support@plaid.com to gain access."
        case .productAlreadyEnabled: return "The specified product is already enabled for this item. Call the corresponding product endpoint directly."
        case .invalidCredentials: return "The username or password provided were not correct."
        case .invalidUsername: return "The username provided was not correct."
        case .invalidPassword: return "The password provided was not correct."
        case .invalidMFA: return "The multi-factor authentication response provided was not correct."
        case .invalidSendMethod: return "The MFA send_method provided was invalid. Consult the documentation for the proper format."
        case .accountLocked: return "This account is locked. Please visit your bank or credit card issuer's website and unlock your account."
        case .accountNotSetup: return "The account has not been fully set up. Please visit your bank or credit card issuer's website and finish the setup process."
        case .countryNotSupported: return "Only United States accounts are currently supported."
        case .mfaNotSupported: return "This account requires a form of multi-factor authentication that is not currently supported. Other accounts at this institution with a different form of multi-factor authentication may be supported."
        case .invalidPin: return "The pin provided was not correct."
        case .accountNotSupported: return "This account is currently not supported."
        case .bofaAccountNotSupported: return "The security rules for this account restrict access. Disable 'Extra Security at Sign-In' in your Bank of America settings."
        case .noAccounts: return "No valid accounts exist."
        case .invalidPatchUsername: return "The username provided does not match the one originally used when adding this account."
        case .mfaReset: return "MFA access has changed or this application's access has been revoked. Submit a PATCH call to resolve."
        case .mfaNotRequired: return "This item does not require the multi-factor authentication process at this time."
        case .wellsAccountNotSupported: return "The security rules for this account restrict access. Disable 'Enhanced Sign On' in your Wells Fargo settings."
        case .institutionNotAvailable: return "This institution is not yet available in this environment."
        case .unableToFindInstitution: return "Unable to find institution. Double-check the provided institution ID."
        case .institutionNotResponding: return "This institution is not responding to our request, please try again in a moment."
        case .institutionDown: return "This institution is down for an indeterminate amount of time, please try again in a few hours."
        case .institutionNoLongerSupported: return "This institution is no longer supported."
        case .unableToFindCategory: return "Double-check the provided category ID."
        case .typeRequired: return "You must include a type parameter."
        case .invalidType1503: return "The specified type is not supported."
        case .invalidDate: return "Consult the documentation for valid date formats."
        case .productNotFound: return "This product doesn't exist yet"
        case .productNotAvailable: return "This product is not yet available for this institution."
        case .accountNotFound: return "The account ID provided was not correct."
        case .itemNotFound: return "No matching items found; go add an account!"
        case .extractorError: return "We failed to pull the required information from the institution - make sure the user can access their account; we have been notified."
        case .extractorErrorRetry: return "We failed to pull the required information from the institution - resubmit this query."
        case .plaidError: return "An unexpected error has occurred on our systems; we've been notified and are looking into it!"
        case .plannedMaintenance: return "Portions of our system are down for planned maintenance. Please try again in a few hours."
        }
    }
}

extension PlaidError: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        return errorDescription()
    }
    
    public var debugDescription: String {
        return errorDescription()
    }
}
