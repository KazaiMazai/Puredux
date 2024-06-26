//
//  File.swift
//  
//
//  Created by Sergey Kazakov on 12/04/2024.
//

import Foundation

// swiftlint:disable large_tuple identifier_name
extension Store {
    func flatMap<T1, T2, T3>() ->
        Store<(T1, T2, T3), Action>
        where
        State == ((T1, T2), T3) {

        map {
            let ((t1, t2), t3) = $0
            return (t1, t2, t3)
        }
    }

    func flatMap<T1, T2, T3, T4>() ->
        Store<(T1, T2, T3, T4), Action>
        where
        State == (((T1, T2), T3), T4) {

        map {
            let (((t1, t2), t3), t4) = $0
            return (t1, t2, t3, t4)
        }
    }

    func flatMap<T1, T2, T3, T4, T5>() ->
        Store<(T1, T2, T3, T4, T5), Action>
        where
        State == ((((T1, T2), T3), T4), T5) {

        map {
            let ((((t1, t2), t3), t4), t5) = $0
            return (t1, t2, t3, t4, t5)
        }
    }

    func flatMap<T1, T2, T3, T4, T5, T6>() ->
        Store<(T1, T2, T3, T4, T5, T6), Action>
        where
        State == (((((T1, T2), T3), T4), T5), T6) {

        map {
            let (((((t1, t2), t3), t4), t5), t6) = $0
            return (t1, t2, t3, t4, t5, t6)
        }
    }

    func flatMap<T1, T2, T3, T4, T5, T6, T7>() ->
        Store<(T1, T2, T3, T4, T5, T6, T7), Action>
        where
        State == ((((((T1, T2), T3), T4), T5), T6), T7) {

        map {
            let ((((((t1, t2), t3), t4), t5), t6), t7) = $0
            return (t1, t2, t3, t4, t5, t6, t7)
        }
    }

    func flatMap<T1, T2, T3, T4, T5, T6, T7, T8>() ->
        Store<(T1, T2, T3, T4, T5, T6, T7, T8), Action>
        where
        State == (((((((T1, T2), T3), T4), T5), T6), T7), T8) {

        map {
            let (((((((t1, t2), t3), t4), t5), t6), t7), t8) = $0
            return (t1, t2, t3, t4, t5, t6, t7, t8)
        }
    }

    func flatMap<T1, T2, T3, T4, T5, T6, T7, T8, T9>() ->
        Store<(T1, T2, T3, T4, T5, T6, T7, T8, T9), Action>
        where
        State == ((((((((T1, T2), T3), T4), T5), T6), T7), T8), T9) {

        map {
            let ((((((((t1, t2), t3), t4), t5), t6), t7), t8), t9) = $0
            return (t1, t2, t3, t4, t5, t6, t7, t8, t9)
        }
    }

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

extension StateStore {
    func flatMap<T1, T2, T3>() ->
        Store<(T1, T2, T3), Action>
        where
        State == ((T1, T2), T3) {

        strongStore().flatMap()
    }

    func flatMap<T1, T2, T3, T4>() ->
        Store<(T1, T2, T3, T4), Action>
        where
        State == (((T1, T2), T3), T4) {

        strongStore().flatMap()
    }

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

    func flatMap<T1, T2, T3, T4, T5, T6, T7>() ->
        Store<(T1, T2, T3, T4, T5, T6, T7), Action>
        where
        State == ((((((T1, T2), T3), T4), T5), T6), T7) {

        strongStore().flatMap()
    }

    func flatMap<T1, T2, T3, T4, T5, T6, T7, T8>() ->
        Store<(T1, T2, T3, T4, T5, T6, T7, T8), Action>
        where
        State == (((((((T1, T2), T3), T4), T5), T6), T7), T8) {

        strongStore().flatMap()
    }

    func flatMap<T1, T2, T3, T4, T5, T6, T7, T8, T9>() ->
        Store<(T1, T2, T3, T4, T5, T6, T7, T8, T9), Action>
        where
        State == ((((((((T1, T2), T3), T4), T5), T6), T7), T8), T9) {

        strongStore().flatMap()
    }

    func flatMap<T1, T2, T3, T4, T5, T6, T7, T8, T9, T10>() ->
        Store<(T1, T2, T3, T4, T5, T6, T7, T8, T9, T10), Action>
        where
        State == (((((((((T1, T2), T3), T4), T5), T6), T7), T8), T9), T10) {

        strongStore().flatMap()
    }
}
// swiftlint:enable large_tuple identifier_name
