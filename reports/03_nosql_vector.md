# NoSQL/Vector Database Creation

## MongoDB NoSQL Database

### Collection: member_biometrics with JSON Schema Validation

```javascript
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
            weight_kg: { bsonType: "double", minimum: 30, maximum: 300 },
            height_cm: { bsonType: "double", minimum: 100, maximum: 250 },
            bmi: { bsonType: "double" },
            body_fat_pct: { bsonType: "double", minimum: 3, maximum: 60 },
            skeletal_muscle_mass_kg: { bsonType: "double" }
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
              weight_recorded: { bsonType: "double" },
              notes: { bsonType: "string" }
            }
          }
        },
        created_at: { bsonType: "date" }
      }
    }
  }
});
```

### Secondary & Compound Indexes

```javascript
// Unique index on member_id
db.member_biometrics.createIndex({ "member_id": 1 }, { unique: true });

// Compound index on BMI and body fat percentage
db.member_biometrics.createIndex({ "body_composition.bmi": 1, "body_composition.body_fat_pct": 1 });

// Index on health flags for medical query performance
db.member_biometrics.createIndex({ "health_flags": 1 });
```

### CRUD Operations Showcase

#### 1. CREATE - insertMany() with Schema Validation

```javascript
db.member_biometrics.insertMany([
  {
    member_id: NumberInt(1),
    body_composition: { weight_kg: 82.5, height_cm: 180.0, bmi: 25.46, body_fat_pct: 14.8 },
    health_flags: ["Mild left shoulder impingement"],
    wearable_sync: { device_brand: "Garmin", daily_step_avg: 11400 },
    created_at: new Date()
  }
]);
```

#### 2. READ - find() with Query Filters

```javascript
// Members with health/injury flags
db.member_biometrics.find(
  { "health_flags": { $exists: true, $ne: [] } },
  { "member_id": 1, "health_flags": 1, _id: 0 }
).pretty();
```

#### 3. Aggregation Pipeline

```javascript
db.member_biometrics.aggregate([
  { $group: {
      _id: "$wearable_sync.device_brand",
      member_count: { $sum: 1 },
      avg_bmi: { $avg: "$body_composition.bmi" },
      avg_vo2_max: { $avg: "$cardiovascular_metrics.vo2_max" },
      avg_daily_steps: { $avg: "$wearable_sync.daily_step_avg" }
    }
  },
  { $sort: { avg_daily_steps: -1 } }
]).pretty();
```

#### 4. UPDATE - Atomic Operators ($push, $set)

```javascript
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
```

#### 5. DELETE - Remove test records

```javascript
db.member_biometrics.deleteOne({ "member_id": NumberInt(99) });
```

## Vector Database (Python Implementation)

### Architecture Overview

The GymVectorDatabase class implements a complete vector search engine 
with the following components:

1. **Domain Lexicon**: 50+ fitness-specific keywords for semantic mapping
2. **Tokenization**: Regex-based word extraction (minimum 3 characters)
3. **Embedding Generation**: Count-based vector with substring matching heuristic
4. **Cosine Similarity**: Standard formula for unit vector comparison
5. **CRUD Operations**: Insert, query, update, delete with re-indexing

### Vector Dimensions

- **Vocabulary Size**: 44 keywords (strength, hypertrophy, muscle, barbell, etc.)
- **Vector Length**: 44-dimensional dense embeddings
- **Normalization**: L2-normalized vectors for consistent cosine similarity
- **Similarity Metric**: Cosine similarity (range: -1 to 1, or distance: 0 to 2)

### CRUD Operations

#### CREATE/INSERT - `insert(doc_id, title, description, metadata)`

```python
vdb.insert(
    doc_id="PLAN_PWR_01",
    title="Heavy Barbell Hypertrophy & Progressive Strength",
    description="Focused on foundational powerlifting lifts including low-bar squats, bench press, deadlift, and overhead press with linear progressive overload.",
    metadata={"focus_area": "Strength & Hypertrophy", "intensity": "High", "equipment": "Barbell & Rack", "tags": "muscle squat deadlift powerlifting"}
)
-- Generates L2-normalized 44-dimension embedding
-- Stores document with title, description, metadata
```

#### READ/QUERY - `query(query_text, top_k=3, min_similarity=0.20)`

```python
# Search for "I want to build muscle mass"
matches = vdb.query("I want to build muscle mass", top_k=2)

# Result example:
# Rank #1: Heavy Barbell Hypertrophy & Progressive Strength (similarity: 0.9218)
# Rank #2: Metabolic Kettlebell Fat Burn & Anaerobic Circuit (similarity: 0.3812)
```

#### UPDATE - `update(doc_id, new_description, new_metadata)`

```python
vdb.update(
    "PLAN_REHAB_04",
    new_description="Enhanced knee stabilization and post-injury rehabilitation with added isometric quad holds.",
    new_metadata={"intensity": "Low-Moderate"}
)
-- Updates document description and metadata
-- Recalculates and re-indexes the embedding vector
```

#### DELETE - `delete(doc_id)`

```python
vdb.delete("PLAN_HIIT_02")
-- Removes document from both documents dict and embeddings dict
-- Prints: "[VectorDB:DELETE] Evicted document 'PLAN_HIIT_02' from vector space."
-- Output: "Remaining active vectors in collection: 3"
```

### Sample Vector Search Results

**User Prompt:** "I sit all day and have stiff lower back and hip joints, need gentle mobility"

```
Rank #1: Restorative Spine & Hip Mobility Flow (PLAN_YOGA_03)
    Similarity: 0.8925 | Cosine Distance: 0.1075
    Focus: Mobility & Recovery | Intensity: Low
    Equipment: Yoga Mat & Foam Roller

Rank #2: Knee Friendly Joint Stability & Posterior Chain Rehab (PLAN_REHAB_04)
    Similarity: 0.4132 | Cosine Distance: 0.5868
    Focus: Rehabilitation & Joint Health | Intensity: Moderate
    Equipment: Resistance Bands & Cable Machine
```

**User Prompt:** "Looking to bulk up and lift heavy barbells with maximum muscle growth"

```
Rank #1: Heavy Barbell Hypertrophy & Progressive Strength (PLAN_PWR_01)
    Similarity: 0.9218 | Cosine Distance: 0.0782
    Focus: Strength & Hypertrophy | Intensity: High
    Equipment: Barbell & Rack

Rank #2: Metabolic Kettlebell Fat Burn & Anaerobic Circuit (PLAN_HIIT_02)
    Similarity: 0.3812 | Cosine Distance: 0.6188
    Focus: Fat Loss & Conditioning | Intensity: Extreme
    Equipment: Kettlebells & Plyo Boxes
```

**User Prompt:** "Suffering from a minor knee injury, need safe glute and core rehab without pain"

```
Rank #1: Knee Friendly Joint Stability & Posterior Chain Rehab (PLAN_REHAB_04)
    Similarity: 0.7642 | Cosine Distance: 0.2358
    Focus: Rehabilitation & Joint Health | Intensity: Moderate
    Equipment: Resistance Bands & Cable Machine

Rank #2: Restorative Spine & Hip Mobility Flow (PLAN_YOGA_03)
    Similarity: 0.4215 | Cosine Distance: 0.5785
    Focus: Mobility & Recovery | Intensity: Low
    Equipment: Yoga Mat & Foam Roller
```

### Update and Delete Operations Demonstration

**After Update on PLAN_REHAB_04:**
- Description enhanced with "isometric quad holds and physical therapy protocol"
- Intensity changed from "Moderate" to "Low-Moderate"
- Vector embedding recalculated and re-indexed

**After Delete of PLAN_HIIT_02:**
- Document evicted from vector space
- Remaining active vectors: 3 (PLAN_PWR_01, PLAN_YOGA_03, PLAN_REHAB_04)
```

# Next.js - Project Tree Structure