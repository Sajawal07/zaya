buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        classpath("com.google.gms:google-services:4.4.0")
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")

    val applyNamespaceFix = { p: Project ->
        if (p.name == "isar_flutter_libs") {
            try {
                val android = p.extensions.findByName("android")
                if (android != null) {
                    val nsMethod = android.javaClass.getMethod("setNamespace", String::class.java)
                    nsMethod.invoke(android, "dev.isar.isar_flutter_libs")
                    println("Applied namespace fix for isar_flutter_libs")
                    
                    val sdkMethod = android.javaClass.getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                    sdkMethod.invoke(android, 35)
                    println("Applied compileSdk fix for isar_flutter_libs")
                }
            } catch (e: Exception) {
                println("Namespace fix failed: ${e.message}")
            }
        }
    }

    if (project.state.executed) {
        applyNamespaceFix(project)
    } else {
        project.afterEvaluate {
            applyNamespaceFix(project)
        }
    }
}

subprojects {
    project.evaluationDependsOn(":app")

    plugins.withId("com.android.library") {
        if (project.name == "awesome_notifications" || project.name == "cloud_firestore") {
            afterEvaluate {
                try {
                    val android = extensions.findByName("android")
                    if (android != null) {
                        val nsMethod = android.javaClass.getMethod("setNamespace", String::class.java)
                        val nsValue = if (project.name == "awesome_notifications") "me.carda.awesome_notifications" else "io.flutter.plugins.firebase.firestore"
                        nsMethod.invoke(android, nsValue)
                        println("Applied namespace fix for ${project.name}")
                    }
                } catch (_: Exception) {}

                try {
                    tasks.named("processReleaseManifest").configure {
                        doFirst {
                            val androidSrc = extensions.findByName("android")
                            val srcDir = androidSrc?.javaClass?.getMethod("getSourceSets")?.invoke(androidSrc)
                            // Strip package from source AndroidManifest.xml
                            val manifestFile = project.file("src/main/AndroidManifest.xml")
                            if (manifestFile.exists()) {
                                var content = manifestFile.readText()
                                val pattern = Regex("""xmlns:android="[^"]*"\s+package="[^"]*"""")
                                if (content.contains("package=")) {
                                    content = content.replace(Regex("""\s+package="[^"]*""""), "")
                                    manifestFile.writeText(content)
                                    println("Stripped package attribute from ${project.name} AndroidManifest.xml")
                                }
                            }
                        }
                    }
                } catch (_: Exception) {}
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
