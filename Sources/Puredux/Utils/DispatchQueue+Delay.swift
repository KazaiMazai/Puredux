//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 18/04/2024.
//

import Foundation

extension DispatchQueue {
    func asyncAfter(delay: TimeInterval?, execute workItem: DispatchWorkItem) {
        guard let delay, delay > .zero else {
            async(execute: workItem)
            return
        }
        
        asyncAfter(deadline: .now() + delay, execute: workItem)
    }
}
