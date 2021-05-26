//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 01.12.2020.
//

import SwiftUI
import Combine
import PureduxCommon

public protocol PresentableView: View {
    associatedtype Content: View
    associatedtype Props
    associatedtype SubState
    associatedtype Store: StoreProtocol

    func props(for state: SubState, on store: ObservableStore<Store>) -> Props

    func content(for props: Props) -> Content

    func substate(for state: Store.AppState) -> SubState

    var distinctStateChangesBy: Equating<SubState> { get }
}

public extension PresentableView {
    var body: some View {
        PresentingView(
            substate: substate,
            props: props,
            content: content,
            distinctStateChangesBy: distinctStateChangesBy.predicate)
    }

    var distinctStateChangesBy: Equating<SubState> {
        .neverEqual
    }
}

public extension PresentableView where SubState == Store.AppState {
    func substate(for state: Store.AppState) -> SubState {
        state
    }
}
