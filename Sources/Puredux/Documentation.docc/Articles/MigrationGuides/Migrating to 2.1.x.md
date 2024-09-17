# Migrating to 2.1.x
 
Minor breaking changes

## Overview

Previously, `Injected` was intended to use only for Stores DI which were accessed on the UI on the main thread. So access to it was not syncronized. 

Dependency injection was being upgraded for a more broad set of DI use cases, so it's becoming thread safe.

Now it also provives a bit of separation of concerns for Stores injection and Dependency injection.

## Dependency Injection Changes

### InjectionKey 

`InjectionKey` which was generated when `@InjectEntry` macro was applied became private to avoid any possibility of direct access to the underlying dependency container storage.

`InjectionKey` was renamed to `DependencyKey`


### Injected and InjectEntry replacement for Stores injection

Injected and InjectEntry were renamed:

```diff
-extension Injected {
-   @InjectEntry var rootState = StateStore<AppRootState, Action>(...)  
-}

+extension Stores {
+   @StoreEntry var rootState = StateStore<AppRootState, Action>(...) 
+}
```

