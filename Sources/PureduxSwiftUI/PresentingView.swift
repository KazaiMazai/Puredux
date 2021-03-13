//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import SwiftUI
import Combine


public protocol PresentingView: View {
    associatedtype Content: View
    associatedtype Props
    associatedtype State
    associatedtype SubState: Equatable
    associatedtype Action

    func props(for substate: SubState, on store: EnvironmentStore<State, Action>) -> Props
    func substate(for state: State) -> SubState
    func content(for props: Props) -> Content
}

public extension PresentingView {
    var body: some View {
        ConnectedView<State, SubState, Action, Content>(mapToSubstate: substate, content: content)
    }

    private func content(for substate: SubState, _ store: EnvironmentStore<State, Action>) -> Content {
        content(for: props(for: substate, on: store))
    }
}

private struct ConnectedView<State, SubState, Action, V: View>: View where SubState: Equatable {
    @EnvironmentObject private var store: EnvironmentStore<State, Action>
    @SwiftUI.State private var substate: SubState?

    let mapToSubstate: (_ state: State) -> SubState
    let content: (_ state: SubState, _ store: EnvironmentStore<State, Action>) -> V

    private var substatePublisher: AnyPublisher<SubState, Never> {
        store.stateSubject
            .map(mapToSubstate)
            .removeDuplicates()
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }

    var body: some View {
        content(substate ?? mapToSubstate(store.state), store)
            .onReceive(substatePublisher) { substate = $0 }
    }
}
