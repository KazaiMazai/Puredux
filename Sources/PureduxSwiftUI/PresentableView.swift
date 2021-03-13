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

    var distinctStateBy: Equating<SubState> { get }
}

public extension PresentableView {
    var body: some View {
        PresentingView(distinctStateBy: equatingState,
                       props: propsForState,
                       content: content)
    }

    var distinctStateBy: Equating<SubState> {
        .neverEqual
    }
}

public extension PresentableView where State == SubState {
    func substate(for state: State) -> SubState {
        state
    }
}

private extension PresentableView {
    func propsForState(for state: State, on store: EnvironmentStore<State, Action>) -> Props {
        props(for: substate(for: state), on: store)
    }


    var equatingState: Equating<State> {
        Equating<State> {
            distinctStateBy.equals(substate(for: $0), substate(for: $1))
        }
    }
}
