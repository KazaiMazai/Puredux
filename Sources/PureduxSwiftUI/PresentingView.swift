//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 13.03.2021.
//

import SwiftUI
import Combine

struct PresentingView<State, SubState, Action, Props, V: View>: View where SubState: Equatable {
    @EnvironmentObject private var store: EnvironmentStore<State, Action>
    @SwiftUI.State private var props: Props?

    let mapToSubstate: (_ state: State) -> SubState
    let mapToProps: (_ substate: SubState, _ store: EnvironmentStore<State, Action>) -> Props
    let content: (_ props: Props) -> V

    var body: some View {
        content(props ?? propsFor(state: store.state, store: store))
            .onReceive(propsSubject) { props = $0 }
    }

    private func propsFor(state: State, store: EnvironmentStore<State, Action>) -> Props {
        mapToProps(mapToSubstate(state), store)
    }

    private var propsSubject: AnyPublisher<Props, Never> {
        store.stateSubject
            .map(mapToSubstate)
            .removeDuplicates()
            .map { mapToProps($0, store) }
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
}
