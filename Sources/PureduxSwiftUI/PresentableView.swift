//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import SwiftUI
import Combine

public protocol PresentableView: View {
    associatedtype Content: View
    associatedtype Props
    associatedtype State
    associatedtype SubState: Equatable
    associatedtype Action

    func props(for substate: SubState, on store: EnvironmentStore<State, Action>) -> Props
    func substate(for state: State) -> SubState
    func content(for props: Props) -> Content
}

public extension PresentableView {
    var body: some View {
        PresentingView<State, SubState, Action, Content>(mapToSubstate: substate, content: content)
    }

    private func content(for substate: SubState, _ store: EnvironmentStore<State, Action>) -> Content {
        content(for: props(for: substate, on: store))
    }
}

public extension PresentableView where State: FalseEquatable, State == SubState {
    func substate(for state: State) -> SubState {
        state
    }
}
