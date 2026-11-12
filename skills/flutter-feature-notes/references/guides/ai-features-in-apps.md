# 5. AI features inside the app, and how to evaluate them

As of 2026-11-09 (Genkit Dart and MediaPipe lines added 2026-11-12): package versions, quotas and store rules below were read on official pages and pub.dev on that date. Re-check them before relying on them; this area changes monthly. *Unverified* marks what the pages read did not say. Sizes and days are judgment, not measured.

## Choose where the model runs

| Option | Use when | Facts read |
|---|---|---|
| Cloud model through **Firebase AI Logic** (`firebase_ai`) | The app is already on Firebase and the feature is chat, text or image generation from Gemini | `firebase_ai` 5.1.0 (publisher firebase.google.com, published about 16 days before 2026-11-09); platforms Android, iOS, macOS, web. Two providers: the Gemini Developer API (the page recommends it for starting, no cost) and the Agent Platform Gemini API (formerly Vertex AI), which needs billing. Install: `flutter pub add firebase_ai firebase_app_check`. No provider key lives in the app; App Check protects the proxy. |
| Cloud model through **your own backend** | Another provider (OpenAI, Anthropic and others), per-user entitlements, moderation, logging or business rules | The app calls the team's API; the provider key stays on the server. The backend owner defines limits, retention and moderation (see the hand-off list below). **Genkit Dart** (`genkit` 1.0.2, publisher genkit.dev; announced stable with Flutter 3.50 on 2026-11-11) is one way to build that backend or call it: flows with `ai.defineFlow`, tools with `ai.defineTool`, streaming, middleware such as `retry`, and OpenTelemetry tracing; Google models through `genkit_google_genai`. A Dart server exposes flows over HTTP with `GenkitRouter`, and the app calls a deployed flow with `defineRemoteAction` from `package:genkit/client.dart`, using a `contextProvider` to check a bearer token. The pages read do not name plugins for other providers. *Unverified: a call from a Flutter app on a device; a third-party post said older Flutter clients need a flag after 1.0, so read the changelog.* Keys stay on the server here too. |
| **On-device, Android system model** (ML Kit GenAI, Gemini Nano through AICore) | Short summarize, proofread, rewrite or describe-image features that must work offline | Android only; supported devices are a limited list (Pixel 9 to 11, Galaxy S25 to S26 and some others), with "plans to expand"; a per-app quota returns `ErrorCode.BUSY` (back off); inference only while the app is in the foreground. The page does not mention Flutter, so a platform channel or plugin is needed *(Unverified: a maintained Flutter plugin)*. |
| **On-device, your own model** | Privacy-critical or offline-first features; accept large downloads | `flutter_edge_ai` 2.5.3 (published 2026-10-25, MIT): engines LiteRT-LM, MediaPipe, ONNX Runtime, llama.cpp and built-in OS models; LiteRT-based features need Android minSdk 30 and arm64-v8a; iOS needs a deployment target of 15 to 16.4 depending on the engine and extended memory entitlements for large models. Model sizes are not on its page. **`flutter_gemma` is discontinued** (its last release points to `flutter_edge_ai`). `tflite_flutter` 0.12.1 is not discontinued but its page calls it work-in-progress and says its helper library is deprecated. Flutter 3.50's post also announces a new **MediaPipe** package from Google AI Edge on pub.dev with 20 on-device vision, audio and text tasks, powered by LiteRT and LiteRT-LM; it does not name the package, platforms or versions *(Unverified; the gallery at google.github.io/flutter-mediapipe loaded only a placeholder)*. |

Decision rule: start with a cloud model behind App Check or your own backend; add on-device only when offline use or privacy requires it, because it adds model downloads, device limits and a separate quality test per model.

## Keys, abuse and cost

- **Never ship a provider API key in the app.** Anything in the binary can be extracted. Flutter's AI Toolkit page warns that when the app calls Gemini directly, `firebase_options.dart` must not be committed to a public repository, because anyone could reuse the configuration and consume quota; for production it recommends a backend (Cloud Functions, Cloud Run or your own server).
- **App Check for Firebase AI Logic:** enforce it early; the Firebase page calls that critical. Providers: Play Integrity (Android), App Attest or DeviceCheck (Apple), reCAPTCHA Enterprise (web). Use the debug provider only for development and keep debug tokens out of public repositories and production builds. Optional replay protection uses limited-use tokens (5-minute lifetime, a new token per request, which adds latency). The page says App Check enforcement for AI Logic became mandatory on **2 November 2026** (that date has passed), with auto-enforcement delayable only until **21 January 2027**; an existing project that has not enforced yet should do so now.
- **Limits:** the Firebase AI Logic default is 100 requests per minute per user (per region), adjustable in Google Cloud under Quotas; there is no per-user override. Project quotas depend on provider and billing. Add your own per-user daily cap on the backend for paid models.
- **Cost:** cap output tokens and input size, show a cancel control, and monitor usage in the provider console (Firebase's "Monitor costs, usage, & metrics" page was not read).

## Building the feature

- **Chat UI:** `flutter_ai_toolkit` (Flutter's package) gives `LlmChatView` with streaming, multi-turn context, rich text, voice input, attachments, function calling and chat serialization, and a provider interface for custom models. Its page does not state a version or stability level *(check pub.dev)*.
- **Streaming:** show text as it arrives, keep a visible cancel button, and keep the partial text if the stream fails, with a retry. *Unverified on this read: the exact streaming API of `firebase_ai` (the README points to external docs).*
- **Output is untrusted input.** Render model output as plain or sanitized markdown text; never run it as code, build URLs or database queries from it without validation, and never put it in a WebView as HTML. (OWASP LLM05, improper output handling.)
- **Guardrails around the model** (Flutter's AI best-practices page, updated 2026-10-26): assume the model will sometimes be wrong; let users verify and correct AI-extracted data before the app acts on it; keep keys out of the code.
- **Agency:** tool or function calls that change data, spend money or send messages need an explicit user confirmation step (OWASP LLM06, excessive agency).
- **Failure states to design and build:** offline, timeout, rate limit (429 or quota), content blocked by the provider's safety filter, empty answer, too-long input, model unavailable, user cancelled. Label AI output as AI-generated where the stores require it (below).

## Store and privacy rules

- **Apple, guideline 5.1.2(i):** you must clearly disclose where personal data is shared with third parties, **including third-party AI**, and obtain explicit permission first. Build a consent screen before the first call that sends personal data, and send the minimum.
- **Apple, guideline 1.2:** AI content creation apps are named among apps that need a way to filter objectionable material, a way to report offensive content with timely responses, the ability to block abusive users, and published contact information. [Guidelines](https://developer.apple.com/app-store/review/guidelines/)
- **Google Play, AI-generated content policy:** applies to apps whose generated content (a central chatbot, or images or video from prompts) must follow Play's restricted-content rules; such apps must have in-app reporting or flagging so users can report offensive content without leaving the app. [Policy](https://support.google.com/googleplay/android-developer/answer/13985936)
- Update the Play Data safety form and Apple privacy labels for every AI provider that receives user data (see `flutter-release`), and include chat history in account deletion.

## Security risks to design against (OWASP Top 10 for LLM Applications, 2025)

Prompt injection (01), sensitive information disclosure (02), supply chain (03), data and model poisoning (04), improper output handling (05), excessive agency (06), system prompt leakage (07), vector and embedding weaknesses (08), misinformation (09), unbounded consumption (10). For a mobile app the practical consequences: assume the system prompt can be extracted from the app or the traffic, never put secrets in it; treat user text, files and web content that reach the model as hostile; cap consumption per user. [OWASP](https://genai.owasp.org/llm-top-10/)

## Evaluating AI features (evals)

The provider docs' approach (Anthropic, "Build evaluations"; the principles are not specific to one provider): be **task-specific** (mirror real inputs, include edge cases such as empty, very long, harmful or ambiguous input), **automate** grading where possible, and prefer **many automatically graded cases** over a few hand-graded ones. Grading methods: code-based (exact or string match; fast and reliable), human (best quality, slow), and LLM-based (flexible; give it a clear rubric, ask for a constrained answer such as correct or incorrect, test its reliability first, and use a different model from the one that wrote the output).

How to apply it to an app (the structure below is this kit's suggestion, not a standard):
1. **Golden set in the repo:** a JSON file of cases (input, expected property such as "mentions X", "returns valid JSON", "refuses", "stays under N words") next to the prompt or backend code. Include prompt-injection samples, other languages, very long and empty input.
2. **Run it where the prompt runs:** a script against the backend or the model API, not Flutter widget tests, because widget tests cannot judge language quality. Run each case more than once (output varies).
3. **Run it when the prompt, the model or its version changes** (including a provider deprecating a model), and before each release that touches the feature. Record model name, date and scores.
4. **Metrics beyond quality:** latency, tokens or cost per call, refusal rate, and the share of replies the user corrected or discarded.
5. **UI tests are separate:** use the project's normal test approach (`flutter-testing`, on request) for loading, error, cancel and consent states.

## What to ask the backend owner or the requester

Which provider and model, who pays and the monthly cap, whether prompts or outputs are logged or used for training, retention and account-deletion behaviour, moderation and the report-handling process, per-user limits, how model versions are pinned, and who owns the golden set.

## Size and effort drivers

Medium to large depending on scope: a simple one-shot feature through Firebase AI Logic is small; chat with streaming, consent, moderation, reporting, limits and an eval set is large. Add time for store review questions about AI data sharing. *(Judgment, not measured.)*
