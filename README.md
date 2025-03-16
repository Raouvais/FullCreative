# RickyBuggy

RickyBuggy is a Swift-based iOS application that fetches and displays character details dynamically, ensuring smooth UI updates and a seamless user experience. This project utilizes Combine for reactive programming and adheres to MVVM architecture for maintainability and scalability.

## Features
- Fetch character details dynamically.
- Display character images with proper cropping.
- Navigate between character details and location details.
- Ensure UI updates happen on the main thread for a smooth experience.
- Improved sorting logic for better user experience.
- Handle URL tap functionality without triggering unintended navigation.

## Recent Fixes & Enhancements
### ✅ UI/UX Improvements
- Fixed image cropping issue in `CharacterDetailView`.
- Ensured character title aligns properly below the navigation bar.
- Improved sorting logic for a better data representation.
- Fixed action sheet behavior to function as expected.

### ✅ Performance & Stability Enhancements
- Fixed re-invoking network requests on tapping show/hide list.
- Optimized fetching of location details dynamically.
- Ensured all UI updates happen on the main thread to prevent glitches.
- Fixed incorrect `AppearanceFrequency` initialization logic to improve readability.

### ✅ Enhancements in Interactivity
- Made URLs tappable without triggering unintended cell navigation.
- Fixed sorting view glitch for a smoother browsing experience.

### ✅ Test Case Improvements
- Fixed test cases to ensure better code reliability and maintainability.

## Installation
1. Clone the repository:
   ```sh
   git clone https://github.com/your-username/RickyBuggy.git
   ```
2. Navigate to the project directory:
   ```sh
   cd RickyBuggy
   ```
3. Open the project in Xcode:
   ```sh
   open RickyBuggy.xcodeproj
   ```
4. Build and run the project on a simulator or physical device.

## Technologies Used
- **Swift** – Core development language
- **Combine** – Handling reactive data flows
- **MVVM Architecture** – Ensuring a scalable and testable codebase
- **DIContainer** – Dependency Injection for better modularity



