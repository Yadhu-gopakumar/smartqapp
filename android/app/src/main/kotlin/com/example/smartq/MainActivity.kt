package com.example.smartq

import android.os.Bundle
import androidx.core.splashscreen.SplashScreen.Companion.installSplashScreen
import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        installSplashScreen() // Correct way to install splash screen
        super.onCreate(savedInstanceState)
    }
}

