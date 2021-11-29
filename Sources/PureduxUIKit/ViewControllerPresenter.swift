//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import PureduxStore
import PureduxCommon
import Dispatch

public protocol ViewControllerPresenter {
    associatedtype ViewController: PresentableViewController
    associatedtype Store: StoreProtocol

    func props(state: Store.AppState, store: Store) -> ViewController.Props

    var distinctStateChangesBy: Equating<Store.AppState> { get }

    func makePresenterWorkerQueue() -> DispatchQueue
}

public extension ViewControllerPresenter {
    var distinctStateChangesBy: Equating<Store.AppState> {
        .neverEqual
    }

    func makePresenterWorkerQueue() -> DispatchQueue {
        DispatchQueue(
            label: "com.puredux.presenter",
            qos: .userInteractive)
    }
}
