//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 02.12.2020.
//
 
import Dispatch
import PureduxStore

struct Presenter<State, Action, ViewController> where ViewController: Presentable {

    private let mainQueue = DispatchQueue.main
    private let workerQueue: DispatchQueue

    private weak var viewController: ViewController?
    private let store: Store<State, Action>

    private let prevState: Ref<State?> = Ref(value: nil)

    private let props: (_ state: State, _ store: Store<State, Action>) -> ViewController.Props
    private let isEqual: (State, State) -> Bool

    init(viewController: ViewController,
         store: Store<State, Action>,
         props: @escaping (State, Store<State, Action>) -> ViewController.Props,
         presentationQueue: PresentationQueue,
         removeStateDuplicates isEqual: @escaping (State, State) -> Bool) {

        self.viewController = viewController
        self.store = store
        self.props = props
        self.workerQueue = presentationQueue.dispatchQueue
        self.isEqual = isEqual
    }
}

extension Presenter: PresenterProtocol {
    func subscribeToStore() {
        store.subscribe(observer: asObserver)
    }
}

private extension Presenter {
    var asObserver: Observer<State> {
        Observer { state, handler in
            observe(state: state, complete: handler)
        }
    }

    func observe(state: State, complete: @escaping (ObserverStatus) -> Void) {
        workerQueue.async {
            if isPrevStateEqualTo(state) {
                complete(.active)
                return
            }

            prevState.value = state
            let newProps = props(state, store)

            mainQueue.async { [weak viewController] in
                guard let viewController = viewController else {
                    complete(.dead)
                    return
                }

                viewController.setProps(newProps)
                complete(.active)
            }
        }
    }
}

private extension Presenter {
    func isPrevStateEqualTo(_ state: State) -> Bool {
        guard let prevState = prevState.value else {
            return false
        }

        return isEqual(prevState, state)
    }
}

private extension Presenter {
    final class Ref<T> {
        var value: T

        init(value: T) {
            self.value = value
        }
    }
}
