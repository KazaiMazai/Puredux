//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.03.2021.
//

import SwiftUI
import Combine

struct PresentingView<AppState, Action, Substate, Props, Content>: View where Content: View {
    @EnvironmentObject private var store: EnvironmentStore<AppState, Action>

    @State private var latestProps: Props?
    @State private var propsPublisher: AnyPublisher<Props, Never>?

    let substate: (_ state: AppState) -> Substate
    let props: (_ substate: Substate, _ store: EnvironmentStore<AppState, Action>) -> Props
    let content: (_ props: Props) -> Content
    
    let stateEquatingPredicate: (Substate, Substate) -> Bool

    var body: some View {
        content(latestProps ?? makeProps())
            .onAppear { propsPublisher = makePropsPublisher() }
            .onReceive(propsPublisher ?? makePropsPublisher()) { self.latestProps = $0 }
    }
}

private extension PresentingView {
    func makeProps() -> Props {
        props(substate(store.state), store)
    }

    func makePropsPublisher() -> AnyPublisher<Props, Never> {
        store.stateSubject
            .map(substate)
            .removeDuplicates(by: stateEquatingPredicate)
            .map { props($0, store) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}

