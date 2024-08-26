//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 22/08/2024.
//

import SwiftUI


struct EffectModifier<ViewState, Action>: ViewModifier {
    let store: Store<ViewState, Action>
    let createEffect: (UIStateObserver, Store<ViewState, Action>) -> Void
    
    private class StateObserver: UIStateObserver { }
    
    @State private var stateObserver = StateObserver()
    
    func body(content: Content) -> some View {
        content
            .onAppear { createEffect(stateObserver, store) }
    }
}
