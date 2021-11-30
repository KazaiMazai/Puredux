//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 30.11.2021.
//

import SwiftUI
import PureduxCommon


public struct Options {
    public static var `default` = Options(queue: .main)

    public var queue: PresentationQueue

    public init(queue: PresentationQueue) {
        self.queue = queue
    }
}

public extension Options {
     enum PresentationQueue {
        case notSpecified
        case main
        case queue(DispatchQueue)

        var dispatchQueue: DispatchQueue? {
            switch self {
            case .main:
                return DispatchQueue.main
            case .queue(let queue):
                return queue
            case .notSpecified:
                return nil
            }
        }
    }
}

extension View {
    public static func with<AppState, Action, Props>(
        props: @escaping (AppState, ObservableStore<AppState, Action>) -> Props,
        content: @escaping (Props) -> Self,
        distinctStateChangesBy: Equating<AppState> = .neverEqual,
        presentationOptions: Options = .default) -> some View {

        EnvironmentStorePresentingView(
            props: props,
            content: content,
            distinctStateChangesBy: distinctStateChangesBy.predicate,
            presentationOptions: presentationOptions)
    }

    public static func with<Store, AppState, Action, Props>(
        store: Store,
        props: @escaping (AppState, Store) -> Props,
        content: @escaping (Props) -> Self,
        distinctStateChangesBy: Equating<AppState> = .neverEqual,
        presentationOptions: Options = .default) -> some View

    where
        Store: ObservableStoreProtocol,
        Store.AppState == AppState,
        Store.Action == Action  {

        StorePresentingView(
            store: store,
            props: props,
            content: content,
            distinctStateChangesBy: distinctStateChangesBy.predicate,
            presentationOptions: presentationOptions)
    }
}
