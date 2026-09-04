---
description: How to maintain and extend the HerCycle Bloom Health System
---

The HerCycle Bloom Health System is a comprehensive suite for personalized women's health. Below are the key components and how to maintain them.

### 1. Mandatory Body Metrics Gate
Post-onboarding, users are locked out of Nourish and Insights tabs until they complete the metrics setup.
- **Gate Widget**: `lib/features/health/presentation/widgets/health_gate_wrapper.dart`
- **Setup Screen**: `lib/features/health/presentation/screens/health_metrics_setup_screen.dart`

### 2. Health Brain & Calculations
All health calculations (BMI, BMR, TDEE, Calorie Goals) are centralized in the `UserMetrics` model.
- **File**: `lib/models/user_metrics.dart`
- **Logic**: Mifflin-St Jeor equation and HealthMode-specific adjustments.

### 3. Wellness & Symptom Tracking
Daily logs are stored in `WellnessLog`.
- **Log Screen**: `lib/features/health/presentation/screens/daily_log_screen.dart`
- **Analytics**: `lib/providers/health_analytics_provider.dart` (computes trends and dynamic insights).

### 4. Health Hub
The central hub for all specialized modules.
- **File**: `lib/features/health/presentation/screens/health_hub_screen.dart`
- **Modules**:
  - Lab Reports
  - Medication Reminders
  - Physical Metrics (BBT/Mucus)
  - Condition Coverage (PCOS, Endometriosis, PMDD, etc.)

### 5. Dashboards & Insights
Dashboards are activated only when `isMetricsComplete` is true.
- **Insights Screen**: `lib/features/insights/presentation/screens/insights_screen.dart`
- **Nourish Screen**: `lib/features/nourish/presentation/screens/nourish_screen.dart`

### Extending the System
- **Adding new conditions**: Update `HealthMode` or add booleans in `UserMetrics`. Update `HealthConditionsScreen`.
- **New insights**: Add logic to `healthAnalyticsProvider` to detect patterns in `WellnessLog` and `CycleLog`.
- **New lab markers**: Add fields to `LabReport` in `lib/models/health_records.dart` and update `LabReportsScreen`.
