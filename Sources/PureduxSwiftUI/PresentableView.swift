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
    associatedtype Action
    associatedtype Substate

    func props(for state: Substate, on store: EnvironmentStore<AppState, Action>) -> Props

    func content(for props: Props) -> Content

    func substate(for state: AppState) -> Substate

    var stateEquating: Equating<Substate> { get }
}

public extension PresentableView {
    var body: some View {
        PresentingView(substate: substate,
                       props: props,
                       content: content,
                       stateEquatingPredicate: stateEquating.predicate)
    }

    var stateEquating: Equating<Substate> {
        .neverEqual
    }
}

public extension PresentableView where Substate == AppState {
    func substate(for state: AppState) -> Substate {
        state
    }
}
