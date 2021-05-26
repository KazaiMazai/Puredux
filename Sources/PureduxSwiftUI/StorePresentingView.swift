//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 26.05.2021.
//

import SwiftUI
import Combine

struct StorePresentingView<Store, LocalState, Props, Content>: View
    where
    Content: View,
    Store: ViewStore {

    let store: Store

    @State private var currentProps: Props?
    @State private var propsPublisher: AnyPublisher<Props, Never>?

    let substate: (_ state: Store.AppState) -> LocalState
    let props: (_ localState: LocalState, _ store: Store) -> Props
    let content: (_ props: Props) -> Content

    let distinctStateChangesBy: (LocalState, LocalState) -> Bool

    var body: some View {
        content(currentProps ?? propsForCurrentState())
            .onAppear { propsPublisher = makePropsPublisher() }
            .onReceive(propsPublisher ?? makePropsPublisher()) { self.currentProps = $0 }
    }
}

private extension StorePresentingView {
    func propsForCurrentState() -> Props {
        props(substate(store.state), store)
    }

    func makePropsPublisher() -> AnyPublisher<Props, Never> {
        store.statePublisher
            .map { substate($0) }
            .removeDuplicates(by: distinctStateChangesBy)
            .map { props($0, store) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
