# Object Declarations

- Apply the [platform tags](../SKILL.md#platform-tags) to select applicable rules.
- These restrictions govern declarations authored in Technoir Lab projects; they are project policy, not Kotlin limitations.
- Use regular classes for services and states or strategies that implement behavior, including stateless implementations. Follow the [dependency injection rules](rules.md#dependency-injection); not every class instance needs injection.
- Allow named `object`, `data object`, and `companion object` declarations only for the roles below. Statelessness, convenience, fewer allocations, eager startup, or an application-wide lifetime do not qualify; regular classes can gain constructor dependencies without replacing singleton access sites.

## Allowlist

| Role | Form and limits |
|---|---|
| Constants | Use a companion for [class-associated constants](rules.md#keep-class-associated-constants-in-the-companion-object); use a named object only for a cohesive namespace without a related class. Allow only `const val` or immutable `val` constants with deterministic, dependency-free initialization. No services, mutable contents, environment reads, I/O, or methods. |
| Payload-free sealed value | Use `data object` for a value, event, or result case, without services, mutable state, or behavior. States that perform transitions do not qualify. |
| Identity token | Use an object or companion for a key/marker contract such as `CoroutineContext.Key<T>`, with only identity and type association. No service behavior or mutable state; prefer a value or enum when singleton identity is unnecessary. |
| Required compiler, platform, or existing interoperability contract | Keep only required members and identify the exact contract in a comment or KDoc. Use explicit inputs or delegate behavior to ordinary classes. Optional framework examples and convenience APIs do not establish necessity. |

- `val` prevents reassignment, not mutation. Caches, registries, clients, dispatchers, and resource owners are not constants.
- Companion factories and utilities require a contract exception even when dependency-free; otherwise use constructors, top-level functions with explicit inputs, or injected factory classes.

### Values and keys

```kotlin
// ReadResult.kt
sealed interface ReadResult

data class TextRead(val text: String) : ReadResult

data object EndOfInput : ReadResult
```

```kotlin
// RequestId.kt
import kotlin.coroutines.AbstractCoroutineContextElement
import kotlin.coroutines.CoroutineContext

class RequestId(val value: String) : AbstractCoroutineContextElement(Key) {
    companion object Key : CoroutineContext.Key<RequestId>
}
```

- Compare data objects with `==`, not `===`; do not use them as identity keys.

## Dependencies and lifetime

- An object declaration defines a class and its singleton instance together. A DI-scoped singleton is an ordinary instance reused by its owner within a graph or lifetime; it need not be global or unique across graphs.
- Share class instances through [dependency injection](rules.md#inject-dependencies-through-the-constructor), not companion `INSTANCE` fields.
- Inject a substitutable abstraction when replacement is needed. Consumers receiving an interface can substitute implementations even when production supplies an object. Direct singleton access or its concrete type prevents ordinary substitution; a scope annotation alone does not enable it. Service objects remain prohibited because their own dependencies cannot be constructor-injected and their lifetime cannot belong to individual graphs or tests.
- Library-owned objects are outside this declaration policy. Inject one when it is a [replaceable collaborator](rules.md#distinguish-collaborators-from-implementation-details), wrapping global-only APIs in an adapter. Constants, value cases, keys, and pure functions need no service injection.
- Named objects initialize thread-safely on first access; later operations and mutable contents are not thereby thread-safe. They guarantee neither eager startup, permanent physical memory residency, nor persistence across process restarts. Initialize services explicitly when startup requires it and retain them through their lifetime owner.
- [JVM] Companions initialize with their enclosing class. Loading differs from initialization; reading an inlined `const val` does not initialize the class. Singleton identity is local to the defining class loader; classes can be unloaded when that loader is reclaimable.

## Contract examples

| Contract | Allowed declaration and boundary |
|---|---|
| [Android] Custom Parcelize serializer selected by `@WriteWith<P>` | `object P : Parceler<T>`: the compiler requires an object. Limit it to conversion using supplied values and parcels. |
| [Android] Handwritten `Parcelable` | `companion object CREATOR : Parcelable.Creator<T>`, or a companion exposing a creator through `@JvmField`. The contract requires a non-null public static `CREATOR` field; Parcelize can generate it. |
| [JVM] Existing Java/reflection API requiring a static member on a particular Kotlin class | Use a companion with `@JvmStatic` or `@JvmField` as appropriate. Static access alone is insufficient: top-level functions already compile to static methods on a file facade. |
| Kotlin/JS external class with static members | A companion inside the `external class` describes members of the external constructor. It does not create an application service. |

- Necessity depends on the chosen integration contract. Constants, sealed values, and identity keys are permitted modeling choices with alternatives. Leave generated declarations to their generator; they do not authorize handwritten service objects.

## Anonymous object expressions

- `object : Interface { ... }` creates an instance each time the expression is evaluated. Use it for local adapters, callbacks, and test doubles, capturing explicit inputs or already-injected dependencies.
- Prefer a lambda for a functional interface when sufficient; use a named class when an implementation is reused or needs its own constructor dependencies.
- Do not acquire hidden global services or store behavior in a global anonymous-object property to bypass the policy.

## References

- [Kotlin: Object declarations and expressions](https://kotlinlang.org/docs/object-declarations.html) — forms, equality, and initialization; the allowlist is Technoir Lab policy.
- [Kotlin: Property names](https://kotlinlang.org/docs/coding-conventions.html#property-names) — immutable constants.
- [Android Developers: Dependency injection](https://developer.android.com/training/dependency-injection#fundamentals) — explicit dependencies and substitution.
- [Metro: Scopes](https://zacsweers.github.io/metro/latest/scopes/) — instance reuse within a graph.
- [Kotlin: CoroutineContext.Key](https://kotlinlang.org/api/core/kotlin-stdlib/kotlin.coroutines/-coroutine-context/-key/)
- [Kotlin: AbstractCoroutineContextElement](https://kotlinlang.org/api/core/kotlin-stdlib/kotlin.coroutines/-abstract-coroutine-context-element/)
- [Kotlin: ContinuationInterceptor.Key](https://kotlinlang.org/api/core/kotlin-stdlib/kotlin.coroutines/-continuation-interceptor/-key/) — companion key example.
- [Kotlin: Calling Kotlin from Java](https://kotlinlang.org/docs/java-to-kotlin-interop.html) — file facades and static members.
- [Java Language Specification: Class initialization](https://docs.oracle.com/javase/specs/jls/se25/html/jls-12.html#jls-12.4.1)
- [Java Language Specification: Class unloading](https://docs.oracle.com/javase/specs/jls/se25/html/jls-12.html#jls-12.7)
- [Android Developers: Parcelable](https://developer.android.com/reference/android/os/Parcelable) — `CREATOR` contract.
- [Android Developers: Parcelize](https://developer.android.com/kotlin/parcelize) — generated implementations.
- [Kotlin compiler: Parcelize annotation checker](https://raw.githubusercontent.com/JetBrains/kotlin/master/plugins/parcelize/parcelize-compiler/parcelize.k2/src/org/jetbrains/kotlin/parcelize/fir/diagnostics/FirParcelizeAnnotationChecker.kt) — object requirement for `@WriteWith`.
- [Kotlin: JavaScript static members](https://kotlinlang.org/docs/js-interop.html#declare-static-members-of-a-class)
