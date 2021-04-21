//
//  File.swift
//  
//
//  Created by Лайм HD on 21.04.2021.
//

import Foundation

public extension Error {
    var httpURLRequest: HTTPURLRequest.Error? {
        self as? HTTPURLRequest.Error
    }
    
    
}
