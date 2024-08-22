//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 21/08/2024.
//

import SwiftUI

@available(iOS 13.0, *)
extension View {
    func effect<ViewState, Action>(store: Store<ViewState, Action>,
                removeStateDuplicates: Equating<ViewState> = .neverEqual,
                on dispatchQueue: DispatchQueue,
                perform: @escaping (ViewState) -> Void) -> some View {
       
        modifier(
            EffectViewModifier(
                store: store,
                removeStateDuplicates: removeStateDuplicates,
                dispatchQueue: dispatchQueue,
                perform: perform
            )
        )
    }
}

@available(iOS 13.0, *)
struct EffectViewModifier<ViewState, Action>: ViewModifier {
    let store: Store<ViewState, Action>
    let removeStateDuplicates: Equating<ViewState>?
    let dispatchQueue: DispatchQueue
    
    let perform: (ViewState) -> Void
    
    private class ViewIsAlive { }
    
    @State private var viewIsAlive = ViewIsAlive()
    
    func body(content: Content) -> some View {
        content.onAppear {
            store.effect(viewIsAlive,
                         withDebounce: .uiDebounce,
                         removeStateDuplicates: removeStateDuplicates,
                         on: dispatchQueue) { state in
                
                Effect {
                    perform(state)
                }
            }
        }
    }
}
