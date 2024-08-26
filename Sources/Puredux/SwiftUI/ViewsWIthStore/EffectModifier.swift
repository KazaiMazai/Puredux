//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 22/08/2024.
//

import SwiftUI


struct EffectModifier<ViewState, Action>: ViewModifier {
    let store: Store<ViewState, Action>
    let createEffect: (AnyObject, Store<ViewState, Action>) -> Void
    
    private class ViewIsAlive { }
    
    @State private var viewIsAlive = ViewIsAlive()
    
    func body(content: Content) -> some View {
        content
            .onAppear { createEffect(viewIsAlive, store) }
    }
}
