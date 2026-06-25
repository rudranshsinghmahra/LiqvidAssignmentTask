## Technical Implementation

* **Storage Location:** Uses the `path_provider` package to securely save and extract the zip file inside the app's private `ApplicationDocumentsDirectory`.
* **Encrypted Media:** Natively reads the `config.json` file, converts the hex keys, and uses AES-256-CBC to decrypt the video file, overwriting the original so the HTML player finds it effortlessly.
* **WebView Integration:** Loads the local `index.html` file via `webview_flutter`, configured to bypass strict mobile gesture requirements for smoother playback.
* **Custom Fixes:** * Injects a continuous JavaScript loop to enable "tap-to-pause" behavior (even inside iframes).
  * Uses a Flutter `PopScope` to load a blank page before closing, ensuring background audio threads are instantly killed when the user exits the screen.
