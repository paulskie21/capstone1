# Workforce dashboard

A browser-based workforce operations dashboard inspired by the ArchitectUI analytics layout. Press F5 in VS Code to start the local server and open the dashboard at `http://localhost:2026`. You can also run the **Serve Workforce Dashboard** task and open that URL. The app has no build step. The shared UI behavior uses jQuery 3.7.1 from the official jQuery CDN, so an internet connection is required when opening the page.

## Modules

The HTML entry point (`index.html`), stylesheet (`styles.css`), shared jQuery UI behavior (`js/app.js`), and module definitions are kept in separate files. Each module's labels, form fields, table columns, and sample records live in its own file under `js/modules/`.

- `dashboard.js` — workforce overview
- `employees.js` — employee directory
- `attendance.js` — attendance records
- `facial-logs.js` — recognition events
- `shifts.js` — work shifts
- `leave-requests.js` — leave applications and review decisions
- `fatigue-forecasting.js` — fatigue risk assessments
- `reports.js` — reports and analytics
- `settings.js` — workspace settings

The record modules support create, read, update, and delete. Most records are saved in the current browser's local storage and can be exported as CSV. Attendance allows at most one record per employee per date in this browser.

## Face attendance (local prototype)

Camera attendance requires the dashboard and the local recognition API to be running:

1. Install Python 3.12. Python 3.15 is not currently supported by the ONNX Runtime dependency used by YOLOv8.
2. From the workspace root, create a virtual environment and install the API dependencies:
   ```powershell
   py -3.12 -m venv .venv
   .\.venv\Scripts\python.exe -m pip install -r server\requirements.txt
   ```
3. Run **Serve Workforce Dashboard** and **Start Face Recognition API** from VS Code tasks. Open `http://localhost:2026`.
4. When adding an employee in Employee Management, select **Enroll face after saving** to open enrollment immediately. Capture three samples with the employee’s permission while they look forward and turn slightly left and right. Existing employees can be enrolled or re-enrolled using the face icon in their row. During Attendance camera check-in, movement starts face scans; a stable match across three scans enables confirmation. Uncertain matches require manual review.

The local API uses DeepFace with its YOLOv8n face detector and FaceNet512 embeddings. It stores up to five face templates linked to employee IDs in `server/data/faces.sqlite3`; raw camera frames are sent to the loopback API for inference and are not written to disk. Delete an enrollment through the same employee face dialog. The first inference may download model weights and take longer.

This is a local prototype, not an accuracy-certified or production attendance system. It does not perform liveness or anti-spoofing checks. The default cosine-distance threshold (`0.30`) and ambiguity margin (`0.05`) are configurable with `FACE_DISTANCE_THRESHOLD` and `FACE_AMBIGUITY_MARGIN`; they have not been calibrated on your employees or camera conditions. The service binds to localhost and has no authentication; do not expose it to a network or use real employee biometrics without a security, privacy, consent, and legal review. Camera access requires browser permission and a secure context such as localhost or HTTPS.
