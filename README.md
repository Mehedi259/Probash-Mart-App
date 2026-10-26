# Probash Mart - Official Mobile App (Flutter)

A cross-platform mobile application (Android & iOS) for **Probash Mart** (প্রবাসী ভাই-বোনদের বিশ্বস্ত গ্রোসারি শপ). Built following **Clean Architecture**, Senior Software Engineering industry standards, and seamlessly integrated with the Django REST Framework backend.

---

## 📱 Features Overview

### 1. 🛍️ Customer Shopping Experience
- **Dynamic Hero Slider**: Promotional banners with auto-play & smooth page indicator.
- **Product Categories**: Visual category circles with custom icons and product counts.
- **Flash Deals**: Real-time interactive countdown timer (Hours, Mins, Secs) with discounted products.
- **Best Sellers & Featured Products**: High-performing products with discount tags and weight units.
- **Interactive Product Details**:
  - Image gallery with multi-photo preview
  - In-stock availability badge
  - Quantity counter selector (+ / -)
  - Wishlist toggle
  - **Direct WhatsApp Order**: Pre-formatted message directly to `+968 9457 8538`
  - Related products carousel

### 2. 🛒 Shopping Cart & Checkout
- **Instant Local & Server Sync**: Persistent local storage using `SharedPreferences` + server sync for authenticated users.
- **Promo Coupon System**: Real-time coupon code validation via `/api/v1/coupons/validate/`.
- **Checkout & Delivery**:
  - Full address form with validation (Name, Phone, Address, City/Wilayat, Postal code)
  - Multiple payment methods:
    - **Cash on Delivery (COD)**
    - **bKash / Nagad / Rocket**
    - **WhatsApp Direct Order**
  - **Order Confirmation**: Order number generation (`PM-YYMMDD-XXXX`), order summary, and WhatsApp follow-up.

### 3. 📦 Order Management & Tracking
- **Order History**: Status badges (Pending, Processing, Shipped, Delivered, Cancelled).
- **Interactive Stepper Timeline**: Step-by-step visual tracker (Placed ➔ Processing ➔ Shipped ➔ Delivered).
- **Public Order Tracking**: Track any order by order number without needing to login.

### 4. 🔐 Authentication & Profile
- **JWT Authentication**: Access and refresh token management with auto-refresh on 401.
- **Customer Registration & Login**: Full form validation with guest checkout support.
- **Profile Management**: Update name, phone, address, and city.
- **Security**: Password change screen.
- **Environment Selector**: Switch dynamically between Local Backend (`127.0.0.1:8000`), Android Emulator (`10.0.2.2:8000`), and Production Server (`46.225.103.236:8003`).

### 5. 🔍 Search & Exploration
- **Debounced Instant Search**: Real-time catalog search with query debouncing.
- **Keyword Suggestions**: Popular search tags (Hilsa, Rice, Oil, Spices, Biscuits).
- **Sort & Filter**: Sort by price (low to high, high to low), best sellers, or newest.

---

## 🏗️ Architecture & Project Structure

The project follows a **Clean Architecture** pattern separating Presentation, Business Logic / State, and Data layers:

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart         # Official brand colors (#FE6202, #281508, #D97706, etc.)
│   │   ├── app_constants.dart      # URLs, WhatsApp number, currency (৳), storage keys
│   │   └── app_assets.dart         # Asset paths for logos, icons, banners
│   ├── network/
│   │   ├── api_client.dart         # Dio client with JWT interceptor, refresh, and image resolver
│   │   ├── api_endpoints.dart      # REST API route mappings
│   │   └── api_exception.dart      # Structured error handling with Bengali messages
│   ├── theme/
│   │   └── app_theme.dart          # Material 3 theme & Google Fonts typography
│   └── utils/
│       ├── formatters.dart         # Price (৳), Date, and Discount calculation
│       └── ui_helpers.dart         # SnackBars, dialogs, WhatsApp & Phone launcher
│
├── data/
│   ├── models/                     # Type-safe models with fromJson & toJson
│   │   ├── user_model.dart
│   │   ├── product_model.dart
│   │   ├── category_model.dart
│   │   ├── cart_item_model.dart
│   │   ├── order_model.dart
│   │   ├── wishlist_model.dart
│   │   ├── banner_model.dart
│   │   ├── coupon_model.dart
│   │   ├── shipping_model.dart
│   │   └── review_model.dart
│   └── services/
│       ├── storage_service.dart    # SharedPreferences token & cache wrapper
│       └── mock_fallback_data.dart # Authentic offline-ready seed catalog
│
├── providers/                      # State Management (Provider / ChangeNotifier)
│   ├── auth_provider.dart
│   ├── categories_provider.dart
│   ├── products_provider.dart
│   ├── cart_provider.dart
│   ├── wishlist_provider.dart
│   ├── order_provider.dart
│   └── banner_provider.dart
│
├── presentation/
│   ├── widgets/                    # Reusable UI Components
│   │   ├── product_card.dart
│   │   ├── category_card.dart
│   │   ├── countdown_timer_widget.dart
│   │   ├── section_header.dart
│   │   ├── custom_button.dart
│   │   ├── custom_text_field.dart
│   │   ├── empty_state_widget.dart
│   │   └── shimmer_loader.dart
│   └── screens/
│       ├── splash/splash_screen.dart
│       ├── onboarding/onboarding_screen.dart
│       ├── main_nav_screen.dart     # Persistent BottomNav shell
│       ├── home/home_screen.dart
│       ├── categories/categories_screen.dart
│       ├── product/
│       │   ├── product_list_screen.dart
│       │   └── product_detail_screen.dart
│       ├── cart/cart_screen.dart
│       ├── checkout/
│       │   ├── checkout_screen.dart
│       │   └── order_success_screen.dart
│       ├── orders/
│       │   ├── orders_screen.dart
│       │   ├── order_detail_screen.dart
│       │   └── order_tracking_screen.dart
│       ├── wishlist/wishlist_screen.dart
│       ├── profile/
│       │   ├── profile_screen.dart
│       │   ├── edit_profile_screen.dart
│       │   └── change_password_screen.dart
│       ├── auth/
│       │   ├── login_screen.dart
│       │   └── register_screen.dart
│       ├── search/search_screen.dart
│       └── info/
│           ├── contact_screen.dart
│           └── static_page_screen.dart
│
└── main.dart
```

---

## 🚀 Running the App

### Prerequisites
- Flutter SDK (v3.44.4 or later)
- Python virtual environment with Django backend running on port 8000:
  ```bash
  cd /Users/mehedihasanmridul/Backend/Probash-Mart-Backend
  ./venv/bin/python manage.py runserver 0.0.0.0:8000
  ```

### Development
```bash
# Get dependencies
flutter pub get

# Run tests
flutter test

# Run code analyzer
flutter analyze

# Run on macOS / Chrome / Simulator
flutter run
```

---

## 🎨 Brand Design Tokens
- **Primary Color**: `#FE6202` (Official Warm Orange from Probash Mart Logo)
- **Secondary Color**: `#281508` (Espresso / Charcoal)
- **Tertiary Accent**: `#D97706` (Golden Amber)
- **WhatsApp Support**: `#25D366`
- **Surface**: `#FBFBFA` / `#FFFFFF`
