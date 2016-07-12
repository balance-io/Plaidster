//
//  HandlerTypealiases.swift
//  Plaidster
//
//  Created by Willow Bellemore on 2016-01-17.
//  Copyright © 2016 Plaidster. All rights reserved.
//

import Foundation

public typealias AddUserHandler = (accessToken: String?, MFAType: PlaidMFAType?, MFA: [[String: Any]]?, accounts: [PlaidAccount]?, transactions: [PlaidTransaction]?, error: NSError?) -> (Void)
public typealias RemoveUserHandler = (message: String?, error: NSError?) -> (Void)

public typealias SubmitMFAHandler = (MFAType: PlaidMFAType?, MFA: [[String: Any]]?, accounts: [PlaidAccount]?, transactions: [PlaidTransaction]?, error: NSError?) -> (Void)
public typealias FetchUserBalanceHandler = (accounts: [PlaidAccount], error:NSError?) -> (Void)
public typealias FetchUserTransactionsHandler = (transactions: [PlaidTransaction], error:NSError?) -> (Void)
public typealias FetchCategoriesHandler = (categories: [PlaidCategory], error:NSError?) -> (Void)
public typealias FetchInstitutionsHandler = (institutions: [PlaidInstitution], error:NSError?) -> (Void)
public typealias SearchInstitutionsHandler = (institutions: [PlaidSearchInstitution], error:NSError?) -> (Void)