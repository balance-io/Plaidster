//
//  PlaidsterError.swift
//  Plaidster
//
//  Created by Willow Bumby on 2016-01-17.
//  Copyright © 2016 Willow Bumby. All rights reserved.
//

import Foundation

internal enum JSONError: ErrorType {
    case EncodingFailed
    case DecodingFailed
    case Empty
}

internal enum PlaidsterError: ErrorType {
    case UnknownException
}