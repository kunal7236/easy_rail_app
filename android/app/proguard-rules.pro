## Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-dontwarn io.flutter.embedding.**

## Gson rules (if using JSON serialization)
-keepattributes Signature
-keepattributes *Annotation*
-dontwarn sun.misc.**
-keep class com.google.gson.** { *; }
-keep class * implements com.google.gson.TypeAdapterFactory
-keep class * implements com.google.gson.JsonSerializer
-keep class * implements com.google.gson.JsonDeserializer

## Keep model classes (adjust package name if needed)
-keep class com.example.easyrail.models.** { *; }

## General Android rules
-keepclassmembers class * implements android.os.Parcelable {
    static ** CREATOR;
}

## Retain service method parameters when optimizing
-keepclassmembers,allowshrinking,allowobfuscation interface * {
    @retrofit2.http.* <methods>;
}

## Ignore annotation used for build tooling
-dontwarn org.codehaus.mojo.animal_sniffer.IgnoreJRERequirement

## Top-level functions like main()
-keepclasseswithmembers class * {
    public static void main(java.lang.String[]);
}
