# Kotlin Test Style Rules

- Apply the [platform tags](../SKILL.md#platform-tags) to select applicable rules.
- Examples target JVM.
- Assume `TextNormalizer` accepts a `NormalizationRules` interface whose `trimWhitespace` property controls trimming in `normalize(String)`.

## Use descriptive backtick names

- Name test functions with descriptive, space-separated phrases enclosed in backticks; state the expected behavior and relevant condition.

### Incorrect

```kotlin
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

class TextNormalizerTest {
    private val rules = StubNormalizationRules()
    private val normalizer = TextNormalizer(rules)

    @Test
    fun normalizeRemovesSurroundingWhitespace() {
        val text = " text "

        val result = normalizer.normalize(text)

        assertThat(result).isEqualTo("text")
    }
}
```

### Correct

```kotlin
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

class TextNormalizerTest {
    private val rules = StubNormalizationRules()
    private val normalizer = TextNormalizer(rules)

    @Test
    fun `normalize removes surrounding whitespace`() {
        val text = " text "

        val result = normalizer.normalize(text)

        assertThat(result).isEqualTo("text")
    }
}
```

## Keep tests in the same package as their subject

- Declare the test class in the same package as the class under test, within the appropriate test source set.

### Correct

```text
src/main/kotlin/io/technoirlab/example/text/TextNormalizer.kt
src/test/kotlin/io/technoirlab/example/text/TextNormalizerTest.kt
```

- Both files declare `package io.technoirlab.example.text`.

## Keep the subject under test in a private property

- Declare the subject under test and its dependencies as private properties of the test class.
- Initialize dependency properties before the subject and inject them through its constructor.

### Correct

```kotlin
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

class TextNormalizerTest {
    private val rules = StubNormalizationRules()
    private val normalizer = TextNormalizer(rules)

    @Test
    fun `normalize removes surrounding whitespace`() {
        val text = " text "

        val result = normalizer.normalize(text)

        assertThat(result).isEqualTo("text")
    }
}
```

## Organize test bodies as Arrange, Act, Assert

- Order each test body as **Arrange** (prepare inputs and dependencies), **Act** (invoke the behavior under test), then **Assert** (verify the outcome).
- Separate the phases with a blank line.

### Correct

```kotlin
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Test

class TextNormalizerTest {
    private val rules = StubNormalizationRules()
    private val normalizer = TextNormalizer(rules)

    @Test
    fun `normalize removes surrounding whitespace`() {
        val text = " text "

        val result = normalizer.normalize(text)

        assertThat(result).isEqualTo("text")
    }
}
```

## Use AssertJ Core assertions

- Use AssertJ Core for test assertions.
- Only when catching and verifying an exception thrown by a suspend function, use JUnit's Kotlin `org.junit.jupiter.api.assertThrows` instead of `org.assertj.core.api.Assertions.assertThatThrownBy`.

### Correct

```kotlin
import kotlinx.coroutines.test.runTest
import org.assertj.core.api.Assertions.assertThat
import org.assertj.core.api.Assertions.assertThatThrownBy
import org.junit.jupiter.api.Test
import org.junit.jupiter.api.assertThrows

class NameValidationTest {
    @Test
    fun `validateName rejects blank names`() {
        val name = " "

        assertThatThrownBy { validateName(name) }
            .isInstanceOf(IllegalArgumentException::class.java)
            .hasMessage("Name must not be blank")
    }

    @Test
    suspend fun `validateNameAsync rejects blank names`() {
        val name = " "

        val exception = assertThrows<IllegalArgumentException> {
            suspendValidateName(name)
        }

        assertThat(exception).hasMessage("Name must not be blank")
    }
}
```

## Use the most specialized AssertJ assertions

- Use the most specialized AssertJ assertion for the value and condition being tested; assert on the original object instead of manually extracting values or computing conditions that AssertJ can check directly.
- Preserve comparison semantics: AssertJ 3.x `hasContent` ignores newline differences; use `content().isEqualTo(...)` when exact text equality matters. Specify the charset when required by the file format.

### Incorrect

```kotlin
import java.nio.file.Path
import kotlin.io.path.readText
import org.assertj.core.api.Assertions.assertThat

private fun assertOutput(file: Path) {
    assertThat(file.readText()).contains("ready")
    assertThat(file.readText()).isEqualTo("status=ready")
}
```

### Correct

```kotlin
import java.nio.file.Path
import org.assertj.core.api.Assertions.assertThat

private fun assertOutput(file: Path) {
    assertThat(file)
        .content()
        .contains("ready")
    assertThat(file).hasContent("status=ready")
}
```

## Put test annotations first

- Place `@Test` or `@ParameterizedTest` first in a test function's annotation list, before other annotations.

### Incorrect

```kotlin
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Tag
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.ValueSource

class TextNormalizerTest {
    private val rules = StubNormalizationRules()
    private val normalizer = TextNormalizer(rules)

    @Tag("text")
    @Test
    fun `normalize preserves whitespace between words`() {
        val text = " first  second "

        val result = normalizer.normalize(text)

        assertThat(result).isEqualTo("first  second")
    }

    @ValueSource(strings = [" ", "\t", "\n"])
    @ParameterizedTest
    fun `normalize returns empty text for whitespace-only input`(text: String) {
        val result = normalizer.normalize(text)

        assertThat(result).isEmpty()
    }
}
```

### Correct

```kotlin
import org.assertj.core.api.Assertions.assertThat
import org.junit.jupiter.api.Tag
import org.junit.jupiter.api.Test
import org.junit.jupiter.params.ParameterizedTest
import org.junit.jupiter.params.provider.ValueSource

class TextNormalizerTest {
    private val rules = StubNormalizationRules()
    private val normalizer = TextNormalizer(rules)

    @Test
    @Tag("text")
    fun `normalize preserves whitespace between words`() {
        val text = " first  second "

        val result = normalizer.normalize(text)

        assertThat(result).isEqualTo("first  second")
    }

    @ParameterizedTest
    @ValueSource(strings = [" ", "\t", "\n"])
    fun `normalize returns empty text for whitespace-only input`(text: String) {
        val result = normalizer.normalize(text)

        assertThat(result).isEmpty()
    }
}
```

## Annotate code-snippet parameters for IDE highlighting

- Annotate test-helper parameters that accept code snippets with `org.intellij.lang.annotations.Language` so the IDE highlights code passed as string literals.
- Use the snippet's language ID, for example `@Language("kotlin")` for Kotlin code.

### Incorrect

```kotlin
import java.nio.file.Path
import kotlin.io.path.writeText

private fun writeKotlinSource(path: Path, code: String) {
    path.writeText(code)
}
```

### Correct

```kotlin
import java.nio.file.Path
import kotlin.io.path.writeText
import org.intellij.lang.annotations.Language

private fun writeKotlinSource(
    path: Path,
    @Language("kotlin")
    code: String,
) {
    path.writeText(code)
}
```

## References

- [kotlinx.coroutines test: runTest](https://kotlinlang.org/api/kotlinx.coroutines/kotlinx-coroutines-test/kotlinx.coroutines.test/run-test.html)
- [JUnit user guide: Assertions and Kotlin assertion support](https://docs.junit.org/6.1.3/writing-tests/assertions.html)
- [AssertJ API: Path assertions](https://www.javadoc.io/static/org.assertj/assertj-core/3.27.7/org/assertj/core/api/AbstractPathAssert.html)
- [AssertJ Core: Quick start](https://assertj.github.io/doc/#assertj-core-quick-start)
- [IntelliJ IDEA: Annotating language injections](https://www.jetbrains.com/help/idea/using-language-injections.html)
- [JetBrains annotations: Language declaration](https://raw.githubusercontent.com/JetBrains/java-annotations/master/src/jvmMain/java/org/intellij/lang/annotations/Language.java)
- [Kotlin standard library: Path.writeText](https://kotlinlang.org/api/core/kotlin-stdlib/kotlin.io.path/write-text.html)
- [Kotlin coding conventions: Names for test methods](https://kotlinlang.org/docs/coding-conventions.html#names-for-test-methods)
- [JUnit user guide: Annotations](https://docs.junit.org/6.1.3/writing-tests/annotations.html)
