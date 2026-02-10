# FinTrack Pro - Advanced Business Finance Manager

**FinTrack Pro** is a high-performance, cross-platform financial management application built with the **Flutter** framework. It is designed to help businesses manage their income, expenses, and tax obligations while providing real-time international currency conversions.

---

## 🚀 Key Features

* **Real-Time Multi-Currency Engine**: 
    * Integrates with **ExchangeRate-API** to provide live conversion rates for PKR, USD, INR, and AED.
    * Dynamic UI that switches currency symbols ($ , ₹ , د.إ , Rs) instantly based on user preference.
* **Automated Tax (GST) Logic**: 
    * Built-in calculation engine for **18% GST** on transactions with a toggle-based application.
* **Professional PDF Reporting**: 
    * Generates comprehensive business audit reports in PDF format.
    * Features full **Unicode support** (via Noto Sans) to render specialized currency symbols (₹ and د.إ) accurately.
* **Detailed Audit QR Codes**: 
    * Every generated report contains a high-density QR code.
    * Scanning the code provides instant verification of the **Date, Total Income, Total Expense, and Net Balance**.
* **Secure Cloud Infrastructure**: 
    * Powered by **Firebase Firestore** for real-time data sync and secure user-level data isolation.



---

## 🛠️ Tech Stack

* **Framework**: Flutter (Dart)
* **Database**: Firebase Firestore (Real-time)
* **Authentication**: Firebase Auth (Secure Login/Signup)
* **API**: ExchangeRate-API (v4) for live currency data
* **Main Packages**: `pdf`, `printing`, `cloud_firestore`, `http`, `qr_flutter`.

---

## 📂 Project Structure

```text
lib/
├── models/           # Data models for transactions
├── services/         # Core logic (Firebase, API, PDF generation)
│   ├── firestore_service.dart
│   ├── currency_service.dart
│   └── pdf_service.dart
├── screens/          # Application screens (Dashboard, Entry, History)
└── widgets/          # Custom reusable UI components