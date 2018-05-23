## [0.5.2] - 24.05.2018
* Fix dependencies issue

## [0.5.0] - 15.05.2018
* Removed `TArg` from `Prgram` and `Init`. All arguments for `init` function should be captured in closure.
* Changed `Subscription` mechamism.
    - new `TSub` type-parameter for `Program`. It's object for holding and managing subscription (like `StreamSubscription`).
    - `subscription` function is now called right after every `update`.
    - `subscription` is not `Cmd` anymore.
* Added new mechamism for reacting on application lifecycle events.

## [0.0.2] - 23.04.2018

* New API. Now every Program is a stateful Widget.
* Added Multiprogram app support (Programs composition, built-in Flutter navigation)


## [0.0.1] - 11.04.2018

* Initial implementation.
