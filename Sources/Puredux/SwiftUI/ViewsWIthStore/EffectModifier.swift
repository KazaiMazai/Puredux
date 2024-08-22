//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 22/08/2024.
//

import SwiftUI

@available(iOS 13.0, *)
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
