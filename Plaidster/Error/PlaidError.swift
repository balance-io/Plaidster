//
//  PlaidError.swift
//  Plaidster
//
//  Created by Willow Bumby on 2016-01-17.
//  Copyright © 2016 Willow Bumby. All rights reserved.
//

import Foundation

internal enum PlaidError: ErrorType {
    case BadAccessToken
    case CredentialsMissing(String)
    case InvalidCredentials(String)
    case InvalidMFA(String)
    case InstitutionNotAvailable
}

internal struct PlaidErrorCode {
    static let MissingAccessToken = 1000
    static let MissingType = 1001
    static let DisallowedAccessToken = 1003
    static let UnsupportedAccessToken = 1008
    static let InvalidOptionsFormat = 1004
    static let MissingCredentials = 1005
    static let InvalidCredentialsFormat = 1006
    static let UpdateRequired = 1007
    static let InvalidContentType = 1009
    static let MissingClientID = 1100
    static let MissingSecret = 1101
    static let InvalidSecretOrClientID = 1102
    static let UnauthorizedProduct1104 = 1104
    static let BadAccessToken = 1105
    static let BadPublicToken = 1106
    static let MissingPublicToken = 1107
    static let InvalidType1108 = 1108
    static let UnauthorizedProduct1109 = 1109
    static let ProductNotEnabled = 1110
    static let InvalidUpgrade = 1111
    static let AdditionLimitExceeded = 1112
    static let RateLimitExceeded = 1113
    static let UnauthorizedEnvironment = 1114
    static let InvalidCredentials = 1200
    static let InvalidUsername = 1201
    static let InvalidPassword = 1202
    static let InvalidMFA = 1203
    static let InvalidSendMethod = 1204
    static let AccountLocked = 1205
    static let AccountNotSetup = 1206
    static let CountryNotSupported = 1207
    static let MFANotSupported = 1208
    static let InvalidPin = 1209
    static let AccountNotSupported = 1210
    static let BOFAAccountNotSupported = 1211
    static let NoAccounts = 1212
    static let InvalidPatchUsername = 1213
    static let MFAReset = 1215
    static let MFANotRequired = 1218
    static let InstitutionNotAvailable = 1300
    static let UnableToFindInstitution = 1301
    static let InstitutionNotResponding = 1302
    static let InstitutionDown = 1303
    static let UnableToFindCategory = 1501
    static let TypeRequired = 1502
    static let InvalidType1503 = 1503
    static let InvalidDate = 1507
    static let ProductNotFound = 1601
    static let UserNotFound = 1605
    static let AccountNotFound = 1606
    static let ItemNotFound = 1610
    static let ExtractorError = 1700
    static let ExtractorErrorRetry = 1701
    static let PlaidError = 1702
    static let PlannedMaintenance = 1800
}