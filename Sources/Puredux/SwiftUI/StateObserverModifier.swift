//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 22/08/2024.
//

import SwiftUI

extension View {
    func withObserver(_ observer: @escaping (UIStateObserver) -> Void) -> some View {
        modifier( StateObserverModifier(with: observer))
    }
}

struct StateObserverModifier: ViewModifier {
    private class StateObserver: UIStateObserver {}
    
    let with: (UIStateObserver) -> Void
    
    @State private var observer = StateObserver()
    
    func body(content: Content) -> some View {
        content
            .onAppear { with(observer) }
    }
}
  
