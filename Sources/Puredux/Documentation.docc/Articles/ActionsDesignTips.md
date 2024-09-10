# Actions Design Tips

Actions design examples and tips

## Overview

Puredux is very flexible in how actions are defined.

The examples below illustrate three different ways to define actions:

- Actions using a protocol
- Actions as an enum
- A combination of both

## Action using a protocol

Actions as a protocol can be defined the following way:

```swift
protocol Action {
    // Define specific actions in your app by conforming to this protocol
}
```

Then, all app actions can be defined as structs conforming to the protocol:

```swift
struct IncrementCounter: Action {
    // ...
}
```

In this case, the reducer would look like this:

```swift
mutating func reduce(_ action: Action) {
    switch action {
    case let action as IncrementCounter:
        // ...
    default:
        break
    }
}
```

### Pros

- Simple, yet flexible actions design
- Side effects with `AsyncAction`s 

### Cons

- Addition overhead related to type casting of actions in reducers

## Action as an enum

Actions as an enum can be defined like this:

```swift
enum Action {
    case incrementCounter
}
```

In this case, the reducer would look like this:

```swift
mutating func reduce(_ action: Action) {
    switch action {
    case .incrementCounter:
        // ...
    default:
        break
    }
}
```

### Pros

- Low-cost in terms of performance due to enum usage

### Cons

- No support for side effects with `AsyncAction`
- Scaling might be tricky in large applications

In larger apps, actions can be broken down into global and feature-specific actions:

```swift
enum AppActions {
    case featureOne(FeatureOneActions)
    case featureTwo(FeatureTwoActions)
}
```

## Action as an enum behind a protocol:

Taking the best of the two worlds:

```swift
protocol Action { }

enum FeatureOneActions: Action {
    case incrementCounter
}
```

In this case, the reducer would look like this:

```swift
mutating func reduce(_ action: Action) {
    switch action {
    case let action as FeatureOneActions:
        switch action {
            // ...
        }
    default:
        break
    }
}
```
