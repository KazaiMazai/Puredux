# Migrating 1.2.x

Puredux was refactored from a set of packages to a single monorepository.

These changes will require a few updates.

## Change the Package

If you were using any of the packages individually:

- PureduxStore
- PureduxSwiftUI
- PureduxUIKit

You should update them to Puredux:

In Xcode 11.0 or later select File > Swift Packages > Add Package Dependency... and add Puredux repository URL:

```
https://github.com/KazaiMazai/Puredux
```

Remove the individual repositories:

```
- https://github.com/KazaiMazai/PureduxUIKit
 
- https://github.com/KazaiMazai/PureduxSwiftUI
  
- https://github.com/KazaiMazai/PureduxStore
```

## Fix Imports

Find and relace all the occurences of:

```swift
import PureduxSwiftUI
```

```
import PureduxUIKit
```

```
import PireduxStore

```

on 

```swift
import Puredux

```
