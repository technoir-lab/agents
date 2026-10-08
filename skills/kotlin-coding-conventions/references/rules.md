# Kotlin Style Rules

- Scope: projects within Technoir Lab GitHub organization.
- Group rules by topic; include a directive and, where applicable, incorrect and correct Kotlin examples.

## General rules

### Respect project EditorConfig

- Respect the project's `.editorconfig` settings that apply to the Kotlin files being created or edited.

## Source code organization

### Package classes by feature

- Organize packages by feature; keep each feature's related models, services, and helpers together in its package or subpackages rather than in global packages grouped by technical role.

#### Correct

```text
src/main/kotlin/io/technoirlab/example/
├── search/
│   ├── SearchQuery.kt
│   ├── SearchResult.kt
│   └── SearchService.kt
└── export/
    ├── ExportOptions.kt
    ├── ExportResult.kt
    └── ExportService.kt
```

### Keep one top-level class per file

- Declare at most one top-level class per file.
- Allow multiple top-level classes only in files that aggregate closely related data transfer objects (DTOs) or domain models.

#### Incorrect

```kotlin
// Search.kt
class SearchService
class SearchIndex
```

#### Correct

```kotlin
// SearchService.kt
class SearchService
```

```kotlin
// SearchIndex.kt
class SearchIndex
```

#### Allowed model aggregation

```kotlin
// SearchModels.kt
data class SearchQuery(val text: String)
data class SearchResult(val matches: List<String>)
```

### Order class declarations by kind and visibility

- Order declarations within a class as follows:

  1. Private properties.
  2. Internal properties.
  3. Public properties.
  4. Initializer blocks (`init {}`).
  5. Public methods.
  6. Internal methods.
  7. Private methods and member extension functions.
  8. Public nested classes.
  9. Internal nested classes.
  10. Companion object.

- Keep closely related declarations together within each group while preserving the group order.
- Separate visibility groups with a blank line.
- Preserve initialization dependencies and behavior when reordering properties and initializer blocks.
- This order overrides the official Kotlin class-layout convention.

#### Example

```kotlin
class TextBuffer(input: String) {
    private val text = input

    internal val isEmpty = text.isEmpty()

    val length = text.length

    init {
        require(length <= MAX_LENGTH) { "Text exceeds maximum length" }
    }

    fun snapshot(): Snapshot = Snapshot(normalizedText())

    internal fun state(): State = State(text)

    private fun normalizedText(): String = text.trimmed()
    private fun String.trimmed(): String = trim().take(MAX_LENGTH)

    class Snapshot(val text: String)

    internal class State(val text: String)

    private companion object {
        private const val MAX_LENGTH = 80
    }
}
```

### Keep class-associated constants in the companion object

- Declare constants related to a class or used primarily by it inside that class's companion object.
- Apply this placement rule to both `const val` and `val` constants named in `UPPER_SNAKE_CASE`.
- Declare top-level constants only when they have no related class, including constants associated with top-level functions.
- Constant holders must meet the [object allowlist](objects.md#allowlist); a `val` referencing a service or mutable contents is not a constant.

#### Incorrect

```kotlin
private const val MAX_LENGTH = 80
private val DEFAULT_TEXT = "Untitled".uppercase()

class TextPreview {
    fun format(text: String): String = text.ifBlank { DEFAULT_TEXT }.take(MAX_LENGTH)
}
```

#### Correct

```kotlin
class TextPreview {
    fun format(text: String): String = text.ifBlank { DEFAULT_TEXT }.take(MAX_LENGTH)

    private companion object {
        private const val MAX_LENGTH = 80
        private val DEFAULT_TEXT = "Untitled".uppercase()
    }
}
```

#### Allowed

```kotlin
private const val MAX_LENGTH = 80
private val DEFAULT_TEXT = "Untitled".uppercase()

fun formatPreview(text: String): String = text.ifBlank { DEFAULT_TEXT }.take(MAX_LENGTH)
```

## API surface and visibility

### Expose only intentional module API

- Expose declarations to consumers of a Gradle module only when they are intended API; hide implementation details.
- Treat `protected` members accessible to consumer subclasses as API too.
- Example: a helper shared across source files within the module, with no consumer-facing role.

#### Incorrect

```kotlin
class TextNormalizer {
    fun normalize(text: String): String = text.trim()
}
```

#### Correct

```kotlin
internal class TextNormalizer {
    fun normalize(text: String): String = text.trim()
}
```

### Prefer the narrowest feasible visibility

- For each declaration, prefer `private`, then `internal` or `protected`, then `public` (the default), according to required access.
- Use `internal` for access within the Kotlin compilation module; use `protected` for access from the declaring class and subclasses. Neither is universally narrower than the other.
- Restrict constructors and property setters independently when callers need less access to them than to the class or property.
- Example: a class uses a companion-object constant only as an implementation detail.

#### Incorrect

```kotlin
class TextPreview {
    fun format(text: String): String = text.take(MAX_LENGTH)

    companion object {
        const val MAX_LENGTH = 80
    }
}
```

#### Correct

```kotlin
class TextPreview {
    fun format(text: String): String = text.take(MAX_LENGTH)

    private companion object {
        private const val MAX_LENGTH = 80
    }
}
```

## Dependency injection

### Distinguish collaborators from implementation details

- A stable dependency has predictable behavior, an established compatible API, and no need for separate substitution, configuration, or lifetime management in its current role. Having no dependencies alone does not make it stable.
- Construct stable implementation details internally and keep behavior-defining configuration with them; see [serialization format ownership](kotlinx-serialization.md#own-serialization-format-configuration).
- Inject external or replaceable collaborators, including application services, clocks, external-system access, and dependencies whose configuration or lifetime belongs to the caller.
- Internal ownership does not authorize global services or extend the [object allowlist](objects.md#allowlist).

### Inject dependencies through the constructor

- Receive collaborating services through constructor parameters. Assemble them and own their lifetimes at the application entry point or DI graph, manually or with frameworks such as Dagger or Metro; inject a factory or provider for deferred or repeated creation.
- Do not construct collaborators inside consumers, hold services in global properties, or obtain them through singleton names or service locators. Pass services explicitly to top-level functions too.
- Construct owned values, internal state, working collections, and factory products where needed.
- If a framework prevents constructor injection, use its supported injection mechanism at that boundary and constructor injection in delegated classes.
- Follow the [object declaration policy](objects.md) when choosing declaration forms.
- Example: `TextNormalizer` is a replaceable application service selected by the caller.

#### Incorrect

```kotlin
class TextNormalizer {
    fun normalize(text: String): String = text.trim()
}

class TextProcessor {
    private val normalizer = TextNormalizer()

    fun process(text: String): String = normalizer.normalize(text)
}

fun main() {
    val processor = TextProcessor()
    println(processor.process(" text "))
}
```

#### Correct

```kotlin
class TextNormalizer {
    fun normalize(text: String): String = text.trim()
}

class TextProcessor(private val normalizer: TextNormalizer) {
    fun process(text: String): String = normalizer.normalize(text)
}

fun main() {
    val normalizer = TextNormalizer()
    val processor = TextProcessor(normalizer)
    println(processor.process(" text "))
}
```

### Inject only the dependencies the class needs

- Limit constructor dependencies to those the class actually uses.
- Inject required dependencies directly; do not inject an aggregate dependency container merely to access a subset of its services.
- Example assumes existing `TextNormalizer`, `TextEncoder`, and `TextValidator` services; `TextProcessor` needs only `TextNormalizer.normalize(String)`.

#### Incorrect

```kotlin
// Dependencies.kt
class Dependencies(
    val normalizer: TextNormalizer,
    val encoder: TextEncoder,
    val validator: TextValidator,
)

// TextProcessor.kt
class TextProcessor(private val dependencies: Dependencies) {
    fun process(text: String): String = dependencies.normalizer.normalize(text)
}
```

#### Correct

```kotlin
// TextProcessor.kt
class TextProcessor(private val normalizer: TextNormalizer) {
    fun process(text: String): String = normalizer.normalize(text)
}
```

## Properties

### Omit redundant property types

- Omit a property's explicit type when it has an initializer and type inference produces the same type.
- Keep an explicit type when omission would change the declared type or when the compiler requires it.

#### Incorrect

```kotlin
private val text: String = "text"
private var isEnabled: Boolean = false
private val buffer: StringBuilder = StringBuilder()
```

#### Correct

```kotlin
private val text = "text"
private var isEnabled = false
private val buffer = StringBuilder()
```

## Function decomposition

### Extract cohesive functions at semantic boundaries

- Apply this rule both when writing new code and when refactoring existing code.
- When writing new code, structure functions as decomposed from the start; do not write a monolithic function intending to split it later.
- When refactoring existing code, apply **Extract Function** (**Extract Method** for class members) to functions that combine distinct responsibilities or mix levels of abstraction.
- Keep the coordinating function at one level of abstraction: name the stages by their intent and delegate their implementation to cohesive helpers. Use **Split Phase** when successive stages operate on different representations, passing an explicit intermediate result between them.
- Choose extraction boundaries by cohesion and data flow, not an arbitrary line-count limit. Keep compact dispatch branches, cohesive mappings, and builder expressions together unless a helper expresses an independently meaningful operation.
- Prefer private helpers with explicit inputs and return values. If several stages share related mutable state, use a small private context scoped to one invocation; do not promote temporary state to fields on a reusable service or pass unrelated state to helpers.
- When refactoring existing code, preserve observable behavior, evaluation order, side effects, error handling, cleanup order, and resource lifetimes. Keep ordering dependencies visible in the coordinating function.
- When refactoring existing code, verify the refactoring with relevant existing tests and, for deterministic transformations, compare the resulting output.

## Function and constructor calls

### Keep arguments in parameter declaration order

- Pass arguments to functions, methods, and constructors in the order their parameters are declared, including named arguments.
- Preserve evaluation behavior when reordering argument expressions with side effects.

#### Incorrect

```kotlin
fun label(prefix: String, value: String): String = prefix + value

val text = label(value = "item", prefix = "#")
```

#### Correct

```kotlin
fun label(prefix: String, value: String): String = prefix + value

val text = label(prefix = "#", value = "item")
```

### Omit redundant argument names

- Omit argument names that repeat the supplied variable name, such as `foo = foo`, when positional arguments preserve the selected overload and parameter binding.
- Retain names needed to skip defaulted parameters or clarify otherwise ambiguous values.

#### Incorrect

```kotlin
data class Dimensions(val width: Int, val height: Int)

fun dimensions(width: Int, height: Int): Dimensions =
    Dimensions(width = width, height = height)
```

#### Correct

```kotlin
data class Dimensions(val width: Int, val height: Int)

fun dimensions(width: Int, height: Int): Dimensions =
    Dimensions(width, height)
```

## String literals

### Use multi-dollar interpolation for literal dollar signs

- When a string literal would require `${'$'}` to represent a literal dollar sign, use the `$$` interpolation prefix and write the dollar sign directly.
- Update intended interpolations to `$$name` or `$${expression}` to preserve the resulting string.

#### Incorrect

```kotlin
fun template(value: String): String =
    """placeholder=${'$'}value; value=$value"""
```

#### Correct

```kotlin
fun template(value: String): String =
    $$"""placeholder=$value; value=$$value"""
```

### Preserve blank-line indentation with trimIndent

- In multi-line string literals processed with `trimIndent()`, indent blank lines to match the surrounding code block within the literal.
- Do not strip trailing whitespace from these blank lines.

## Comments

### Multi-line KDoc

- Always write KDoc comments as multi-line blocks, even for a single sentence; never use single-line `/** ... */` comments.
- Put `/**` and `*/` on separate lines; prefix each content line with ` *`.

#### Incorrect

```kotlin
/** A named item. */
class Item(val name: String)
```

#### Correct

```kotlin
/**
 * A named item.
 */
class Item(val name: String)
```

## Annotations

### Put annotations on separate lines

- Always put each annotation on its own line, separate from other annotations and the annotated code, including annotations without arguments.

#### Incorrect

```kotlin
@Deprecated("Use Item instead") class LegacyItem
```

#### Correct

```kotlin
@Deprecated("Use Item instead")
class LegacyItem
```

### Keep suppressions narrow

- Put `@Suppress(...)` on the narrowest statement or block that needs it.
- Use a broader declaration or file scope only when the diagnostic cannot be suppressed at a narrower scope.

#### Incorrect

```kotlin
@Suppress("UNCHECKED_CAST")
fun countItems(value: Any): Int {
    val items = value as List<String>
    return items.size
}
```

#### Correct

```kotlin
fun countItems(value: Any): Int {
    @Suppress("UNCHECKED_CAST")
    val items = value as List<String>
    return items.size
}
```

## References

- [Martin Fowler: Extract Function / Extract Method](https://refactoring.com/catalog/extractFunction.html) — refactoring terminology; extraction criteria are Technoir Lab policy.
- [Martin Fowler: Split Phase](https://refactoring.com/catalog/splitPhase.html) — separate processing stages using an intermediate representation.
- [Kotlin documentation: Variable type inference](https://kotlinlang.org/docs/basic-syntax.html#variables) — type inference; omitting redundant property types is Technoir Lab policy.
- [Kotlin documentation: Multi-dollar string interpolation](https://kotlinlang.org/docs/strings.html#multi-dollar-string-interpolation)
- [Kotlin standard library: trimIndent implementation](https://raw.githubusercontent.com/JetBrains/kotlin/master/libraries/stdlib/src/kotlin/text/Indent.kt) — whitespace behavior; matching blank-line indentation is Technoir Lab policy.
- [Kotlin coding conventions: Source file organization](https://kotlinlang.org/docs/coding-conventions.html#source-file-organization) — the single-class default and DTO/domain-model exception are Technoir Lab policy.
- [Android Developers: Fundamentals of dependency injection](https://developer.android.com/training/dependency-injection#fundamentals)
- [van Deursen and Seemann: Stable and volatile dependencies, sections 1.3.1–1.3.2](https://livebook.manning.com/book/dependency-injection-principles-practices-patterns/chapter-1/) — dependency classification; ownership rules are Technoir Lab policy.
- [Kotlin coding conventions: Directory structure](https://kotlinlang.org/docs/coding-conventions.html#directory-structure) — directory layout; grouping packages by feature is Technoir Lab policy.
- [Kotlin documentation: Named arguments](https://kotlinlang.org/docs/functions.html#named-arguments)
- [Kotlin documentation: Creating instances of classes](https://kotlinlang.org/docs/classes.html#creating-instances)
- [Kotlin documentation: Companion objects](https://kotlinlang.org/docs/object-declarations.html#companion-objects) — language syntax; constant placement is Technoir Lab policy.
- [Kotlin coding conventions: Property names](https://kotlinlang.org/docs/coding-conventions.html#property-names) — naming for `const val` and immutable `val` constants.
- [Kotlin coding conventions: Class layout](https://kotlinlang.org/docs/coding-conventions.html#class-layout)
- [Kotlin documentation: Visibility modifiers](https://kotlinlang.org/docs/visibility-modifiers.html)
- [Kotlin coding conventions: Annotations](https://kotlinlang.org/docs/coding-conventions.html#annotations)
- [Kotlin standard library: Suppress](https://kotlinlang.org/api/core/kotlin-stdlib/kotlin/-suppress/)
- [Kotlin documentation: KDoc syntax](https://kotlinlang.org/docs/kotlin-doc.html#kdoc-syntax) — language syntax; the multi-line requirement is Technoir Lab policy.
