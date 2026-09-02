# Linux release cohort report

**Build:** `0.3.0-alpha.356`

Linux is now a first-class private-alpha candidate rather than a source-only development platform. The reviewed `Linux Playtest` preset produces one x86-64 executable with its resource pack embedded. Pull-request CI exports and launches it natively on Ubuntu, creates a checksummed cohort with the same observer and evidence tools as Windows, downloads that exact artifact into a separate job, and reverifies the complete local evidence workflow.

Tagged and manually dispatched release workflows now build Windows, unsigned macOS, and Linux candidates from the same source revision. The tag-gated publisher downloads and verifies all three manifests before assembling standalone artifacts, observer cohorts, and the shared checksum list. A failed or missing Linux cohort blocks publication rather than silently omitting the platform.

This does not claim universal Linux compatibility. AppImage, Flatpak, Snap, distro packages, ARM builds, signing, and hardware coverage outside the current Ubuntu runner remain out of scope. `release_ready` remains false, and human sessions remain necessary for performance, input, accessibility, and comprehension claims.
