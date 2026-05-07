# Mini Me — Privacy Policy

**Last updated:** May 2026
**Effective:** First public release

This is the source-of-truth privacy policy for the Mini Me iOS app. Publish this file (or its rendered HTML) to a public URL — `https://mini-me.app/privacy` is suggested — and submit that URL in App Store Connect under "Privacy Policy URL" before App Store review.

---

## Plain-English summary

Mini Me runs entirely on your device. Your schedule, your habits, your character customizations, and the contents of every block you complete stay on your iPhone. We never see them, we never receive them, and we don't have a server that could store them.

The one and only feature that uses cloud storage is **Friends**, and even then we only sync four small things to Apple's iCloud — your chosen display name, the name of the scene your mini-me is currently in (e.g. "coffeeShop"), the name of the pose they're holding (e.g. "slacking"), and the timestamp of when you were last active. Nothing else. Not your schedule details. Not your block labels. Not your location. Not your Apple ID.

The data above is held in **your iCloud account**, in our app's public CloudKit container. We are not the storage provider — Apple is. We don't have a database. We don't run analytics. We don't have advertising partners.

If you delete the app, your local data goes with it and your CloudKit presence record stops being updated; existing friends will see a stale "last active" timestamp. To remove your CloudKit record entirely, sign out of iCloud or contact us to delete it on your behalf.

---

## What data Mini Me collects

### Stays on your device (never transmitted)

- The blocks you create in your daily schedule (label, category, time, duration)
- Your wake-up time
- The completion record of each day (which blocks you marked done)
- Your mini-me's name, color/skin tone, and any equipped customizations
- Your room layout and decoration choices
- Coin balance and ownership of in-game items
- Any notification preferences
- Calendar events (only if you explicitly enable Calendar Sync, and only as a one-way import — events are read on-demand and not stored remotely)

### Synced to iCloud (only when Friends is enabled)

- A randomly generated 36-character user identifier (UUID), unrelated to your Apple ID
- A 6-character invite code (alphanumeric, regeneratable)
- Your chosen mini-me display name
- The current scene type your mini-me is in (one of: bedroom, study, gym, kitchen, coffeeShop, rooftop)
- The current activity your mini-me is doing (one of: idling, working, reading, eating, exercising, socializing, sleeping)
- The timestamp of when you last opened the app

This data is published to the **public** CloudKit container `iCloud.com.woojjwoo.pixieme`, accessible to other Mini Me users who have your invite code. It is updated when you open the app and stops updating when the app is closed.

### Not collected (under any circumstances)

- Your name, email address, or contact info
- Your Apple ID
- Your location (coarse or precise)
- Your IP address (we have no server to receive it)
- Device identifiers (IDFA, advertising ID, MAC address)
- App usage analytics, crash reports, or telemetry (Mini Me ships with no analytics SDK)
- The text content of your blocks ("morning meditation," "work on resume," etc.)
- Calendar event content
- Any health, fitness, or biometric data
- Photos, contacts, microphone, or camera content

---

## How data is used

- **On-device data** (schedule, completions, customizations) is used solely to render your widget and your in-app experience.
- **iCloud-synced data** (the four fields above) is used solely to render your friends' presence inside your scene during shared social blocks and inside your friends list. It is not analyzed, aggregated, or shared with third parties.

We do not use any data for advertising, profiling, or training machine learning models.

---

## Sharing data with third parties

We don't share your data with anyone. There are no advertising partners, no analytics partners, and no data brokers involved with Mini Me. The only third party in the data flow is **Apple**, which provides the iCloud / CloudKit storage that holds your presence record. Apple's handling of that data is governed by [Apple's Privacy Policy](https://www.apple.com/legal/privacy/).

---

## Children

Mini Me is suitable for ages 4+ and contains no advertising, no in-app purchases, and no chat or open communication features. The Friends feature uses 6-character invite codes only; there is no public discovery, no friend requests, and no way for strangers to contact a child user. We do not knowingly collect any data from children under 13 beyond the four-field presence record above, and that record contains no personally identifying information.

---

## Your rights and choices

- **You can disable Friends at any time.** Tap a friend → swipe to remove. To stop publishing your presence entirely, do not enable the Friends feature, or remove all your friends. Disabling iCloud Drive or signing out of iCloud also stops the sync.
- **You can regenerate your invite code at any time.** Go to You → Friends → Share my code → Generate new code. Old codes immediately stop working.
- **You can delete your CloudKit record.** Sign out of iCloud, then sign back in and the old record will not return; or contact us at the email below to request deletion.
- **You can wipe all local data.** You → Settings → Reset Data (full reset) removes everything stored on the device.
- **You can export your data.** Currently not supported in v1; reach out via email if you need a copy of your local schedule and we will provide a JSON export.

---

## Security

- All on-device data is stored in iOS's standard SwiftData container (encrypted at rest by iOS).
- All iCloud transit is encrypted by Apple (TLS in flight, encrypted at rest in CloudKit).
- We do not run our own servers, so there is no separate access path.

---

## International users

Mini Me is sold worldwide via the App Store. Local data never leaves your device. CloudKit data is stored in Apple's data centers in the user's region. We do not transfer data internationally; Apple's regional data residency rules apply.

---

## Changes to this policy

We will revise this document if the data behavior changes. Material changes will be announced via an in-app banner at least 14 days before they take effect. The "Last updated" date at the top reflects the most recent material change.

---

## Contact

For privacy questions, data deletion requests, or anything else:

**Email:** trubigideas@gmail.com

---

## Apple App Store Connect — Data Disclosures

For convenience, the App Store privacy "nutrition label" should be filled out as follows:

| Category | Disclosure |
|---|---|
| Data Linked to You | None |
| Data Not Linked to You | Display Name (only when Friends is enabled), Other User Content (current scene + activity, when Friends is enabled) |
| Data Used to Track You | None |

**Tracking:** Mini Me does not track users across apps and websites.
**Third-party SDKs:** None.
