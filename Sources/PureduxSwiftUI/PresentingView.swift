//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.03.2021.
//

import SwiftUI
import Combine

struct PresentingView<AppState, SubState, Action, Props, Content>: View where Content: View, SubState: Equatable {
    @EnvironmentObject private var store: EnvironmentStore<AppState, Action>
    @State private var observableProps: Props?

    let substate: (_ state: AppState) -> SubState
    let props: (_ substate: SubState, _ store: EnvironmentStore<AppState, Action>) -> Props
    let content: (_ props: Props) -> Content

    var body: some View {
        content(latestProps)
            .onReceive(propsPublisher) { observableProps = $0 }
    }

    private var latestProps: Props {
        observableProps ?? propsFor(state: store.state, store: store)
    }

    private func propsFor(state: AppState, store: EnvironmentStore<AppState, Action>) -> Props {
        props(substate(state), store)
    }

    private var propsPublisher: AnyPublisher<Props, Never> {
        store.stateSubject
            .map(substate)
            .removeDuplicates()
            .map { props($0, store) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
