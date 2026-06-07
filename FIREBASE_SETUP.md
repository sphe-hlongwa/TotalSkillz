# Firebase & Google Sign-In Setup Guide for Flutter

When moving from a web app to a Flutter app, **you do NOT need to create a new Firebase project**. You should use your existing Firebase project (the one your web app is currently using) so that your Flutter app connects to the exact same database and users.

However, you *do* need to register your new Android (and iOS) app within that existing Firebase project and provide your specific computer's "Google Keys" (SHA certificates) for Google Sign-In to work.

Follow these steps to get your Flutter app fully connected:

## Step 1: Get Your SHA-1 and SHA-256 Keys (Linux/Mac)

Google Sign-In requires your computer's "fingerprint" to verify that your app is authentic. 

1. Open your terminal.
2. Run the following command to generate/view your debug keystore:
   ```bash
   keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
   ```
3. Look for the lines starting with `SHA1:` and `SHA256:`. Copy both of these strings. You will need them in the next step.

## Step 2: Register the Android App in Firebase

1. Go to the [Firebase Console](https://console.firebase.google.com/).
2. Open your **existing** project (the one used for the TotalSkillz web app).
3. On the Project Overview page (home icon), click the **Android icon** to add a new Android app (or click "Add app" if you already have apps listed).
4. **Android package name:** `com.totalskillz.mathgrade12`
   - I've verified this in your `android/app/build.gradle.kts`. Enter this exact string in Firebase.
5. **App nickname:** (Optional) "MathGrade12 Flutter".
6. **Debug signing certificate SHA-1:** Paste the `SHA1` string you copied in Step 1.
7. Click **Register app**.

## Step 3: Download & Place `google-services.json`

1. After registering, Firebase will prompt you to download a `google-services.json` file. Download it.
2. Important: Move this file into the `android/app/` directory of your Flutter project. 
   - The path must be exactly: `mathgrade12_flutter/android/app/google-services.json`.
3. Click "Next" through the remaining steps in the Firebase Console and click "Continue to console".

## Step 4: Add the SHA-256 Key (Required for Google Sign-In)

1. In the Firebase Console, click the **Gear Icon** (Project Settings) next to "Project Overview" in the top left.
2. Scroll down to "Your apps" and select the Android app you just created.
3. Under "SHA certificate fingerprints", click **Add fingerprint**.
4. Paste the `SHA256` string you copied in Step 1 and click Save.

## Step 5: Verify Authentication Methods

Since you already had a web app, Google Sign-In and Email/Password might already be enabled, but it's good to verify:
1. In the Firebase Console, go to **Authentication** -> **Sign-in method**.
2. Ensure **Email/Password** is enabled.
3. Ensure **Google** is enabled.
   - If you click edit on Google, make sure a "Project support email" is selected.

---

> **Note on Firebase Initialization**: 
> You might see `await Firebase.initializeApp(...)` in `main.dart`. If you run `flutterfire configure` in the terminal, it will auto-generate a `firebase_options.dart` file that handles the connection for all platforms using your active project. This is the modern, recommended way to link Flutter apps!
