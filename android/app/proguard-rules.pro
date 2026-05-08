# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Firebase App Check & Play Integrity
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Supabase / PostgREST (Prevent obfuscation of JSON serializable models if any)
-keepattributes Signature
-keepattributes *Annotation*
-keepattributes EnclosingMethod

# Keep generic signatures for reflection-based serializers
-keepclassmembers class * {
  @com.google.gson.annotations.SerializedName <fields>;
}
