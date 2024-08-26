//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 12/04/2024.
//

import Foundation

// swiftlint:disable large_tuple identifier_name
public extension Store {
    /**
     Flattens the state of the store from a nested tuple to a flat tuple.

     This function transforms the store's state from a nested tuple type `((T1, T2), T3)` to a flat tuple type `(T1, T2, T3)`. 
     The transformation makes it easier to work with the individual components
     of the nested tuple state by bringing all elements to the same level in a flat tuple.

     - Returns: A new `Store` with the flattened state of type `(T1, T2, T3)` and the same action type `Action`.
     - Note: This method is only available when the store's state is a nested tuple of the form `((T1, T2), T3)`. 
     The transformation extracts the inner tuple elements `T1` and `T2` and combines them with `T3` into a flat tuple `(T1, T2, T3)`.
     */
    func flatMap<T1, T2, T3>() ->
        Store<(T1, T2, T3), Action>
        where
        State == ((T1, T2), T3) {

        map {
            let ((t1, t2), t3) = $0
            return (t1, t2, t3)
        }
    }

    /**
     Refer to the  `flatMap<T1, T2, T3>()` documentation
     */
    func flatMap<T1, T2, T3, T4>() ->
        Store<(T1, T2, T3, T4), Action>
        where
        State == (((T1, T2), T3), T4) {

        map {
            let (((t1, t2), t3), t4) = $0
            return (t1, t2, t3, t4)
        }
    }
    
    /**
     Refer to the  `flatMap<T1, T2, T3>()` documentation
     */
    func flatMap<T1, T2, T3, T4, T5>() ->
        Store<(T1, T2, T3, T4, T5), Action>
        where
        State == ((((T1, T2), T3), T4), T5) {

        map {
            let ((((t1, t2), t3), t4), t5) = $0
            return (t1, t2, t3, t4, t5)
        }
    }

    /**
     Refer to the  `flatMap<T1, T2, T3>()` documentation
     */
    func flatMap<T1, T2, T3, T4, T5, T6>() ->
        Store<(T1, T2, T3, T4, T5, T6), Action>
        where
        State == (((((T1, T2), T3), T4), T5), T6) {

        map {
            let (((((t1, t2), t3), t4), t5), t6) = $0
            return (t1, t2, t3, t4, t5, t6)
        }
    }

    /**
     Refer to the  `flatMap<T1, T2, T3>()` documentation
     */
    func flatMap<T1, T2, T3, T4, T5, T6, T7>() ->
        Store<(T1, T2, T3, T4, T5, T6, T7), Action>
        where
        State == ((((((T1, T2), T3), T4), T5), T6), T7) {

        map {
            let ((((((t1, t2), t3), t4), t5), t6), t7) = $0
            return (t1, t2, t3, t4, t5, t6, t7)
        }
    }

    /**
     Refer to the  `flatMap<T1, T2, T3>()` documentation
     */
    func flatMap<T1, T2, T3, T4, T5, T6, T7, T8>() ->
        Store<(T1, T2, T3, T4, T5, T6, T7, T8), Action>
        where
        State == (((((((T1, T2), T3), T4), T5), T6), T7), T8) {

        map {
            let (((((((t1, t2), t3), t4), t5), t6), t7), t8) = $0
            return (t1, t2, t3, t4, t5, t6, t7, t8)
        }
    }

    /**
     Refer to the  `flatMap<T1, T2, T3>()` documentation
     */
    func flatMap<T1, T2, T3, T4, T5, T6, T7, T8, T9>() ->
        Store<(T1, T2, T3, T4, T5, T6, T7, T8, T9), Action>
        where
        State == ((((((((T1, T2), T3), T4), T5), T6), T7), T8), T9) {

        map {
            let ((((((((t1, t2), t3), t4), t5), t6), t7), t8), t9) = $0
            return (t1, t2, t3, t4, t5, t6, t7, t8, t9)
        }
    }

    /**
     Refer to the  `flatMap<T1, T2, T3>()` documentation
     */
    func flatMap<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>() ->
        Store<(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10), Action>
        where
        State == (((((((((T1, T2), T3), T4), T5), T6), T7), T8), T9), T10) {

        map {
            let (((((((((t1, t2), t3), t4), t5), t6), t7), t8), t9), t10) = $0
            return (t1, t2, t3, t4, t5, t6, t7, t8, t9, t10)
        }
    }
}

public extension StateStore {
    /**
     Flattens the state of the store from a nested tuple to a flat tuple.

     This function transforms the store's state from a nested tuple type `((T1, T2), T3)` to a flat tuple type `(T1, T2, T3)`.
     The transformation makes it easier to work with the individual components
     of the nested tuple state by bringing all elements to the same level in a flat tuple.

     - Returns: A new `Store` with the flattened state of type `(T1, T2, T3)` and the same action type `Action`.
     - Note: This method is only available when the store's state is a nested tuple of the form `((T1, T2), T3)`.
     The transformation extracts the inner tuple elements `T1` and `T2` and combines them with `T3` into a flat tuple `(T1, T2, T3)`.
     */
    func flatMap<T1, T2, T3>() ->
        Store<(T1, T2, T3), Action>
        where
        State == ((T1, T2), T3) {

        strongStore().flatMap()
    }

    /**
     Refer to the  `flatMap<T1, T2, T3>()` documentation
     */
    func flatMap<T1, T2, T3, T4>() ->
        Store<(T1, T2, T3, T4), Action>
        where
        State == (((T1, T2), T3), T4) {

        strongStore().flatMap()
    }

    /**
     Refer to the  `flatMap<T1, T2, T3>()` documentation
     */
    func flatMap<T1, T2, T3, T4, T5>() ->
        Store<(T1, T2, T3, T4, T5), Action>
        where
        State == ((((T1, T2), T3), T4), T5) {

        strongStore().flatMap()
    }

    func flatMap<T1, T2, T3, T4, T5, T6>() ->
        Store<(T1, T2, T3, T4, T5, T6), Action>
        where
        State == (((((T1, T2), T3), T4), T5), T6) {

        strongStore().flatMap()
    }

    /**
     Refer to the  `flatMap<T1, T2, T3>()` documentation
     */
    func flatMap<T1, T2, T3, T4, T5, T6, T7>() ->
        Store<(T1, T2, T3, T4, T5, T6, T7), Action>
        where
        State == ((((((T1, T2), T3), T4), T5), T6), T7) {

        strongStore().flatMap()
    }

    /**
     Refer to the  `flatMap<T1, T2, T3>()` documentation
     */
    func flatMap<T1, T2, T3, T4, T5, T6, T7, T8>() ->
        Store<(T1, T2, T3, T4, T5, T6, T7, T8), Action>
        where
        State == (((((((T1, T2), T3), T4), T5), T6), T7), T8) {

        strongStore().flatMap()
    }

    /**
     Refer to the  `flatMap<T1, T2, T3>()` documentation
     */
    func flatMap<T1, T2, T3, T4, T5, T6, T7, T8, T9>() ->
        Store<(T1, T2, T3, T4, T5, T6, T7, T8, T9), Action>
        where
        State == ((((((((T1, T2), T3), T4), T5), T6), T7), T8), T9) {

        strongStore().flatMap()
    }

    /**
     Refer to the  `flatMap<T1, T2, T3>()` documentation
     */
    func flatMap<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>() ->
        Store<(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10), Action>
        where
        State == (((((((((T1, T2), T3), T4), T5), T6), T7), T8), T9), T10) {

        strongStore().flatMap()
    }
}
// swiftlint:enable large_tuple identifier_name
