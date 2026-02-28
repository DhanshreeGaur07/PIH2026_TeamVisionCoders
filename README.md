# 📘 ScrapCrafters

### AI-Powered Circular Economy Platform

---

## 1️⃣ Project Overview

**ScrapCrafters** is a digital circular-economy platform that connects:

* 🧍 Users (scrap donors & buyers)
* 🤝 Partners (scrap dealers & artists)
* 🏭 Industries (bulk scrap consumers)

The platform enables intelligent scrap collection, redistribution, product creation, and industrial fulfillment using AI-driven scrap classification and smart matching algorithms.

---

## 2️⃣ Problem Statement

Urban waste is poorly categorized, inefficiently distributed, and underutilized.

Key issues:

* Lack of structured scrap redistribution
* No incentive mechanism for individuals
* Inefficient scrap-to-industry matching
* No AI-based verification of scrap types

---

## 3️⃣ Proposed Solution

ScrapCrafters provides:

* AI-based scrap classification
* Smart dealer-industry matching
* Gamified reward system (Scrap Coins)
* Marketplace for upcycled products
* Contract-based artist collaborations
* Real-time industrial requirement fulfillment

---

# 🏗 System Architecture

```text
Frontend (React.js)
        ↓
Backend (FastAPI - Python)
        ↓
Firebase Firestore Database
Firebase Authentication
Firebase Storage
        ↓
AI Module (EfficientNetB0 Model)
```

---

## 4️⃣ Technology Stack

### Frontend

* React.js
* React Router
* Redux Toolkit
* Material UI
* Axios

### Backend

* FastAPI
* Pydantic
* Firebase Admin SDK
* Uvicorn

### Database

* Firebase Firestore
* Firebase Auth
* Firebase Storage

### AI/ML

* TensorFlow / Keras
* EfficientNetB0 (Transfer Learning)
* Data Augmentation

---

# 👥 System Modules

---

## 🧍 1. User Module

### Features

* Registration & Login
* Scrap Donation
* Scrap Image Upload
* Earn Scrap Coins
* Purchase Products
* Give Contract to Artist

### Data Fields

* Name
* Email
* Phone
* Location
* Scrap Coin Balance

---

## 🤝 2. Partner Module

### Types

* Scrap Dealer
* Artist

### Features

#### Scrap Dealer

* Accept scrap pickup request
* Store scrap inventory
* Sell scrap to industries

#### Artist

* Accept scrap
* Create products
* Sell products on platform

---

## 🏭 3. Industry Module

### Features

* Unique Industry ID
* Add Scrap Requirement (e.g., 50kg Iron)
* Real-time requirement fulfillment
* Automatic closure when demand met

---

# 🤖 AI Module Documentation

## Model Used

EfficientNetB0 (Transfer Learning)

## Why EfficientNet?

* Lightweight
* High accuracy
* Fast training
* Ideal for hackathon deployment

---

## AI Workflow

1. User uploads scrap image
2. Image resized to 224x224
3. Passed through EfficientNet model
4. Softmax classification
5. Confidence score generated
6. Scrap type stored in database
7. Scrap coins awarded

---

## Model Architecture

```python
EfficientNetB0 (ImageNet weights)
↓
GlobalAveragePooling
↓
Dense (128, ReLU)
↓
Dropout (0.3)
↓
Dense (5 classes, Softmax)
```

---

## Classes Detected

* Iron
* Plastic
* Copper
* Glass
* E-waste

---

## Data Augmentation

* Rotation
* Flip
* Zoom
* Brightness adjustment

---

## Accuracy Optimization

* Transfer learning
* Early stopping
* Learning rate scheduler
* Label smoothing

---

# 🧠 Smart Matching Algorithm

When industry posts requirement:

### Steps

1. Filter dealers by scrap type
2. Filter by location proximity
3. Rank using weighted score

### Weighted Score Formula

```text
Score = (0.4 × proximity)
      + (0.3 × availability)
      + (0.2 × rating)
      + (0.1 × response_speed)
```

---

## Demand Fulfillment Logic

If industry requires 50kg iron:

* System allocates from nearest dealers
* Updates remaining requirement
* Closes request automatically at 50kg

---

# 🪙 Scrap Coin System

Reward formula:

```text
ScrapCoin = ScrapWeight × SustainabilityFactor
```

Example:

| Scrap Type | Coin Multiplier |
| ---------- | --------------- |
| Plastic    | 20              |
| Iron       | 30              |
| Copper     | 40              |
| E-waste    | 50              |
| Glass      | 20              |

Coins can be used to:

* Purchase products
* Avail artist services

---

# 🔐 Security Measures

* Firebase Authentication
* Role-based access control
* Image validation before AI processing
* Confidence threshold check
* Input validation using Pydantic
* HTTPS secure API endpoints

---

# 📊 Database Structure (Firestore)

Collections:

```text
users/
partners/
industries/
scrap_requests/
industry_requirements/
products/
transactions/
scrap_coins/
```

# 📈 Future Enhancements

* Carbon footprint tracker
* ESG analytics dashboard
* Blockchain-based scrap tracking
* IoT-based smart bins
* AI price prediction
* Heatmap visualization

---

# 🌍 Sustainable Development Goals (SDGs)

ScrapCrafters supports:

### SDG 11 – Sustainable Cities and Communities

Improves urban waste circulation.

### SDG 12 – Responsible Consumption and Production

Promotes circular economy.

### SDG 9 – Industry, Innovation and Infrastructure

Optimizes industrial supply chain.

### SDG 13 – Climate Action

Reduces landfill emissions.

### SDG 8 – Decent Work and Economic Growth

Supports scrap dealers & artists.

---

# 🎯 Expected Impact

* Reduced waste mismanagement
* Increased scrap recovery efficiency
* Transparent scrap redistribution
* Incentivized sustainability
* Improved industrial material sourcing

---

# 🏆 Conclusion

ScrapCrafters transforms waste into value through:

* Artificial Intelligence
* Smart Matching Algorithms
* Gamified Sustainability
* Industry Integration

It is not just a marketplace. It is a digital circular-economy ecosystem designed for scalable urban sustainability.
