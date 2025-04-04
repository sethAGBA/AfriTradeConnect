# Keep BouncyCastle classes (used by okhttp3 for SSL/TLS)
-keep class org.bouncycastle.** { *; }
-dontwarn org.bouncycastle.**

# Keep Conscrypt classes (used by okhttp3 for SSL/TLS)
-keep class org.conscrypt.** { *; }
-dontwarn org.conscrypt.**

# Keep OpenJSSE classes (used by okhttp3 for SSL/TLS)
-keep class org.openjsse.** { *; }
-dontwarn org.openjsse.**

# Keep okhttp3 classes to avoid issues with SSL/TLS configuration
-keep class okhttp3.** { *; }
-dontwarn okhttp3.**