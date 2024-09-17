# Migrating to 2.1.x
 
Minor changes not even breaking ones.

## Overview

Previously, `Injected` was intended to use only for Stores DI which were accessed on the UI on the main thread. So access to it was not syncronized. 

Now Injected is being upgraded for a more broad set of DI use cases, so it's becoming thread safe.

This requires a few changes to be made.

## Injection Changes


Injected now provides a threadsafe access to underlying DI container. 

### InjectionKey and InjectEntry 

InjectionKey which is generated when `@InjectEntry` macro is applied is now private to avoid any possibility of direct access to the underlying storage.

However, this shouldn't be a breaking change because it was never intended to be used directly.
