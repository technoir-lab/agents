# Android Projects

## [Android] Module configuration

- Select the application or library convention using [plugin selection](project-setup.md#plugin-selection) and configure [plugin loading](project-setup.md#plugin-loading), including Google's plugin repository.
- Reuse the supplied Android Gradle Plugin `9.4.1` and its built-in Kotlin support; do not also apply `org.jetbrains.kotlin.android`.
- Configure convention-owned properties through `androidApplication` or `androidLibrary`; they are copied to Android's DSL during `finalizeDsl`.
- Set `packageName` explicitly for a stable Android namespace; its default replaces hyphens and underscores in the project name with dots.
- Reuse Java 21 source/target compatibility and core-library desugaring; the convention adds `com.android.tools:desugar_jdk_libs`.

| Property | Scope | Default |
|---|---|---|
| `compileSdk` | Application and library | `37` |
| `minSdk` | Application and library | `26` |
| `applicationId` | Application only | Required; no default |
| `targetSdk` | Application only | `37` |
| `versionCode` | Application only | `1` |
| `versionName` | Application only | `project.version.toString()` |

Minimal application module after declaring and loading the plugin in settings:

```kotlin
plugins {
    id("io.technoirlab.conventions.android-application")
}

androidApplication {
    applicationId = "com.example.app"
    packageName = "com.example.app"
}
```

## [Android] Build features

- Keep features disabled unless required; configure them inside the module extension's `buildFeatures` block.

| When | Configure | Behavior |
|---|---|---|
| Generate Parcelable implementations | `parcelize = true` | Applies the Kotlin Parcelize compiler plugin |
| Generate serializers | [Serialization setup](dependencies-and-serialization.md#serialization) | Applies the serialization compiler plugin; declare format libraries separately |
| Share Android library test support | `testFixtures = true` in `androidLibrary.buildFeatures` | Enables Android test fixtures; see [publication behavior](publishing.md) |
| Generate build-time constants | `buildConfig { buildConfigField("VALUE", "value") }` | Enables Android's native Java BuildConfig generator when fields are present |

- For BuildConfig, `variant` names an existing Android build type, such as `debug` or `release`; omit it for `defaultConfig` fields. It does not name a Kotlin source set or a combined flavor/build-type variant.
- Supported BuildConfig value types are `String`, `Boolean`, `Int`, `Long`, `Float`, and `Double`; only strings may be null. The shared provider overload omits a field when its provider is absent.
- The inherited `abiValidation` and `redacted` switches are not wired by the Android plugins; do not rely on them to enable those features.

## [Android] Tests, publishing, and limits

- Use the [Android unit-test guidance](testing-and-quality.md#android-local-unit-tests) for JUnit and coverage.
- Use the supplied [Android library publication](publishing.md) for the release AAR, source and documentation artifacts, and enabled fixtures.
- These conventions do not configure KMP Android targets, Compose, product flavors, signing, or baseline profiles. Configure required capabilities separately; do not combine these AGP application/library plugins with the Kotlin Multiplatform plugin in the same module.

## References

- [Android conventions usage and supported scope](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/android-conventions/README.md)
- [Convention dependency versions](https://github.com/technoir-lab/convention-plugins/blob/main/gradle/libs.versions.toml)
- [Android application extension](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/android-conventions/src/api/kotlin/io/technoirlab/conventions/android/api/AndroidApplicationExtension.kt)
- [Android common extension](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/android-conventions/src/api/kotlin/io/technoirlab/conventions/android/api/AndroidCommonExtension.kt)
- [Android library feature API](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/android-conventions/src/api/kotlin/io/technoirlab/conventions/android/api/AndroidLibraryBuildFeatures.kt)
- [Common package-name defaults](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/internal/CommonExtensionImpl.kt)
- [Android application defaults](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/android-conventions/src/main/kotlin/io/technoirlab/conventions/android/internal/AndroidApplicationExtensionImpl.kt)
- [Android SDK defaults](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/android-conventions/src/main/kotlin/io/technoirlab/conventions/android/internal/AndroidCommonExtensionImpl.kt)
- [Android application feature wiring](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/android-conventions/src/main/kotlin/io/technoirlab/conventions/android/AndroidApplicationConventionPlugin.kt)
- [Android library feature wiring](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/android-conventions/src/main/kotlin/io/technoirlab/conventions/android/AndroidLibraryConventionPlugin.kt)
- [Android DSL finalization, desugaring, and release variant](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/android-conventions/src/main/kotlin/io/technoirlab/conventions/android/configuration/Android.kt)
- [Android BuildConfig generation and supported values](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/android-conventions/src/main/kotlin/io/technoirlab/conventions/android/configuration/BuildConfigGeneration.kt)
- [BuildConfig field and provider overloads](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/api/kotlin/io/technoirlab/conventions/common/api/BuildConfigSpec.kt)
- [Android Developers: Built-in Kotlin and KMP compatibility](https://developer.android.com/build/migrate-to-built-in-kotlin)
