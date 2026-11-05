/**
 * ============================================================================
 * DBMS MINI PROJECT: GYM MEMBERSHIP MANAGER
 * File: 05_nosql_mongodb.js
 * Students: Priyansh Soni (SRN: PES1UG24CS344)
 *           Pulkit Bhardwaj (SRN: PES1UG24CS346)
 * Institution: PES University, Bengaluru
 * Database: gym_nosql_db (MongoDB Document Store)
 * Description: MongoDB NoSQL Schema Definition, Validation Rules, Compound
 *              Indexes, and Comprehensive CRUD Operations for Member Biometrics
 *              and Dynamic Workout/Diet Telemetry.
 * ============================================================================
 */

// 1. Switch to / Create Database
use gym_nosql_db;

// 2. Drop existing collections for clean reproducible execution
db.member_biometrics.drop();
db.workout_telemetry.drop();

// ----------------------------------------------------------------------------
// 3. Collection Creation with JSON Schema Validation
// ----------------------------------------------------------------------------
db.createCollection("member_biometrics", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["member_id", "body_composition", "health_flags", "wearable_sync", "created_at"],
      properties: {
        member_id: {
          bsonType: "int",
          description: "Relational member_id foreign reference, must be an integer"
        },
        body_composition: {
          bsonType: "object",
          required: ["weight_kg", "height_cm", "bmi", "body_fat_pct"],
          properties: {
            weight_kg: { bsonType: ["double", "int"], minimum: 30, maximum: 300 },
            height_cm: { bsonType: ["double", "int"], minimum: 100, maximum: 250 },
            bmi: { bsonType: ["double", "int"] },
            body_fat_pct: { bsonType: ["double", "int"], minimum: 3, maximum: 60 },
            skeletal_muscle_mass_kg: { bsonType: ["double", "int"] }
          }
        },
        cardiovascular_metrics: {
          bsonType: "object",
          properties: {
            resting_heart_rate_bpm: { bsonType: "int", minimum: 35, maximum: 140 },
            blood_pressure: {
              bsonType: "object",
              properties: {
                systolic: { bsonType: "int" },
                diastolic: { bsonType: "int" }
              }
            },
            vo2_max: { bsonType: ["double", "int"] }
          }
        },
        health_flags: {
          bsonType: "array",
          items: { bsonType: "string" },
          description: "List of allergies, prior injuries, or medical restrictions"
        },
        wearable_sync: {
          bsonType: "object",
          properties: {
            device_brand: { enum: ["Apple Watch", "Garmin", "Whoop", "Fitbit", "None"] },
            last_sync_time: { bsonType: "date" },
            daily_step_avg: { bsonType: "int" },
            sleep_quality_score: { bsonType: "int", minimum: 0, maximum: 100 }
          }
        },
        historical_checkins: {
          bsonType: "array",
          items: {
            bsonType: "object",
            properties: {
              date: { bsonType: "date" },
              weight_recorded: { bsonType: ["double", "int"] },
              notes: { bsonType: "string" }
            }
          }
        },
        created_at: { bsonType: "date" }
      }
    }
  }
});

// ----------------------------------------------------------------------------
// 4. Create Secondary & Compound Indexes for High-Performance Queries
// ----------------------------------------------------------------------------
db.member_biometrics.createIndex({ "member_id": 1 }, { unique: true });
db.member_biometrics.createIndex({ "body_composition.bmi": 1, "body_composition.body_fat_pct": 1 });
db.member_biometrics.createIndex({ "health_flags": 1 });

// ----------------------------------------------------------------------------
// 5. CRUD OPERATION 1: CREATE (Insert Many Documents)
// ----------------------------------------------------------------------------
db.member_biometrics.insertMany([
  {
    member_id: NumberInt(1),
    body_composition: {
      weight_kg: 82.5,
      height_cm: 180.0,
      bmi: 25.46,
      body_fat_pct: 14.8,
      skeletal_muscle_mass_kg: 42.1
    },
    cardiovascular_metrics: {
      resting_heart_rate_bpm: NumberInt(58),
      blood_pressure: { systolic: NumberInt(118), diastolic: NumberInt(76) },
      vo2_max: 48.2
    },
    health_flags: ["Mild left shoulder impingement", "No dairy post-workout"],
    wearable_sync: {
      device_brand: "Garmin",
      last_sync_time: new Date("2026-03-06T08:30:00Z"),
      daily_step_avg: NumberInt(11400),
      sleep_quality_score: NumberInt(88)
    },
    historical_checkins: [
      { date: new Date("2026-02-01"), weight_recorded: 84.0, notes: "Initial intake assessment" },
      { date: new Date("2026-02-15"), weight_recorded: 83.2, notes: "Cardio phase check" },
      { date: new Date("2026-03-01"), weight_recorded: 82.5, notes: "Lean mass progression" }
    ],
    created_at: new Date("2026-02-01T10:00:00Z")
  },
  {
    member_id: NumberInt(2),
    body_composition: {
      weight_kg: 62.0,
      height_cm: 165.0,
      bmi: 22.77,
      body_fat_pct: 21.5,
      skeletal_muscle_mass_kg: 26.8
    },
    cardiovascular_metrics: {
      resting_heart_rate_bpm: NumberInt(64),
      blood_pressure: { systolic: NumberInt(112), diastolic: NumberInt(72) },
      vo2_max: 41.5
    },
    health_flags: ["Asthma (carries inhaler)"],
    wearable_sync: {
      device_brand: "Apple Watch",
      last_sync_time: new Date("2026-03-06T09:15:00Z"),
      daily_step_avg: NumberInt(9800),
      sleep_quality_score: NumberInt(82)
    },
    historical_checkins: [
      { date: new Date("2026-02-03"), weight_recorded: 63.5, notes: "Initial baseline" },
      { date: new Date("2026-03-01"), weight_recorded: 62.0, notes: "Good endurance response" }
    ],
    created_at: new Date("2026-02-03T14:30:00Z")
  },
  {
    member_id: NumberInt(7),
    body_composition: {
      weight_kg: 91.0,
      height_cm: 178.0,
      bmi: 28.72,
      body_fat_pct: 24.2,
      skeletal_muscle_mass_kg: 38.5
    },
    cardiovascular_metrics: {
      resting_heart_rate_bpm: NumberInt(74),
      blood_pressure: { systolic: NumberInt(128), diastolic: NumberInt(82) },
      vo2_max: 37.8
    },
    health_flags: ["Lower back stiffness", "Hypertension stage 1 monitor"],
    wearable_sync: {
      device_brand: "Whoop",
      last_sync_time: new Date("2026-03-05T22:00:00Z"),
      daily_step_avg: NumberInt(7200),
      sleep_quality_score: NumberInt(69)
    },
    historical_checkins: [
      { date: new Date("2026-03-01"), weight_recorded: 91.0, notes: "VIP onboarding and posture test" }
    ],
    created_at: new Date("2026-03-01T17:30:00Z")
  }
]);

// ----------------------------------------------------------------------------
// 6. CRUD OPERATION 2: READ (Find, Filter, Projection, Aggregation Pipeline)
// ----------------------------------------------------------------------------
// A. Retrieve members requiring special medical/injury attention
print("=== Members with Health/Injury Flags ===");
db.member_biometrics.find(
  { "health_flags": { $exists: true, $ne: [] } },
  { "member_id": 1, "health_flags": 1, "cardiovascular_metrics.blood_pressure": 1, _id: 0 }
).pretty();

// B. Aggregation Pipeline: Calculate average BMI, VO2 Max, and Step Count by Wearable Brand
print("=== Biometric Aggregation by Wearable Brand ===");
db.member_biometrics.aggregate([
  {
    $group: {
      _id: "$wearable_sync.device_brand",
      member_count: { $sum: 1 },
      avg_bmi: { $avg: "$body_composition.bmi" },
      avg_vo2_max: { $avg: "$cardiovascular_metrics.vo2_max" },
      avg_daily_steps: { $avg: "$wearable_sync.daily_step_avg" }
    }
  },
  { $sort: { avg_daily_steps: -1 } }
]).pretty();

// ----------------------------------------------------------------------------
// 7. CRUD OPERATION 3: UPDATE (Atomic $set, $push, and $inc)
// ----------------------------------------------------------------------------
// Append a new progress checkin and update resting heart rate after conditioning
db.member_biometrics.updateOne(
  { "member_id": NumberInt(1) },
  {
    $push: {
      "historical_checkins": {
        date: new Date(),
        weight_recorded: 82.0,
        notes: "Target bench press and squat PR achieved"
      }
    },
    $set: {
      "cardiovascular_metrics.resting_heart_rate_bpm": NumberInt(56),
      "wearable_sync.last_sync_time": new Date()
    }
  }
);

// ----------------------------------------------------------------------------
// 8. CRUD OPERATION 4: DELETE
// ----------------------------------------------------------------------------
// Remove a test record or inactive member biometric profile
db.member_biometrics.deleteOne({ "member_id": NumberInt(99) });