//
//  StringProtocol+.swift
//  Exploring-CompositionalLayout
//
//  Created by Safe Tect on 29/11/23.
//

import Foundation

extension StringProtocol {
    var firstUppercased: String {
        return prefix(1).uppercased() + dropFirst()
    }
    
    var displayNicely: String {
        return firstUppercased.replacingOccurrences(of: "_", with: " ")
    }
}
