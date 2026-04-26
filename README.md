# Baby Cry Interpreter AI 👶🍼

AI-powered mobile application to detect and interpret baby cries (Hungry, Sleepy, Uncomfortable, etc.) using Gemini 3 Flash.

## 🚀 Features
- **Real-time Audio Recording:** Capture baby cries directly from your device.
- **AI Analysis:** Uses Gemini 3 Flash's native audio understanding to interpret the cry.
- **Modern UI/UX:** Clean, animated interface with Material 3 and smooth transitions.
- **Actionable Insights:** Provides advice for parents based on the AI's findings.

## 🛠 Tech Stack
- **Framework:** [Flutter](https://flutter.dev/)
- **AI Model:** Gemini 3 Flash (via OpenAI Compatible Proxy)
- **Animations:** `animate_do`
- **Audio:** `record` & `path_provider`

## 📋 Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) installed on your machine.
- A code editor (VS Code or Android Studio).
- Access to a Gemini 3 Flash API (or a compatible proxy).

## ⚙️ Setup & Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/ivanarifin/baby-cry-interpreter-ai.git
   cd baby-cry-interpreter-ai
   ```

2. **Configure Environment Variables:**
   Copy the `.env.example` file to `.env` and fill in your credentials:
   ```bash
   cp .env.example .env
   ```
   Edit `.env`:
   - `AI_BASE_URL`: Your proxy/API base URL (e.g., `http://localhost:8317/v1`).
   - `AI_API_KEY`: Your API key.
   - `X_OAUTH_KEY`: Your specific account ID (if using a proxy).

3. **Install Dependencies:**
   ```bash
   flutter pub get
   ```

4. **Run the Application:**
   - **Web (Chrome/Brave):**
     ```bash
     flutter run -d chrome
     ```
   - **Android (Physical Device):**
     Make sure USB Debugging is enabled, then:
     ```bash
     flutter run
     ```
   - **Windows Desktop:**
     ```bash
     flutter run -d windows
     ```

## 📱 How to Use
1. Open the app.
2. Tap the **Mic** button to start recording the baby's cry.
3. Tap the **Stop** button when finished (recommend 5-10 seconds).
4. Wait for the AI to analyze and display the result.

## 🤝 Contributing
Feel free to fork this project and submit PRs for any improvements or new features!

---
Made with ❤️ for parents everywhere.
