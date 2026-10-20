# GPA Calculator Pro - Flutter

A complete Flutter GPA/CGPA calculator based on the supplied project proposal.

## Included features

- Student profile / local login
- Semester GPA calculator
- Course name, code and credit hour input
- Letter grade selection
- Automatic grade-point conversion
- Total credit hours and total grade points
- Final GPA calculation
- Add/remove courses dynamically
- Input validation
- Save semester results locally
- GPA history with course details
- Multi-semester CGPA calculation
- Target CGPA / required next-semester GPA planner
- GPA analytics and progress chart
- Best, latest, average GPA and highest-credit statistics
- Printable PDF academic report
- Custom university grading scale
- Dark mode
- Clear history / reset grading scale
- Responsive Material 3 interface

## Important: correct project name

The folder/project name must use lowercase letters and underscores. Use this folder name exactly:

`gpa_calculator_pro`

Do NOT run `flutter create .` from a folder named `GPA_Calculator_Flutter_Ready` because Dart project names cannot contain uppercase letters or hyphens.

## VS Code setup

1. Extract the ZIP.
2. Open the `gpa_calculator_pro` folder in VS Code.
3. Open Terminal -> New Terminal.
4. Run:

```powershell
flutter doctor
flutter pub get
flutter analyze
```

5. If the `android`, `web`, `windows`, etc. platform folders are not present, run exactly:

```powershell
flutter create --project-name gpa_calculator_pro .
```

This creates the standard Flutter platform files without replacing the `lib` application code.

6. For the easiest first run:

```powershell
flutter run -d chrome
```

Or connect an Android device/emulator and run:

```powershell
flutter run
```

## If VS Code says "No Device"

For Chrome:

```powershell
flutter devices
flutter run -d chrome
```

For Android, start an emulator from Android Studio or connect a phone with USB debugging enabled, then run:

```powershell
flutter devices
flutter run
```

## If dependencies are stuck

Run:

```powershell
flutter clean
flutter pub get
flutter analyze
flutter run -d chrome
```

## Data storage

The app stores profile, grading scale and GPA history locally with SharedPreferences. No Firebase/API key is required for the basic application.

## Build and install the Android APK

From this `gpa_calculator_pro` folder, run:

```powershell
flutter doctor
flutter pub get
flutter test
flutter analyze
flutter build apk --release
```

The installable APK is written to:

`build\app\outputs\flutter-apk\app-release.apk`

Copy that file to an Android phone and open it to install. If installing over USB
with Android platform tools, enable USB debugging and run:

```powershell
adb install -r build\app\outputs\flutter-apk\app-release.apk
```

The release build currently uses Flutter's generated debug signing configuration,
which is suitable for personal installation and testing. Store publishing requires
your own release signing key.

## Scope

This is an offline GPA/CGPA calculator. Firebase authentication, cloud sync and
push notifications require a configured Firebase project; e-commerce, maps,
camera and other unrelated features are not part of this app.
