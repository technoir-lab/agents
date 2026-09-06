# Build Features

## Shared feature switches

- Configure features inside the selected module extension's `buildFeatures` block.
- Do not enable optional build features unless needed by the module's current requirements; do not enable them speculatively or copy unused feature switches from examples.
- Preserve convention defaults unless a module requirement calls for a change; shared feature switches default to `false`, except the Gradle plugin ABI default below.

| When | Use | Provided behavior |
|---|---|---|
| A library exposes an API whose compatibility must be tracked | `abiValidation = true` | Enables Kotlin ABI validation and attaches its check to `check` |
| Configure the [redaction library](tech-stack.md#redaction) | `redacted = true` | Applies the compiler plugin; annotate the relevant declarations using its API |
| Build-time values must be available to source code | `buildConfig { buildConfigField("VALUE", "value") }` | Generates BuildConfig only when fields are declared, using the module's `packageName` |
| Only one source set needs a generated value | `buildConfigField("VALUE", "value", variant = "test")` | Restricts the field to the matching source set |
| BuildConfig values come from Gradle providers | The `buildConfigField` provider overload | Keeps the value provider-backed; an absent provider omits the field |
| Serializable models need generated serializers | [Serialization setup](dependencies-and-serialization.md#serialization) | Uses the convention's serialization feature |

## ABI baselines

- [Gradle] ABI validation us enabled by default for Gradle plugin modules.
- [JVM] For regular JVM application/library modules, enable it when API compatibility is a project requirement; these modules default to disabled.
- [KMP] For KMP application/library modules, enable it when API compatibility is a project requirement; these modules default to disabled.
- After intentional API changes, run `./gradlew :module:updateKotlinAbi` and review the generated files under `api/`.
- Use `./gradlew :module:checkKotlinAbi` to verify the baseline; resolve unintended API changes before updating it.
- For additional KMP switches, read [multiplatform features](multiplatform.md).

## References

- [Shared feature defaults](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/internal/CommonBuildFeaturesImpl.kt)
- [Gradle plugin feature defaults](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/main/kotlin/io/technoirlab/conventions/gradle/plugin/internal/GradlePluginBuildFeaturesImpl.kt)
- [BuildConfig generation](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/configuration/BuildConfigGeneration.kt)
- [BuildConfig field DSL](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/api/kotlin/io/technoirlab/conventions/common/api/BuildConfigSpec.kt)
- [Redacted feature wiring](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/configuration/Redacted.kt)
- [JVM compiler, BOM, and ABI configuration](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/common-conventions/src/main/kotlin/io/technoirlab/conventions/common/configuration/Kotlin.kt)
- [KMP targets, hierarchy, BOMs, ABI, and C interop](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/kotlin-multiplatform-conventions/src/main/kotlin/io/technoirlab/conventions/kotlin/multiplatform/configuration/KotlinMultiplatform.kt)
- [ABI baseline functional test](https://github.com/technoir-lab/convention-plugins/blob/main/conventions/gradle-plugin-conventions/src/functionalTest/kotlin/io/technoirlab/conventions/gradle/plugin/GradlePluginConventionPluginFunctionalTest.kt)
