//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 30.05.2021.
//

import SwiftUI
import Combine
import PureduxCommon

public protocol LocalStorePresentableView: View {
    associatedtype Store: ViewStore

    associatedtype Content: View
    associatedtype Props

    var store: Store { get }

    func props(for state: Store.AppState, on store: Store) -> Props

    func content(for props: Props) -> Content

    var distinctStateChangesBy: Equating<Store.AppState> { get }
}

public extension LocalStorePresentableView {
    var body: some View {
        StorePresentingView(
            store: store,
            props: props,
            content: content,
            distinctStateChangesBy: distinctStateChangesBy.predicate)
    }

    var distinctStateChangesBy: Equating<Store.AppState> {
        .neverEqual
    }
}
