//
//  PlaidSearchInstitution.swift
//  Plaidster
//
//  Created by Benjamin Baron on 2/17/16.
//  Copyright © 2016 Plaidster. All rights reserved.
//

import Foundation
#if os(iOS)
    import UIKit
#else
    import AppKit
#endif

// Institution returned from /institutions/search
// Note that the formatting and even naming of this data is wholey inconsistant
// with the /institutions and /institutions/longtail results hence the different
// model. Tisk, tisk Plaid...
public struct PlaidSearchInstitution {
    
    #if os(iOS)
    public typealias Color = UIColor
    #else
    public typealias Color = NSColor
    #endif
    
    #if os(iOS)
    public typealias Image = UIImage
    #else
    public typealias Image = NSImage
    #endif
    
    public struct Field {
        public var name: String
        public var label: String
        public var type: String
    }
    
    // MARK: Properties
    
    // This API call returns both an id and type field which seem to be equal. So using type for consistency with other API calls
    public var type: String
    
    public var name: String
    // Number of characters to cut off long names
    public var nameBreak: Int?
    
    public var products: [String: Bool]
    
    public var forgottenPasswordUrl: String?
    public var accountLockedUrl: String?
    public var accountSetupUrl: String?
    
    // Anyone's guess what this is for...
    public var video: String?
    
    public var fields: [Field]
    
    // Colors
    public var lightColor: Color?
    public var darkColor: Color?
    public var darkerColor: Color?
    public var primaryColor: Color?
    public var gradient: [Color]?
    
    // Base64 encoded image
    public var logo: String?
    
    // Convenience property to get the NSData representation of the Base64 encoded image (for example
    // to store more compactly in an sqlite database BLOB field rather than TEXT field.
    public var logoData: Data? {
        if let logo = self.logo {
            return Data(base64Encoded: logo, options: NSData.Base64DecodingOptions(rawValue: 0))
        }
        return nil
    }
    
    // Convenience property to get a platform independent image object from the image data
    public var logoImage: Image? {
        if let logoData = self.logoData, let image = Image(data: logoData) {
            return image
        }
        return nil
    }
    
    // MARK: Initialization
    public init(institution: [String: AnyObject]) throws {
        type = try checkType(institution, name: "type")
        
        name = try checkType(institution, name: "name")
        nameBreak = institution["nameBreak"] as? Int
        
        products = try checkType(institution, name: "products")
        
        forgottenPasswordUrl = institution["forgottenPassword"] as? String
        accountLockedUrl = institution["accountLocked"] as? String
        accountSetupUrl = institution["accountSetup"] as? String
        
        video = institution["video"] as? String
        
        fields = [Field]()
        let fieldsDictArray: [[String: String]] = try checkType(institution, name: "fields")
        for fieldDict in fieldsDictArray {
            if let name = fieldDict["name"], let label = fieldDict["label"], let type = fieldDict["type"] {
                let field = Field(name: name, label: label, type: type)
                fields.append(field)
            }
        }
        
        let colors: [String: AnyObject] = try checkType(institution, name: "colors")
        lightColor = colorFromString(colors["light"] as? String)
        darkColor = colorFromString(colors["dark"] as? String)
        darkerColor = colorFromString(colors["darker"] as? String)
        primaryColor = colorFromString(colors["primary"] as? String)
        
        if let gradientStrings = colors["gradient"] as? [String] {
            var gradientColors = [Color]()
            for gradientString in gradientStrings {
                if let color = colorFromString(gradientString) {
                    gradientColors.append(color)
                }
            }
            if gradientColors.count > 0 {
                gradient = gradientColors
            }
        }
        
        logo = institution["logo"] as? String
    }
    
    // Plaid returns colors in a frustratingly inconsistant way. Main institutions (i.e. like 10 of them) return
    // colors in this format: rgba(255,255,255,1) while all other institutions return a hex format like #ffffff
    fileprivate func colorFromString(_ colorString: String?) -> Color? {
        guard let colorString = colorString else {
            return nil
        }
        
        guard colorString.characters.count > 0 else {
            return nil
        }
        
        if colorString.hasPrefix("#") {
            // Decode hex format like #ffffff
            return hexStringToColor(colorString)
            
        } else if colorString.hasPrefix("r") {
            // Decode rgba format like rgba(255,255,255,1)
            return rgbaStringToColor(colorString)
        } else {
            return nil
        }
    }
    
    // Adapted from http://stackoverflow.com/a/27203691/299262
    fileprivate func hexStringToColor(_ hex: String) -> Color? {
        var cString: String = hex.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).uppercased()
        
        if cString.hasPrefix("#") {
            cString = cString.substring(from: cString.characters.index(cString.startIndex, offsetBy: 1))
        }
        
        if cString.characters.count != 6 {
            return nil
        }
        
        var rgbValue: UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return Color(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    fileprivate func rgbaStringToColor(_ rgba: String) -> Color? {
        var cString: String = rgba.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines as CharacterSet)
        
        if cString.hasPrefix("rgba(") {
            cString = cString.substring(from: cString.characters.index(cString.startIndex, offsetBy: 5))
        }
        
        if cString.hasSuffix(")") {
            cString = cString.substring(to: cString.characters.index(cString.endIndex, offsetBy: -1))
        }
        
        let colorValues = cString.components(separatedBy: ",")
        if colorValues.count == 4 {
            let red = (colorValues[0] as NSString).floatValue
            let green = (colorValues[1] as NSString).floatValue
            let blue = (colorValues[2] as NSString).floatValue
            let alpha = (colorValues[3] as NSString).floatValue
            
            return Color(
                red: CGFloat(red) / 255.0,
                green: CGFloat(green) / 255.0,
                blue: CGFloat(blue) / 255.0,
                alpha: CGFloat(alpha)
            )
        }
        
        return nil
    }
}
