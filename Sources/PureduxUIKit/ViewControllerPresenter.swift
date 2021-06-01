//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import PureduxStore

public protocol ViewControllerPresenter {
    associatedtype ViewController: PresentableViewController
    associatedtype Store: StoreProtocol

    func props(state: Store.AppState, store: Store) -> ViewController.Props
}
