# kotlinx.serialization Rules

- Apply the [platform tags](../SKILL.md#platform-tags) to select applicable rules.

## Declare a private Json property

- Always declare a private property holding a `Json` instance and use it for encoding and decoding; never call the global `Json` object directly.
- Configure the instance for the data format as needed, for example with `namingStrategy = JsonNamingStrategy.SnakeCase` or `ignoreUnknownKeys = true`; neither setting is mandatory.
- Use `private val json = Json` when default settings are sufficient.

### Incorrect

```kotlin
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

fun encodeValues(values: Map<String, String>): String =
    Json.encodeToString(values)

fun decodeValues(text: String): Map<String, String> =
    Json.decodeFromString(text)
```

### Correct

```kotlin
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

private val json = Json

fun encodeValues(values: Map<String, String>): String =
    json.encodeToString(values)

fun decodeValues(text: String): Map<String, String> =
    json.decodeFromString(text)
```

### Optional configuration

- When the data format requires these settings, replace the property declaration with:

```kotlin
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonNamingStrategy

@OptIn(ExperimentalSerializationApi::class)
private val json = Json {
    namingStrategy = JsonNamingStrategy.SnakeCase
    ignoreUnknownKeys = true
}
```

## Use typed models for fixed schemas

- For objects whose field names and types are known at compile time, define typed `@Serializable` models and use them for both serialization and deserialization.
- Do not represent fixed-schema objects with `JsonObject`, `JsonElement`, or dynamic key-value maps; reserve these representations for schema portions whose structure is determined at runtime.

Given JSON object:

```json
{"name": "sample", "count": 3}
```

### Incorrect

```kotlin
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.int
import kotlinx.serialization.json.jsonPrimitive

private val json = Json

data class Item(
    val name: String,
    val count: Int
)

fun parseItem(text: String): Item {
    val item = json.decodeFromString<JsonObject>(text)
    return Item(
        name = item.getValue("name").jsonPrimitive.content,
        count = item.getValue("count").jsonPrimitive.int
    )
}
```

### Correct

```kotlin
import kotlinx.serialization.Serializable
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

@Serializable
data class Item(
    val name: String,
    val count: Int
)

private val json = Json

fun parseItem(text: String): Item =
    json.decodeFromString<Item>(text)
```

## [Android] [JVM] Prefer streams for file I/O

- When encoding JSON to or decoding JSON from a `java.io.File` or `java.nio.file.Path` on JVM, prefer `encodeToStream` / `decodeFromStream` over `encodeToString` / `decodeFromString` with `writeText` / `readText`.
- Opt in with `@OptIn(ExperimentalSerializationApi::class)` on the declarations using the stream APIs.
- Close opened streams with `use`.

### Incorrect

```kotlin
import java.io.File
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

private val json = Json {}

fun writeValues(file: File, values: Map<String, String>) {
    file.writeText(json.encodeToString(values))
}

fun readValues(file: File): Map<String, String> =
    json.decodeFromString(file.readText())
```

### Correct

```kotlin
import java.io.File
import java.nio.file.Path
import kotlin.io.path.inputStream
import kotlin.io.path.outputStream
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.decodeFromStream
import kotlinx.serialization.json.encodeToStream

private val json = Json {}

@OptIn(ExperimentalSerializationApi::class)
fun writeValues(file: File, values: Map<String, String>) {
    file.outputStream().use { output ->
        json.encodeToStream(values, output)
    }
}

@OptIn(ExperimentalSerializationApi::class)
fun readValues(file: File): Map<String, String> =
    file.inputStream().use { input ->
        json.decodeFromStream<Map<String, String>>(input)
    }

@OptIn(ExperimentalSerializationApi::class)
fun writeValues(path: Path, values: Map<String, String>) {
    path.outputStream().use { output ->
        json.encodeToStream(values, output)
    }
}

@OptIn(ExperimentalSerializationApi::class)
fun readValues(path: Path): Map<String, String> =
    path.inputStream().use { input ->
        json.decodeFromStream<Map<String, String>>(input)
    }
```

## References

- [Kotlin documentation: Serialization](https://kotlinlang.org/docs/serialization.html)
- [kotlinx.serialization: Serializable](https://kotlinlang.org/api/kotlinx.serialization/kotlinx-serialization-core/kotlinx.serialization/-serializable/)
- [kotlinx.serialization JSON: JsonObject](https://kotlinlang.org/api/kotlinx.serialization/kotlinx-serialization-json/kotlinx.serialization.json/-json-object/)
- [kotlinx.serialization JSON: decodeFromString](https://kotlinlang.org/api/kotlinx.serialization/kotlinx-serialization-json/kotlinx.serialization.json/-json/decode-from-string.html)
- [kotlinx.serialization JSON: namingStrategy](https://kotlinlang.org/api/kotlinx.serialization/kotlinx-serialization-json/kotlinx.serialization.json/-json-builder/naming-strategy.html)
- [kotlinx.serialization JSON: JsonNamingStrategy.SnakeCase](https://kotlinlang.org/api/kotlinx.serialization/kotlinx-serialization-json/kotlinx.serialization.json/-json-naming-strategy/-builtins/-snake-case.html)
- [kotlinx.serialization JSON: ignoreUnknownKeys](https://kotlinlang.org/api/kotlinx.serialization/kotlinx-serialization-json/kotlinx.serialization.json/-json-builder/ignore-unknown-keys.html)
- [kotlinx.serialization JSON: encodeToStream](https://kotlinlang.org/api/kotlinx.serialization/kotlinx-serialization-json/kotlinx.serialization.json/encode-to-stream.html)
- [kotlinx.serialization JSON: decodeFromStream](https://kotlinlang.org/api/kotlinx.serialization/kotlinx-serialization-json/kotlinx.serialization.json/decode-from-stream.html)
- [kotlinx.serialization: ExperimentalSerializationApi](https://kotlinlang.org/api/kotlinx.serialization/kotlinx-serialization-core/kotlinx.serialization/-experimental-serialization-api/)
