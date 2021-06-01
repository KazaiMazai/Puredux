//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import PureduxStore
import PureduxCommon

public protocol ViewControllerPresenter {
    associatedtype ViewController: PresentableViewController
    associatedtype Store: StoreProtocol

    func props(state: Store.AppState, store: Store) -> ViewController.Props

    var distinctStateChangesBy: Equating<Store.AppState> { get }
}

public extension ViewControllerPresenter {
    var distinctStateChangesBy: Equating<Store.AppState> {
        .neverEqual
    }
}
