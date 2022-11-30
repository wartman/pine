Refactor
--------

The goals of this refactor should be as follows:

- Simplify and Document. The Element class especially has taken on too much cruft.
- Try not to change the user-facing API too much. One exception: I think the distinction between `ImmutableComponent` and `ObserverComponent` has turned out to be useless -- we should just merge them somehow.
- Clean up macro stuff especially -- it was always thrown together.
  - Importantly, make sure you're using stuff that relies on `getType` as little as possible, if at all. Trying to type things is extremely brittle at macro time. If at all possible, use metadata and ComplexTypes.
- Place all code that is not meant to be easily user-accessible in their own sub-packages for organization. 
- Prefer composition over inheritance. Even inside our Element classes. Look for any way to cut down on our OOP bloat.
