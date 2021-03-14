//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.03.2021.
//

import SwiftUI
import Combine

struct PresentingView<AppState, Action, Props, Content>: View where Content: View {
    @EnvironmentObject private var store: EnvironmentStore<AppState, Action>
    @SwiftUI.State private var observableProps: Props?

    let props: (_ substate: AppState, _ store: EnvironmentStore<AppState, Action>) -> Props
    let content: (_ props: Props) -> Content
    let equatingStates: Equating<AppState>

    var body: some View {
        if let props = observableProps {
            content(props)
                .onReceive(propsPublisher) { observableProps = $0 }
        } else {
            EmptyView()
                .onReceive(propsPublisher) { observableProps = $0 }
                .onAppear { observableProps = props(store.state, store) }
        }
    }

    private var propsPublisher: AnyPublisher<Props, Never> {
        store.stateSubject
            .removeDuplicates(by: equatingStates.predicate)
            .map { props($0, store) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
        
    }
}

