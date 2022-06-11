//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 30.11.2021.
//

import SwiftUI
import PureduxCommon

public enum PresentationQueue {
   case sharedPresentationQueue
   case main
   case serialQueue(DispatchQueue)

   var dispatchQueue: DispatchQueue? {
       switch self {
       case .main:
           return DispatchQueue.main
       case .serialQueue(let queue):
           return queue
       case .sharedPresentationQueue:
           return nil
       }
   }
}

extension View {
    
    public static func withEnvStore<AppState, Action, Props>(
        removeStateDuplicates by: Equating<AppState> = .neverEqual,
        props: @escaping (AppState, PublishingStore<AppState, Action>) -> Props,
        queue: PresentationQueue = .sharedPresentationQueue,
        content: @escaping (Props) -> Self) -> some View {

        EnvironmentStorePresentingView<AppState, Action, Props, Self>(
            props: props,
            content: content,
            removeDuplicates: by.predicate,
            queue: queue)
    }

    public static func with<AppState, Action, Props>(
        store: PublishingStore<AppState, Action>,
        removeStateDuplicates by: Equating<AppState> = .neverEqual,
        props: @escaping (AppState, PublishingStore<AppState, Action>) -> Props,
        queue: PresentationQueue = .sharedPresentationQueue,
        content: @escaping (Props) -> Self) -> some View {

        StorePresentingView(
            store: store,
            props: props,
            content: content,
            removeDuplicates: by.predicate,
            queue: queue)
    }
}
