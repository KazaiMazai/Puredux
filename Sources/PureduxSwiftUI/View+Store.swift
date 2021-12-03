//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 30.11.2021.
//

import SwiftUI
import PureduxCommon

public enum PresentationQueue {
   case storeQueue
   case main
   case queue(DispatchQueue)

   var dispatchQueue: DispatchQueue? {
       switch self {
       case .main:
           return DispatchQueue.main
       case .queue(let queue):
           return queue
       case .storeQueue:
           return nil
       }
   }
}

struct SomeView<Store: PublishingStore>: View where Store.AppState == String {
    let store: Store

    var body: some View {
        Text.with(
            store: store,
            props: { state, stote in
                state
            },
            queue: .storeQueue,
            content: content
        )
    }

    func content(props: String) -> Text {
        Text(props)
    }
}

extension View {
    
    public static func with<AppState, Action, Props>(
        removeStateDuplicates by: Equating<AppState> = .neverEqual,
        props: @escaping (AppState, AnyPublishingStore<AppState, Action>) -> Props,
        queue: PresentationQueue = .storeQueue,
        content: @escaping (Props) -> Self) -> some View {

        EnvironmentStorePresentingView<AppState, Action, Props, Self>(
            props: props,
            content: content,
            removeDuplicates: by.predicate,
            queue: queue)
    }

    public static func with<Store, AppState, Action, Props>(
        store: Store,
        removeStateDuplicates by: Equating<AppState> = .neverEqual,
        props: @escaping (AppState, Store) -> Props,
        queue: PresentationQueue = .storeQueue,
        content: @escaping (Props) -> Self) -> some View

    where
        Store: PublishingStore,
        Store.AppState == AppState,
        Store.Action == Action  {

        StorePresentingView(
            store: store,
            props: props,
            content: content,
            removeDuplicates: by.predicate,
            queue: queue)
    }
}
