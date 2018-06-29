//
//  ARSessionState.swift
//  AR Measure
//
//  Created by udaykanthd on 26/06/18.
//  Copyright © 2018 udaykanthd. All rights reserved.
//

import Foundation
enum ARSessionStateStatus {
    case initialized
    case ready
    case temporarilyUnAvailable
    case failed
    
    var statusDescription: String {
        switch self {
        case .initialized:
            return " Session initialized..."
        case .ready:
            return " Session is ready..."
        case .temporarilyUnAvailable:
            return " Session is temporarily un available..."
        case .failed:
            return " Session failed..."
        }
        
    }
}
