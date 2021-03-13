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
    associatedtype AppState
    associatedtype SubState: Equatable
    associatedtype Action

    func props(for substate: SubState, on store: EnvironmentStore<AppState, Action>) -> Props
    func substate(for state: AppState) -> SubState
    func content(for props: Props) -> Content

    var distinctStateBy: Equating<SubState> { get }
}

public extension PresentableView {
    var body: some View {
        PresentingView(distinctStateBy: equatingState,
                       props: propsForAppState,
                       content: content)
    }

    var distinctStateBy: Equating<SubState> {
        .neverEqual
    }
}

public extension PresentableView where AppState == SubState {
    func substate(for state: AppState) -> SubState {
        state
    }
}

private extension PresentableView {
    func propsForAppState(for state: AppState, on store: EnvironmentStore<AppState, Action>) -> Props {
        props(for: substate(for: state), on: store)
    }


    var equatingState: Equating<AppState> {
        Equating<AppState> {
            distinctStateBy.equals(substate(for: $0), substate(for: $1))
        }
    }
}
