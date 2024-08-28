//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 21/08/2024.
//

import SwiftUI
import Dispatch
import Combine


struct StoreView<ViewState, Action, Props, Content: View>: View {
    let store: Store<ViewState, Action>
    let props: (ViewState, @escaping Dispatch<Action>) -> Props
    let content: (_ props: Props) -> Content
    
    private(set) var removeStateDuplicates: Equating<ViewState>?
    private(set) var presentationQueue: DispatchQueue = PresentationQueue.sharedPresentationQueue.dispatchQueue
    
    @State private var currentProps: Props?

    var body: some View {
        makeContent()
            .effect(on: store,
                    withDelay: .uiDebounce,
                    removeStateDuplicates: removeStateDuplicates,
                    on: presentationQueue) { state in
               
                Effect {
                    let props = props(state, store.dispatch)
                    DispatchQueue.main.async { currentProps = props }
                }
            }
    }
}


extension StoreView {
    @ViewBuilder
    func makeContent() -> some View {
        if let props = currentProps {
            content(props)
        } else {
            Color.clear
        }
    }
}


extension StoreView {
     
    func removeStateDuplicates(_ equating: Equating<ViewState>) -> Self {
        var selfCopy = self
        selfCopy.removeStateDuplicates = equating
        return selfCopy
    }
 
    func usePresentationQueue(_ queue: PresentationQueue) -> Self {
        var selfCopy = self
        selfCopy.presentationQueue = queue.dispatchQueue
        return selfCopy
    }
}


extension StoreView {
    init(_ store: Store<ViewState, Action>,
         props: @escaping (ViewState, @escaping Dispatch<Action>) -> Props,
         content: @escaping (Props) -> Content) {
        self.store = store
        self.props = props
        self.content = content
    }
}


extension StoreView where Props == (ViewState, Dispatch<Action>)  {
     
    init(_ store: Store<ViewState, Action>,
         content: @escaping (Props) -> Content) {
        self.store = store
        self.props = { state, store in (state, store) }
        self.content = content
    }
}
