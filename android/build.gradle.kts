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
                    val method = android.javaClass.getMethod("setNamespace", String::class.java)
                    method.invoke(android, "dev.isar.isar_flutter_libs")
                    println("Applied namespace fix for isar_flutter_libs")
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

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
