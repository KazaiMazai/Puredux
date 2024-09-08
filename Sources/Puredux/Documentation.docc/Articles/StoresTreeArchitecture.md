# Stores Tree Architecture

Puredux allows you to build a hierarchical store tree. This architecture facilitates building applications where state can be shared or isolated, while state mutations remain predictable.

## Overview
Actions are propagated upstream from child stores to the root store,
while state updates flow downstream from the root store to child stores and, ultimately, to store observers.


The store tree hierarchy ensures that business logic is completely decoupled from the UI layer. This allows for a deep, isolated business logic tree while maintaining a shallow UI layer focused solely on its responsibilities.

Make your app driven by business logic, not by the view hierarchy.

## Bulding the Hierarchy

**Step 1: Root Store**

```swift
let root = StateStore<AppState, Action>(AppState()) { state, action in 
    state.reduce(action) 
} 
.effect(\.effectState) { appState, dispatch in
    Effect {
        // ...
    }
}
```

**Step 2: Feature One**

```swift
let featureOne = root.with(FeatureOne()) { appState, action in 
    state.reduce(action) 
}
.effect(\.effectState) { appState, dispatch in
    Effect {
        // ...
    }
}
```

**tep 2: Feature Two**

```swift

let featureTwo = root.with(FeatureTwo()) { state, action in
    state.reduce(action)
}
.effect(\.effectState) { appState, dispatch in
    Effect {
        // ...
    }
}

let screenOne = featureTwo.with(ScreenOne()) { state, action in 
    state.reduce(action) 
}
.effect(\.effectState) { appState, dispatch in
    Effect {
        // ...
    }
}

let screenTwo = featureTwo.with(ScreenTwo()) { state, action in 
    state.reduce(action) 
}

```
## Tree Hierarchy

We can connect the tree above to the UI we will end up with the following hierarchy:


```text
              +----------------+    +--------------+
              | AppState Store | -- | Side Effects |
              +----------------+    +--------------+
                    |
                    |
       +------------+-------------------------+
       |                                      |
       |                                      |
       |                                      |
       |                                      |
 +------------------+                     +------------------+    +--------------+
 | FeatureOne Store |                     | FeatureTwo Store | -- | Side Effects |
 +------------------+                     +------------------+    +--------------+
    |         |                               |
 +----+  +--------------+                     |
 | UI |  | Side Effects |        +------------+------------+
 +----+  +--------------+        |                         |
                                 |                         |
                                 |                         |
                                 |                         |
                          +-----------------+         +-----------------+
                          | ScreenOne Store |         | ScreenTwo Store |
                          +-----------------+         +-----------------+
                             |         |                 |
                          +----+  +--------------+    +----+
                          | UI |  | Side Effects |    | UI |
                          +----+  +--------------+    +----+
```
*/
