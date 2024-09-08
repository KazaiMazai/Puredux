# Migrating to 2.0.x
 
There are big changes taking place.


## Store Changes

### Store and StoreProtocol Breaking Changes

`Store<State, Action>`  was renamed to `AnyStoreStore<State, Action>`

```diff
- Store<State, Action> 
+ AnyStore<State, Action>

```

`StoreProtocol<State, Action>`  was renamed to `Store<State, Action>`
 
```diff
- any StoreProtocol<State, Action> 
+ any Store<State, Action>

```

### Store's store() method was removed

Store method was deprecated previouisly.
The closest thing to the removed `store()` method is `eraseToAnyStore()`. 

```diff
let store = StateStore(...)

- store.store()
+ store.eraseToAnyStore()

### Observer Changes

There were breaking changes in the `Observer<T>` API. 
Due to store internals changes, observer doesn't need to have a callback closure and now returns its status in a sync manner 


```diff
- let observer = Observer { state, completeHandler in
-    // handle new state
-    return completeHandler(.active)
- }

+ let observer = Observer { state in
+    // handle new state
+    return .active
+ } 
```