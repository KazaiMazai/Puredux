//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01/09/2024.
//

import XCTest
@testable import Puredux
import SwiftUI
import UIKit

extension Injected {
    @InjectEntry var rootStore = StateStore<Int, Int>(0) { state, action in state += action }
    
}
