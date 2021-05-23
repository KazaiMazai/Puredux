//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import PureduxStore

public protocol ViewControllerPresenter {
    associatedtype ViewController: PresentableViewController
    associatedtype State
    associatedtype Action

    func props(state: State, store: Store<State, Action>) -> ViewController.Props
}
