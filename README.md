# Infant Cry Diagnostic System (ICDS) 🏥👶🎙️

A professional-grade mobile application designed for the objective analysis and interpretation of infant vocalizations using Gemini 3 Flash's native multimodal capabilities.

## 🚀 Key Features
- **Acoustic Data Acquisition:** High-fidelity real-time audio recording of infant cries.
- **Multimodal AI Analysis:** Leverages Gemini 3 Flash for native audio understanding, identifying phonetic markers based on established pediatric research (e.g., Dunstan Baby Language).
- **Clinical-Grade Reporting:** Provides technical summaries of acoustic findings, diagnostic confidence scores, and objective explanations.
- **Criticality Assessment:** Automated detection of high-intensity or abnormal acoustic markers that may indicate medical urgency.
- **Professional UI/UX:** A clean, clinical interface designed for high-stakes environments with real-time waveform visualization.

## 🛠 Tech Stack
- **Framework:** [Flutter](https://flutter.dev/) (Material 3)
- **AI Engine:** Gemini 3 Flash (via OpenAI Compatible API)
- **Signal Processing:** `audio_waveforms` for real-time visualization.
- **Audio Engine:** `record` & `path_provider`.
- **Animations:** `animate_do` for seamless transitions.

## 📋 Prerequisites
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Stable channel).
- A compatible IDE (VS Code, Android Studio, or IntelliJ).
- Access to a Gemini 3 Flash API endpoint or a compatible proxy.

## ⚙️ Setup & Installation

1. **Clone the Repository:**
   ```bash
   git clone https://github.com/ivanarifin/baby-cry-interpreter-ai.git
   cd baby-cry-interpreter-ai
   ```

2. **Environment Configuration:**
   Create a `.env` file based on the provided template:
   ```bash
   cp .env.example .env
   ```
   Required variables:
   - `AI_BASE_URL`: Your API/Proxy base URL.
    - `AI_API_KEY`: Your authentication key.
    - `AI_MODEL`: `gemini-3-flash` (or compatible).

3. **Dependency Installation:**
   ```bash
   flutter pub get
   ```

4. **Deployment:**
   - **Mobile (Android/iOS):** Ensure a physical device is connected with debugging enabled.
     ```bash
     flutter run
     ```
   - **Web (Chromium-based):**
     ```bash
     flutter run -d chrome
     ```
   - **Desktop (Windows):**
     ```bash
     flutter run -d windows
     ```

## 📱 Operational Procedure
1. Initialize the application.
2. Position the device's microphone within optimal range of the infant.
3. Activate the **Diagnostic Input** (Mic icon) to begin data acquisition.
4. The system will automatically terminate recording once sufficient acoustic data is acquired (approx. 6 seconds of clear signal).
5. Review the **Diagnostic Report** for findings and recommendations.

## ⚖️ Legal Disclaimer
This system is intended for informational and educational purposes only. It does not constitute medical advice, diagnosis, or treatment. Always seek the advice of a physician or other qualified health provider with any questions regarding a medical condition. Never disregard professional medical advice or delay in seeking it because of information provided by this application.

---
Developed for advanced pediatric acoustic research.
