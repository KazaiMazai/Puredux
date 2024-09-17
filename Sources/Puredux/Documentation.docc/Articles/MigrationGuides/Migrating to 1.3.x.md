# Migrating to 1.3.x

A few breaking changes related to the replacement of StoreObject with a StateStore.

## Store Changes

### Referenced StoreObject
StoreObject used to be a class, StateStore is a struct.

StoreObject that were weakly referenced wll require a fix.
Since is StoreObject now a typealias of StateStore the compiler will point you to all the places that require a fix:

```diff
- let storeObject: StoreObject = ....

- doSomethingWithStore() { [weak storeObject] in
-     storeObject?.dispatch(...)
- }

+ let stateStore: StateStore = ....
+ let store = stateStore.store()
+ doSomethingWithStore() { 
+    store.dispatch(...)
+ }
```

### StoreObject constructor

The following StoreObject's constructor is no longer available. It was not needed except for the cases when you wanted to mock your StoreObject.

It can be fixed by replacing StoreObject with a Store
```diff
- StoreObject(dispatch: { ... }, subscribe: { ... })
+ Store(dispatch: { ... }, subscribe: { ... })
```

