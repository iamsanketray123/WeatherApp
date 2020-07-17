//
//  HelperMethods.swift
//  WeatherApp
//
//  Created by Sanket Ray on 7/18/20.
//  Copyright © 2020 Sanket Ray. All rights reserved.
//

import UIKit

let errorMessage = "Something went wrong. Please try again later!"

extension UIColor {
    static func rgb(_ red : CGFloat,_ green: CGFloat,_ blue: CGFloat, _ alpha: CGFloat = 1.0) -> UIColor {
        return UIColor(red: red/255, green: green/255, blue: blue/255, alpha: alpha)
    }
}

class Alert {
    
    class func showBasic(title : String? , message: String, vc : UIViewController, style: UIAlertController.Style = .alert) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: style)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        vc.present(alert, animated: true)
    }
    
}

func stringify(json: Any, prettyPrinted: Bool = false) -> String {
    var options: JSONSerialization.WritingOptions = []
    if prettyPrinted {
        options = JSONSerialization.WritingOptions.prettyPrinted
    }
    
    do {
        let data = try JSONSerialization.data(withJSONObject: json, options: options)
        if let string = String(data: data, encoding: String.Encoding.utf8) {
            return string
        }
    } catch {
        print(error)
    }
    
    return String()
}

