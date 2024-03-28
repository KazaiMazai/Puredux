//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import Dispatch

struct Presenter<State, Action>: PresenterProtocol {
    let store: Store<State, Action>
    let observer: Observer<State>
     
    func subscribeToStore() {
        store.subscribe(observer: observer)
    }
}
 
