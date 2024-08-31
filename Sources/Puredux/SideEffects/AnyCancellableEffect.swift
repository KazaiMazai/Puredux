//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 31/08/2024.
//

import Foundation

class AnyCancellableEffect {
    class EffectStateObserver { }
     
    var observer: AnyObject = EffectStateObserver()
    
    init(_ observer: AnyObject) {
        self.observer = observer
    }
    
    init() {
        self.observer = EffectStateObserver()
    }
    
    func cancel() {
        observer = EffectStateObserver()
    }
}
