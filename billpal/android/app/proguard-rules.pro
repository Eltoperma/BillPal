# Add project specific ProGuard rules here.
# By default, the flags in this file are appended to flags specified
# in $ANDROID_HOME/tools/proguard/proguard-android.txt

# Keep ML Kit Text Recognition classes
-keep class com.google.mlkit.vision.text.** { *; }
-keep class com.google.android.gms.internal.vision.** { *; }
-dontwarn com.google.mlkit.vision.text.**

# Keep Chinese Text Recognizer
-keep class com.google.mlkit.vision.text.chinese.** { *; }
-dontwarn com.google.mlkit.vision.text.chinese.**

# Keep Devanagari Text Recognizer
-keep class com.google.mlkit.vision.text.devanagari.** { *; }
-dontwarn com.google.mlkit.vision.text.devanagari.**

# Keep Japanese Text Recognizer
-keep class com.google.mlkit.vision.text.japanese.** { *; }
-dontwarn com.google.mlkit.vision.text.japanese.**

# Keep Korean Text Recognizer
-keep class com.google.mlkit.vision.text.korean.** { *; }
-dontwarn com.google.mlkit.vision.text.korean.**

# Keep all ML Kit Vision classes
-keep class com.google.mlkit.vision.** { *; }
-dontwarn com.google.mlkit.vision.**

# Keep Flutter plugin classes
-keep class io.flutter.** { *; }
-keep class com.google_mlkit_text_recognition.** { *; }

# Keep Google Play Core classes (optional dependencies)
-keep class com.google.android.play.core.** { *; }
-dontwarn com.google.android.play.core.**

