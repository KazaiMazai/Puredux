//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 31/08/2024.
//

import Foundation


final class CancellableObserver {
    private class AnyStateObserver { }

    var observer: AnyObject = AnyStateObserver()

    init(_ observer: AnyObject) {
        self.observer = observer
    }

    init() {
        self.observer = AnyStateObserver()
    }

    func cancel() {
        observer = AnyStateObserver()
    }
}
