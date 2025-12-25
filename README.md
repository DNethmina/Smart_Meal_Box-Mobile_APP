# 🍱 Smart Meal Box: IoT-Integrated Nutrition Tracker

[![Flutter](https://img.shields.io/badge/Flutter-%2302569B.svg?style=for-the-badge&logo=Flutter&logoColor=white)](https://flutter.dev)
[![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)](https://firebase.google.com/)
[![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

**Smart Meal Box** is a cutting-edge IoT companion application designed to help users take control of their health. By connecting directly to a physical smart meal box, the app provides real-time monitoring of food weight, nutritional intake, and storage conditions, turning every meal into actionable data.

---

## 🎯 The Problem & Solution

* **The Problem:** Most nutrition apps rely on manual user input, which is often inaccurate, time-consuming, or easily forgotten.
* **The Solution:** Smart Meal Box eliminates manual entry by using **IoT sensors** to measure actual food weight and temperature. This data is synced instantly to a Flutter-based mobile interface for a "zero-effort" tracking experience.

---

## ✨ Key Features

* **Live Dashboard:** View real-time weight measurements and the current temperature of your food.
* **Automatic Logging:** The app calculates nutritional breakdowns (calories, proteins, carbs, fats) automatically based on the weight of the food type selected.
* **Goal Tracking:** Set custom daily targets and watch your progress update in real-time as you eat.
* **Smart Alert System:** Receive instant notifications if food temperature exceeds safe limits or when daily calorie goals are reached.
* **Historical Trends:** Access weekly and monthly summaries to identify long-term eating habits and patterns.

---

## 🎨 My Role: Flutter Developer & UI/UX Lead

As the primary mobile developer, I focused on creating a seamless bridge between IoT data streams and the user. My goal was to create a high-performance application that simplifies complex nutritional data through an encouraging and intuitive interface.

### 🚀 Key Technical Contributions

* **Real-Time IoT Integration:** Implemented live data listeners using **Firebase/Firestore** to reflect weight changes from the meal box instantly on the dashboard.
* **Health Data Visualization:** Developed interactive intake charts using the **fl_chart** library to visualize daily macronutrients.
* **State Management:** Utilized **Provider/Riverpod** to ensure the UI updates efficiently without lag when high-frequency data is received from the IoT device.
* **Notification Engine:** Built a custom alert system triggered by real-time sensor data.

---

## 🏗 Technical Stack

| Component | Technology |
| :--- | :--- |
| **Frontend** | Flutter (Dart) |
| **Backend** | Firebase / Cloud Firestore |
| **Communication** |  HTTP |
| **Data Visualization** | fl_chart |
| **State Management** | Provider / Riverpod |
