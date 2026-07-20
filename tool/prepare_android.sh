#!/usr/bin/env bash
# Regenerates the (gitignored) Android platform folder and applies the fixes
# the plugin set needs. Run by both local Docker builds and CI so the two
# stay identical.
set -euo pipefail

flutter create --platforms=android --org com.fontostudio --project-name fonto_studio .

APP_GRADLE="android/app/build.gradle.kts"
ROOT_GRADLE="android/build.gradle.kts"

# App module: compile against API 36.
sed -i 's/compileSdk = flutter.compileSdkVersion/compileSdk = 36/' "$APP_GRADLE"

# Some plugins hardcode a lower compileSdk in their own build.gradle
# (file_picker 8.x and share_plus pin 34), but flutter_plugin_android_lifecycle
# requires consumers to compile against 36. Force every Android subproject up to
# 36 after it is evaluated, via reflection so it works across AGP versions.
if ! grep -q "fonto: force compileSdk" "$ROOT_GRADLE"; then
cat >> "$ROOT_GRADLE" <<'KOTLIN'

// fonto: force compileSdk 36 on all Android subprojects (incl. plugins that
// hardcode 34) — flutter_plugin_android_lifecycle requires it. The existing
// evaluationDependsOn(":app") means some projects are already evaluated by the
// time this runs, so configure those immediately and defer the rest.
subprojects {
    val forceSdk: () -> Unit = {
        val androidExt = extensions.findByName("android")
        if (androidExt != null) {
            val setter = androidExt.javaClass.methods.firstOrNull {
                it.name == "setCompileSdk" && it.parameterCount == 1
            }
            if (setter != null) {
                setter.invoke(androidExt, 36)
            } else {
                runCatching {
                    androidExt.javaClass
                        .getMethod("compileSdkVersion", Int::class.javaPrimitiveType)
                        .invoke(androidExt, 36)
                }
            }
        }
    }
    if (state.executed) forceSdk() else afterEvaluate { forceSdk() }
}
KOTLIN
fi

echo "prepare_android: patched. app compileSdk ->"
grep -nE "compileSdk|targetSdk|minSdk" "$APP_GRADLE" || true
echo "prepare_android: root override appended ->"
grep -n "force compileSdk 36" "$ROOT_GRADLE" || true
