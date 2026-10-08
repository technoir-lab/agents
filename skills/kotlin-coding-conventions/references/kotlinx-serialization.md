# kotlinx.serialization Rules

- Apply the [platform tags](../SKILL.md#platform-tags) to select applicable rules.

## Own serialization format configuration

- Keep a fixed serialization contract's format and configuration in a private property of its serializer class, as a [stable implementation detail](rules.md#distinguish-collaborators-from-implementation-details). Use that property for encoding and decoding; avoid direct global calls and file-level or companion configuration.
- Inject the format only when the API delegates configuration or lifetime ownership to the caller, not solely for testing. Test the serializer's public behavior with its real configuration, including field names, defaults, and unknown fields; substitute the application serializer in consumer tests.
- Create each serializer once per application or DI scope and [inject it](rules.md#inject-dependencies-through-the-constructor) into consumers, so its format and caches are reused; do not create serializers or formats per operation. `Json` is immutable and thread-safe; confirm other formats' thread safety before sharing them across threads.
- Apply this ownership rule across formats, using the project's chosen library and configuration API:

| Format | Example |
|---|---|
| JSON | kotlinx.serialization `Json` |
| YAML | kotaml `Yaml` |
| XML | xmlutil `XML` |

- The `ItemSerializer` examples use this model:

```kotlin
// Item.kt
import kotlinx.serialization.Serializable

@Serializable
data class Item(
    val displayName: String,
    val count: Int
)
```

### Incorrect: caller controls a fixed contract

```kotlin
// ItemSerializer.kt
import kotlinx.serialization.json.Json

class ItemSerializer(private val json: Json) {
    fun encodeItem(item: Item): String = json.encodeToString(item)

    fun decodeItem(text: String): Item = json.decodeFromString(text)
}
```

### Correct

```kotlin
// ItemSerializer.kt
import kotlinx.serialization.json.Json

class ItemSerializer {
    private val json = Json

    fun encodeItem(item: Item): String = json.encodeToString(item)

    fun decodeItem(text: String): Item = json.decodeFromString(text)
}
```

### Optional configuration

- Use `Json` for defaults or `Json { ... }` for required settings. For example, configure the property in `ItemSerializer` as follows; neither setting is mandatory:

```kotlin
// ItemSerializer.kt
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonNamingStrategy

class ItemSerializer {
    @OptIn(ExperimentalSerializationApi::class)
    private val json = Json {
        namingStrategy = JsonNamingStrategy.SnakeCase
        ignoreUnknownKeys = true
    }

    // encodeItem and decodeItem as above
}
```

## Use typed models for fixed schemas

- Use typed `@Serializable` models for encoding and decoding known field names and types. Reserve `JsonObject`, `JsonElement`, and dynamic maps for schema portions determined at runtime.
- Both examples decode `{"displayName":"sample","count":3}` into the `Item` model above.

### Incorrect

```kotlin
// ItemSerializer.kt
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.JsonObject
import kotlinx.serialization.json.int
import kotlinx.serialization.json.jsonPrimitive

class ItemSerializer {
    private val json = Json

    fun decodeItem(text: String): Item {
        val item = json.decodeFromString<JsonObject>(text)
        return Item(
            displayName = item.getValue("displayName").jsonPrimitive.content,
            count = item.getValue("count").jsonPrimitive.int
        )
    }
}
```

### Correct

```kotlin
// ItemSerializer.kt
import kotlinx.serialization.json.Json

class ItemSerializer {
    private val json = Json

    fun decodeItem(text: String): Item = json.decodeFromString<Item>(text)
}
```

## [Android] [JVM] Prefer streams for file I/O

- For JSON in `java.io.File` or `java.nio.file.Path`, prefer `encodeToStream` / `decodeFromStream` over string conversion with `writeText` / `readText`.
- Opt in on declarations using the stream APIs and close streams with `use`.

### Incorrect

```kotlin
import java.nio.file.Path
import kotlin.io.path.readText
import kotlin.io.path.writeText
import kotlinx.serialization.json.Json

class ValuesFileSerializer {
    private val json = Json

    fun writeValues(path: Path, values: Map<String, String>) {
        path.writeText(json.encodeToString(values))
    }

    fun readValues(path: Path): Map<String, String> =
        json.decodeFromString(path.readText())
}
```

### Correct

```kotlin
import java.nio.file.Path
import kotlin.io.path.inputStream
import kotlin.io.path.outputStream
import kotlinx.serialization.ExperimentalSerializationApi
import kotlinx.serialization.json.Json
import kotlinx.serialization.json.decodeFromStream
import kotlinx.serialization.json.encodeToStream

class ValuesFileSerializer {
    private val json = Json

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
}
```

## References

- [kotlinx.serialization: SerialFormat](https://kotlinlang.org/api/kotlinx.serialization/kotlinx-serialization-core/kotlinx.serialization/-serial-format/)
- [kotaml: Usage samples](https://github.com/Heapy/kotaml#usage-samples)
- [xmlutil: Format configuration](https://github.com/pdvrieze/xmlutil#format)
- [kotlinx.serialization: Json](https://kotlinlang.org/api/kotlinx.serialization/kotlinx-serialization-json/kotlinx.serialization.json/-json/) — serializer ownership is Technoir Lab policy.
- [kotlinx.serialization guide: Json configuration](https://github.com/Kotlin/kotlinx.serialization/blob/master/docs/json.md#json-configuration) — configuration, thread safety, and reuse.
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
