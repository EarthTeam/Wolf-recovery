# AGENTS.md

This file provides guidance to WARP (warp.dev) when working with code in this repository.

## Project Overview

Wolf Recovery is a **single-file, local-first web application** for tracking health/recovery metrics, designed specifically for people managing ADT (Adrenal/Thyroid Dysfunction) or CFS (Chronic Fatigue Syndrome). The entire application—HTML, CSS, and JavaScript—lives in one self-contained HTML file.

## Development Workflow

### File Naming Convention
- Active development happens on versioned files: `Wolf-Recovery_v{major}.{minor}.html`
- The latest version is copied to `index.html` for deployment
- Old versions are archived in `OLD VERSIONS/`

### Deployment
```bash
./deploy-latest.sh
```
This script:
1. Finds the latest `Wolf-Recovery_v*.html` file (by modification time)
2. Backs up current `index.html` with timestamp
3. Copies latest version to `index.html`
4. Commits and pushes to GitHub
5. Vercel auto-deploys from GitHub

### Local Testing
Open any `.html` file directly in a browser—no build step or server required. The app stores data in `localStorage` or optionally in a local `data.json` file via File System Access API.

## Architecture

### Multi-Device Voting System
The app integrates data from three wearable devices and uses a "voting" consensus model:
- **Morpheus**: Morning HRV readiness test (wake-test snapshot, not overnight)
- **Oura Ring**: Overnight recovery score, RHR
- **Whoop**: Recovery percentage or RHR (RHR used as proxy when recovery is missing)

Each device "votes" on the user's state (ok/neutral/stressed) based on deviation from their personal baseline. A **majority vote** determines the integration phase.

### Integration Phases (ADT/CFS-specific terminology)
- **REGULATED**: Devices agree the system is recovered
- **TRANSITIONAL**: Mixed signals, often a timing/sequencing effect
- **INTEGRATION LAG**: Devices show stress but fatigue isn't high—interpreting as delayed absorption of prior load
- **PROTECTIVE RESET**: Both devices and subjective fatigue signal stress

### Movement Strategy Recommendations
Output is actionable guidance, not just a color:
- **Expand**: System cleared, can push slightly
- **Consolidate**: Keep it easy/repeatable, no testing
- **Scout**: De-stack load, stay in motion but shorter/flatter
- **Prime**: Gentle reset only, skip intensity

### Load Memory (PEM Reservoir)
A rolling calculation (`computeLoadMemorySeries`) that models unabsorbed movement load over 7-10 days:
- Inputs: steps, fatigue, joint warnings, resistance training, cognitive load (parsed from notes)
- Shows clearance status: CLEARING / INTEGRATING / SATURATED
- Detects "approaching capacity" when high-step days stack consecutively

### Key Thresholds
Defined in `getThresholds(mode)`:
- **ADT mode** (default): More conservative—lower z-score thresholds, stricter joint warnings
- **Standard mode**: Slightly higher thresholds for non-CFS users

### Primary Limiter Detection
Auto-detects whether the day's constraint is:
- **Metabolic** (neuro-energy): High fatigue, device stress signals
- **Mechanical** (joints/tendons): Joint pain, tendon keywords in notes
- **Mixed**: Both active

## Code Structure Notes

- All state management is in-memory or localStorage—no external API calls
- `computeDayAssessment()` is the main function that orchestrates voting, outlier detection, and recommendation generation
- `computeBaselines()` calculates rolling statistics for each metric over the baseline window
- CSV/JSON import/export supports multiple header aliases for flexibility

## Data Schema
Each entry has these fields:
```javascript
{
  date,           // YYYY-MM-DD
  mReady,         // Morpheus readiness 0-100
  mHrv,           // Morpheus HRV
  ouraRec,        // Oura recovery 0-100
  whoopRec,       // Whoop recovery 0-100 (optional)
  whoopRhr,       // Whoop RHR bpm
  ouraRhr,        // Oura RHR bpm
  steps,          // Daily step count
  fatigue,        // Subjective 1-10
  resistance,     // Y/N - strength training
  joint,          // Joint/tendon warning 0-10
  limiter,        // AUTO/METABOLIC/MECHANICAL/MIXED
  amState,        // FLAT/MIXED/ONLINE
  pmShift,        // NO/SOME/CLEAR
  liftTime,       // 12/15/18/UNK
  notes           // Free text
}
```
