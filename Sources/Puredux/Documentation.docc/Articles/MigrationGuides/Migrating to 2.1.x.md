# Migrating to 2.1.x
 
Dependency Injection Feature and minor not so breaking changes

## Overview

- Swift tools min requirement bump to 5.10
- Dependency Injection Feature

## Swift Tools v5.10 

Minimum supported Swift version is now 5.10

## Dependency Injection Changes

Previously, Injected was intended for use only with Stores DI that were accessed on the main thread in the UI. Consequently, access to it was not synchronized.

Dependency injection has been upgraded to support a broader range of use cases and is now thread-safe.

Additionally, there is now a clearer separation of concerns between Stores injection and general Dependency Injection.

Read more in the <doc:DependencyInjection>.

### InjectionKey 

`InjectionKey` which was generated when `@InjectEntry` macro was applied became private to avoid any possibility of direct access to the underlying dependency container storage.

`InjectionKey` was renamed to `DependencyKey` and `StoreInjectionKey` depending on `@DependencyEntry` or `@StoreEntry` macro is used.


### Injected and InjectEntry replacement for Stores injection

Injected and InjectEntry were renamed:

```diff
-extension Injected {
-   @InjectEntry var rootState = StateStore<AppRootState, Action>(...)  
-}

+extension SharedStores {
+   @StoreEntry var rootState = StateStore<AppRootState, Action>(...) 
+}
```

