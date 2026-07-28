allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

fun Project.ensureAndroidNamespaceIfMissing() {
    val androidExtension = extensions.findByName("android") ?: return
    val getNamespace =
        androidExtension::class.java.methods.find {
            it.name == "getNamespace" && it.parameterCount == 0
        } ?: return
    val setNamespace =
        androidExtension::class.java.methods.find {
            it.name == "setNamespace" && it.parameterCount == 1
        } ?: return

    val currentNamespace = getNamespace.invoke(androidExtension) as? String
    if (currentNamespace.isNullOrBlank()) {
        val safeModuleName = name.replace('-', '_')
        setNamespace.invoke(androidExtension, "com.bgapp2.legacy.$safeModuleName")
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

// Compatibility shim for legacy Android plugins that still don't declare a namespace.
subprojects {
    pluginManager.withPlugin("com.android.application") {
        ensureAndroidNamespaceIfMissing()
    }
    pluginManager.withPlugin("com.android.library") {
        ensureAndroidNamespaceIfMissing()
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
