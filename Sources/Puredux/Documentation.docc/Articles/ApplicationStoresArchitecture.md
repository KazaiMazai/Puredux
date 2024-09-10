# Application Stores Architecture

Puredux allows you to build a hierarchical store tree. This architecture facilitates building applications where state can be shared or isolated, while state mutations remain predictable.

## Overview
Actions are propagated upstream from child stores to the root store,
while state updates flow downstream from the root store to child stores and, ultimately, to store observers.


The store tree hierarchy ensures that business logic is completely decoupled from the UI layer. This allows for a deep, isolated business logic tree while maintaining a shallow UI layer focused solely on its responsibilities.

Make your app driven by business logic, not by the view hierarchy.

## Choosing the Stores hierarchy

Puredux provides flexibility in structuring your app with the following store hierarchy options:

- Single Store
- Multiple Independent Stores
- Multiple Stores Tree

### Single Store

The single store pattern is best suited for very simple applications where the state management requirements are minimal. It consolidates the entire application state into one store. 

However, this approach is not recommended when the app has multiple instances of the same module within the store. 
In this context, a "module" refers to a feature or screen, represented by a pair consisting of a State and a Reducer. Managing multiple instances within a single store can become cumbersome.

### Multiple Independent Stores

This pattern is ideal when you have multiple modules that are completely independent of each other and do not require communication or shared state. 
Each module has its own store, which simplifies state management for isolated components or features. The lack of dependencies between modules also ensures that changes in one module do not affect others, leading to a more modular and maintainable structure.

### Multiple stores tree

The multiple stores tree is the most flexible and scalable store architecture. It is designed to handle complex applications by organizing stores in a hierarchical structure. This approach offers several benefits:

- **Feature scope isolation**: Each feature or module has its own dedicated store, preventing cross-contamination of state.
- **Performance optimization**: Stores can be made pluggable and isolated, reducing the overhead of managing a large, monolithic state and improving performance.
- **Scalable application growth**: You can start with a simple structure and add more stores as your application grows, making this approach sustainable for long-term development.

#### For most applications, the recommended setup is

- A root store to manage shared, global application state
- Individual stores for each screen, ensuring clear separation of concerns

#### For larger applications or more complex use cases, this can evolve into

- A shared root store for common application-wide state
- Separate feature stores to handle specific functionality or domains
- Individual stores for each screen to manage their local state independently

This hierarchical approach allows your application to scale efficiently while maintaining a clean and organized state management strategy.

Here is a tree hierarchy example below.

## Bulding the Tree Hierarchy

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

**Step 3: Feature Two**

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

At this point, we've built an app structure consisting of a shared state, two independent features, and added two screen states to the second feature. We've also connected side effects to them, integrating everything together.

Puredix essentially allows us to build a fully functioning app and control it by dispatching actions—all without the need for an actual UI or even a single mock.

This is a powerful Puredix feature, enabling the testing of interactions between different modules and components of an application to ensure they work correctly at almost any scope: the whole app, a specific feature, or even an individual screen.

For the real app, we would also connect the UI to stores, transforming it into an app with the following architecture:


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


## Stores Interactions Within the Tree

Stores interact with each other within the tree structure according to the following key rules:

- **Actions propagate upstream**: When an action is dispatched from a child store, it travels upward through the tree, reaching each parent store's reducer until the root. This ensures that changes originating in any part of the app are handled consistently, enabling coordinated state management across the entire application.

- **State updates propagate downstream**: Once the root store processes the action and updates the state, the new state is propagated downward through the tree, reaching all child stores. This ensures consistent state updates throughout the app, with changes eventually reaching all observers.

This flow ensures that actions taken at any point in the app are seamlessly reflected across the entire state tree, providing a robust and scalable architecture for managing complex app behavior.
