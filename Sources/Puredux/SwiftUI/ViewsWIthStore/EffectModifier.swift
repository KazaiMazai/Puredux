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

struct StateObserverModifier: ViewModifier {
    private class StateObserver: UIStateObserver {}
    let with: (UIStateObserver) -> Void
    
    @State private var observer = StateObserver()
    
    func body(content: Content) -> some View {
        content
            .onAppear { with(observer) }
    }
}
 
//
//struct WithCancellables: ViewModifier {
//    let perform: (inout Set<CancellableEffect>) -> Void
//    
//    @State private var cancelalbles = Set<CancellableEffect>()
//    
//    func body(content: Content) -> some View {
//        content
//            .onAppear { with(&cancelalbles) }
//    }
//}
 
