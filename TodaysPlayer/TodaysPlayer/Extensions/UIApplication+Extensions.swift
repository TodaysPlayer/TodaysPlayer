//
//  UIApplication+Ext.swift
//  TodaysPlayer
//
//  Created by 최용헌 on 10/28/25.
//

import UIKit

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
