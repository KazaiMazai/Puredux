//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2020.
//

import UIKit
import Dispatch
import PureduxStore

struct Presenting<State, Action, ViewController> where ViewController: PresentableViewController {
    weak var viewController: ViewController?
    let store: Store<State, Action>

    let map: (_ state: State, _ store: Store<State, Action>) -> ViewController.Props
    let uiQueue: DispatchQueue =  DispatchQueue.main

    private func connect() {
        store.subscribe(observer: asObserver)
    }
}

extension Presenting: Presenter {

}

extension Presenting {
    private func observe(state: State) -> Observer<State>.Status {
        guard let viewController = viewController else {
            return .dead
        }

        let props = map(state, store)
        viewController.render(props: props)

        return .active
    }

    var asObserver: Observer<State> {
        Observer(queue: uiQueue) { state in
            return self.observe(state: state)
        }
    }
}
