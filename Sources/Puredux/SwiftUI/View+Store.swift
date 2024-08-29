//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 29/08/2024.
//

import SwiftUI

extension View {
   func subscribe<State, Action, Props>(store: any StoreProtocol<State, Action>,
                                        props: @escaping (State, Store<State, Action>) -> Props,
                                        presentationQueue: DispatchQueue = .sharedPresentationQueue,
                                        removeStateDuplicates equating: Equating<State>? = nil,
                                        observe: @escaping (Props) -> Void) -> some View {
       withObserver { observer in
           observer.subscribe(
               store: store.getStore(),
               props: props,
               presentationQueue: presentationQueue,
               removeStateDuplicates: equating,
               observe: observe
           )
       }
   }
   
   func subscribe<State, Action, Props>(_ store: any StoreProtocol<State, Action>,
                                        props: @escaping (State, @escaping Dispatch<Action>) -> Props,
                                        presentationQueue: DispatchQueue = .sharedPresentationQueue,
                                        removeStateDuplicates equating: Equating<State>? = nil,
                                        observe: @escaping (Props) -> Void) -> some View {
       withObserver { observer in
           observer.subscribe(
               store.getStore(),
               props: props,
               presentationQueue: presentationQueue,
               removeStateDuplicates: equating,
               observe: observe
           )
       }
   }
   
   func subscribe<State, Action>(_ store: any StoreProtocol<State, Action>,
                                 removeStateDuplicates equating: Equating<State>? = nil,
                                 observe: @escaping (State) -> Void) -> some View {
       withObserver { observer in
           observer.subscribe(
               store.getStore(),
               removeStateDuplicates: equating,
               observe: observe
           )
       }
   }
   
   func subscribe<State, Action>(_ store: any StoreProtocol<State, Action>,
                                 removeStateDuplicates equating: Equating<State>? = nil,
                                 observe: @escaping (State, Dispatch<Action>) -> Void) -> some View {
       
       withObserver { observer in
           observer.subscribe(
               store.getStore(),
               removeStateDuplicates: equating,
               observe: observe
           )
       }
   }
   
   func subscribe<State, Action>(store: any StoreProtocol<State, Action>,
                                 removeStateDuplicates equating: Equating<State>? = nil,
                                 observe: @escaping (State, Store<State, Action>) -> Void) -> some View {
       
       withObserver { observer in
           observer.subscribe(
               store: store.getStore(),
               removeStateDuplicates: equating,
               observe: observe
           )
       }
   }
}
