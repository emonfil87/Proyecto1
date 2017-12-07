//
//  Extensiones.swift
//  ProyectoOne
//
//  Created by Erick Monfil on 06/12/17.
//  Copyright © 2017 Blueicon. All rights reserved.
//

import Foundation
import UIKit

extension UITextField{
    @IBInspectable var placeHolderColor: UIColor? {
        get {
            return self.placeHolderColor
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string:self.placeholder != nil ? self.placeholder! : "", attributes:[NSAttributedStringKey.foregroundColor: newValue!])
        }
    }
}
