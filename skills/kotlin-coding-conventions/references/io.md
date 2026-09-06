# Kotlin I/O Rules

- Apply the [platform tags](../SKILL.md#platform-tags) to select applicable rules.

## Managing resources

### Use AutoCloseable for closeable resources

- Use `AutoCloseable` as the contract for resources that require explicit cleanup; never declare resource types as `Closeable` or implement `Closeable`.

#### Incorrect

```kotlin
import java.io.Closeable

interface TextSource : Closeable {
    fun read(): String
}
```

#### Correct

```kotlin
interface TextSource : AutoCloseable {
    fun read(): String
}
```

## Working with files

### [Android] [JVM] Prefer Path over File

- Prefer `java.nio.file.Path` over `java.io.File` for file-system paths.

#### Incorrect

```kotlin
import java.io.File

val directory = File("data")
```

#### Correct

```kotlin
import kotlin.io.path.Path

val directory = Path("data")
```

### [Android] [JVM] Use Kotlin Path extensions

- Use `kotlin.io.path` extensions instead of equivalent `java.nio.file.Files` methods.

#### Incorrect

```kotlin
import java.nio.file.Files
import java.nio.file.Path

fun readContent(path: Path): String = Files.readString(path)
```

#### Correct

```kotlin
import java.nio.file.Path
import kotlin.io.path.readText

fun readContent(path: Path): String = path.readText()
```

### [Android] [JVM] Use the path division operator

- Import `kotlin.io.path.div` and use `/` instead of `Path.resolve(...)` to resolve child paths.

#### Incorrect

```kotlin
import java.nio.file.Path

fun contentPath(directory: Path): Path = directory.resolve("content.txt")
```

#### Correct

```kotlin
import java.nio.file.Path
import kotlin.io.path.div

fun contentPath(directory: Path): Path = directory / "content.txt"
```

## Working with URLs

### [Android] [JVM] Represent URLs with URI

- Use `java.net.URI` to represent URLs in properties, parameters, and return types instead of `String` or `java.net.URL`.

#### Incorrect

```kotlin
import java.net.URL

data class TextEndpoint(val url: String)
data class UrlEndpoint(val url: URL)
```

#### Correct

```kotlin
import java.net.URI

data class Endpoint(val url: URI)

val endpoint = Endpoint(URI("https://example.com/api"))
```

## Java serialization

### [Android] [JVM] Declare and update a random serialVersionUID

- By default, classes implementing `java.io.Serializable`, directly or through inheritance, must declare `@Serial private const val serialVersionUID: Long` in their companion object. Exclude enum classes, whose serialization UID is fixed by Java, and exception classes not intended for Java serialization.
- Replace `<random Long>` in the template with a freshly generated random integer in the `Long` range for each class; never generate the value at runtime.
- Regenerate the value whenever the class undergoes structural changes, such as field or superclass changes; retain it for changes confined to method bodies or formatting.

#### Incorrect

```kotlin
import java.io.Serializable

data class Item(val name: String) : Serializable
```

#### Correct

```text
import java.io.Serial
import java.io.Serializable

data class Item(val name: String) : Serializable {
    private companion object {
        @Serial
        private const val serialVersionUID = <random Long>L
    }
}
```

## References

- [Kotlin standard library: AutoCloseable](https://kotlinlang.org/api/core/kotlin-stdlib/kotlin/-auto-closeable/)
- [Java API: Serializable](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/io/Serializable.html) — serialization contract; random UID generation and regeneration are Technoir Lab policy.
- [Java API: Serial](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/io/Serial.html)
- [Kotlin Java interoperability: Static fields](https://kotlinlang.org/docs/java-to-kotlin-interop.html#static-fields)
- [Java API: URI](https://docs.oracle.com/en/java/javase/25/docs/api/java.base/java/net/URI.html)
- [Kotlin standard library: Path extensions](https://kotlinlang.org/api/core/kotlin-stdlib/kotlin.io.path/)
- [Kotlin standard library: Path.div](https://kotlinlang.org/api/core/kotlin-stdlib/kotlin.io.path/div.html)
- [Kotlin standard library: Path.readText](https://kotlinlang.org/api/core/kotlin-stdlib/kotlin.io.path/read-text.html)
