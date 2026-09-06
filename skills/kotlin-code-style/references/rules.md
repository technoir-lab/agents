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
    private val text: String = input

    internal val isEmpty: Boolean = text.isEmpty()

    val length: Int = text.length

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
        private const val MAX_LENGTH: Int = 80
    }
}
```

### Keep class-associated constants in the companion object

- Declare constants conceptually associated with a class or used primarily by that class inside its companion object, rather than at file top level.

#### Incorrect

```kotlin
private const val MAX_LENGTH: Int = 80

class TextPreview {
    fun format(text: String): String = text.take(MAX_LENGTH)
}
```

#### Correct

```kotlin
class TextPreview {
    fun format(text: String): String = text.take(MAX_LENGTH)

    private companion object {
        private const val MAX_LENGTH: Int = 80
    }
}
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
        const val MAX_LENGTH: Int = 80
    }
}
```

#### Correct

```kotlin
class TextPreview {
    fun format(text: String): String = text.take(MAX_LENGTH)

    private companion object {
        private const val MAX_LENGTH: Int = 80
    }
}
```

## Dependency injection

### Inject dependencies through the constructor

- Receive a class's dependencies through constructor parameters; do not instantiate them inside the class.
- Apply this rule to manual dependency injection and DI frameworks, including Dagger and Metro.

#### Incorrect

```kotlin
class TextNormalizer {
    fun normalize(text: String): String = text.trim()
}

class TextProcessor {
    private val normalizer = TextNormalizer()

    fun process(text: String): String = normalizer.normalize(text)
}

val processor = TextProcessor()
```

#### Correct

```kotlin
class TextNormalizer {
    fun normalize(text: String): String = text.trim()
}

class TextProcessor(private val normalizer: TextNormalizer) {
    fun process(text: String): String = normalizer.normalize(text)
}

val normalizer = TextNormalizer()
val processor = TextProcessor(normalizer)
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

### Use line comments for single-line comments

- Use `// comment` for single-line non-documentation comments; never use block-comment syntax (`/* comment */`).
- For documentation comments, follow [Multi-line KDoc](#multi-line-kdoc).

#### Incorrect

```kotlin
/* Preserve whitespace within the text. */
```

#### Correct

```kotlin
// Preserve whitespace within the text.
```

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

- [Kotlin documentation: Multi-dollar string interpolation](https://kotlinlang.org/docs/strings.html#multi-dollar-string-interpolation)
- [Kotlin standard library: trimIndent implementation](https://raw.githubusercontent.com/JetBrains/kotlin/master/libraries/stdlib/src/kotlin/text/Indent.kt) — whitespace behavior; matching blank-line indentation is Technoir Lab policy.
- [Kotlin documentation: Comments](https://kotlinlang.org/docs/basic-syntax.html#comments) — comment syntax; the single-line requirement is Technoir Lab policy.
- [Kotlin coding conventions: Source file organization](https://kotlinlang.org/docs/coding-conventions.html#source-file-organization) — the single-class default and DTO/domain-model exception are Technoir Lab policy.
- [Android Developers: Fundamentals of dependency injection](https://developer.android.com/training/dependency-injection#fundamentals)
- [Kotlin coding conventions: Directory structure](https://kotlinlang.org/docs/coding-conventions.html#directory-structure) — directory layout; grouping packages by feature is Technoir Lab policy.
- [Kotlin documentation: Named arguments](https://kotlinlang.org/docs/functions.html#named-arguments)
- [Kotlin documentation: Creating instances of classes](https://kotlinlang.org/docs/classes.html#creating-instances-of-classes)
- [Kotlin documentation: Companion objects](https://kotlinlang.org/docs/object-declarations.html#companion-objects) — language syntax; constant placement is Technoir Lab policy.
- [Kotlin coding conventions: Class layout](https://kotlinlang.org/docs/coding-conventions.html#class-layout)
- [Kotlin documentation: Visibility modifiers](https://kotlinlang.org/docs/visibility-modifiers.html)
- [Kotlin coding conventions: Annotations](https://kotlinlang.org/docs/coding-conventions.html#annotations)
- [Kotlin standard library: Suppress](https://kotlinlang.org/api/core/kotlin-stdlib/kotlin/-suppress/)
- [Kotlin documentation: KDoc syntax](https://kotlinlang.org/docs/kotlin-doc.html#kdoc-syntax) — language syntax; the multi-line requirement is Technoir Lab policy.
