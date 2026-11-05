#!/usr/bin/env python3
"""
============================================================================
DBMS MINI PROJECT: GYM MEMBERSHIP MANAGER
File: 06_vector_database.py
Students: Priyansh Soni (SRN: PES1UG24CS344)
          Pulkit Bhardwaj (SRN: PES1UG24CS346)
Institution: PES University, Bengaluru
Component: Vector Database & Semantic Similarity Engine
Description: High-dimensional vector database implementation supporting:
             1. Vector Collection Initialization & Schema Definition
             2. Dense Vector Embeddings Generation (Semantic Text Vectorizer)
             3. CRUD: CREATE (Vector Ingestion with Rich Metadata)
             4. CRUD: READ (Cosine Distance Semantic Similarity Query & Top-K Retrieval)
             5. CRUD: UPDATE (Vector Upsert, Metric & Metadata Modification)
             6. CRUD: DELETE (Vector Eviction & Index Rebalancing)
============================================================================
"""

import math
import re
from typing import List, Dict, Any, Tuple

class GymVectorDatabase:
    """
    High-performance Vector Database collection store for Gym Workout Plans
    and Semantic Recommendation Matching.
    """
    def __init__(self, collection_name: str = "gym_workout_recommendations"):
        self.collection_name = collection_name
        self.vocabulary: Dict[str, int] = {}
        self.documents: Dict[str, Dict[str, Any]] = {}
        self.embeddings: Dict[str, List[float]] = {}
        self._build_domain_lexicon()

    def _build_domain_lexicon(self):
        """Initializes domain vocabulary vector basis for fitness semantic space."""
        keywords = [
            "strength", "hypertrophy", "muscle", "barbell", "progressive", "overload",
            "squat", "deadlift", "bench", "powerlifting", "hiit", "cardio", "fat",
            "loss", "metabolic", "sweat", "endurance", "stamina", "kettlebell",
            "circuits", "yoga", "mobility", "flexibility", "vinyasa", "ashtanga",
            "joint", "posture", "spine", "recovery", "rehabilitation", "knee",
            "injury", "core", "calisthenics", "crossfit", "plyometrics", "agility",
            "aerobic", "lean", "shred", "conditioning", "glutes", "hamstrings", "chest"
        ]
        self.vocabulary = {word: idx for idx, word in enumerate(keywords)}

    def _tokenize(self, text: str) -> List[str]:
        return re.findall(r"\b[a-z]{3,}\b", text.lower())

    def generate_embedding(self, text: str) -> List[float]:
        """
        Generates an L2-normalized dense vector representation in semantic space.
        """
        tokens = self._tokenize(text)
        vector = [0.0] * len(self.vocabulary)
        
        for t in tokens:
            if t in self.vocabulary:
                vector[self.vocabulary[t]] += 1.0
            else:
                # Substring / root matching heuristic for morphology
                for v_word, idx in self.vocabulary.items():
                    if v_word in t or t in v_word:
                        vector[idx] += 0.5

        # L2 Vector Normalization
        norm = math.sqrt(sum(v ** 2 for v in vector))
        if norm > 0:
            vector = [round(v / norm, 4) for v in vector]
        else:
            vector = [1.0 / math.sqrt(len(vector))] * len(vector)
        return vector

    def cosine_similarity(self, vec_a: List[float], vec_b: List[float]) -> float:
        """Calculates cosine similarity between two unit vectors."""
        dot_product = sum(a * b for a, b in zip(vec_a, vec_b))
        norm_a = math.sqrt(sum(a ** 2 for a in vec_a))
        norm_b = math.sqrt(sum(b ** 2 for b in vec_b))
        if norm_a == 0 or norm_b == 0:
            return 0.0
        return dot_product / (norm_a * norm_b)

    # -------------------------------------------------------------------------
    # CRUD 1: CREATE (Insert Vector Document with Metadata)
    # -------------------------------------------------------------------------
    def insert(self, doc_id: str, title: str, description: str, metadata: Dict[str, Any]):
        embedding = self.generate_embedding(f"{title} {description} {metadata.get('tags', '')}")
        self.documents[doc_id] = {
            "id": doc_id,
            "title": title,
            "description": description,
            "metadata": metadata
        }
        self.embeddings[doc_id] = embedding
        print(f"[VectorDB:INSERT] Stored '{doc_id}' ({title}) | Vector dims: {len(embedding)}")

    # -------------------------------------------------------------------------
    # CRUD 2: READ (Semantic Top-K Query with Cosine Distance)
    # -------------------------------------------------------------------------
    def query(self, query_text: str, top_k: int = 3, min_similarity: float = 0.20) -> List[Dict[str, Any]]:
        query_vector = self.generate_embedding(query_text)
        results = []

        for doc_id, emb in self.embeddings.items():
            sim = self.cosine_similarity(query_vector, emb)
            doc = self.documents[doc_id]
            results.append({
                "id": doc_id,
                "title": doc["title"],
                "similarity_score": round(sim, 4),
                "cosine_distance": round(1.0 - sim, 4),
                "focus_area": doc["metadata"].get("focus_area"),
                "intensity": doc["metadata"].get("intensity"),
                "target_equipment": doc["metadata"].get("equipment"),
                "description": doc["description"]
            })

        results.sort(key=lambda x: x["similarity_score"], reverse=True)
        return [r for r in results[:top_k] if r["similarity_score"] >= min_similarity]

    # -------------------------------------------------------------------------
    # CRUD 3: UPDATE (Update Metadata and Recalculate Embedding)
    # -------------------------------------------------------------------------
    def update(self, doc_id: str, new_description: str = None, new_metadata: Dict[str, Any] = None):
        if doc_id not in self.documents:
            raise KeyError(f"Document ID '{doc_id}' not found.")
        
        doc = self.documents[doc_id]
        if new_description:
            doc["description"] = new_description
        if new_metadata:
            doc["metadata"].update(new_metadata)

        # Re-index vector
        self.embeddings[doc_id] = self.generate_embedding(
            f"{doc['title']} {doc['description']} {doc['metadata'].get('tags', '')}"
        )
        print(f"[VectorDB:UPDATE] Updated document '{doc_id}' and re-indexed vector.")

    # -------------------------------------------------------------------------
    # CRUD 4: DELETE (Evict Vector Document)
    # -------------------------------------------------------------------------
    def delete(self, doc_id: str) -> bool:
        if doc_id in self.documents:
            del self.documents[doc_id]
            del self.embeddings[doc_id]
            print(f"[VectorDB:DELETE] Evicted document '{doc_id}' from vector space.")
            return True
        return False


def run_vector_db_demo():
    print("=" * 78)
    print("GYM MEMBERSHIP MANAGER - VECTOR DATABASE CRUD & SEMANTIC QUERY ENGINE")
    print("=" * 78)
    vdb = GymVectorDatabase()

    # 1. Ingest Sample Curated Workout Plans into Vector Store
    print("\n--- 1. VECTOR CRUD: INSERT / INGESTION ---")
    vdb.insert(
        doc_id="PLAN_PWR_01",
        title="Heavy Barbell Hypertrophy & Progressive Strength",
        description="Focused on foundational powerlifting lifts including low-bar squats, bench press, deadlift, and overhead press with linear progressive overload.",
        metadata={"focus_area": "Strength & Hypertrophy", "intensity": "High", "equipment": "Barbell & Rack", "tags": "muscle squat deadlift powerlifting"}
    )
    vdb.insert(
        doc_id="PLAN_HIIT_02",
        title="Metabolic Kettlebell Fat Burn & Anaerobic Circuit",
        description="High-tempo interval training designed for rapid fat loss, elevated cardiac output, sweat induction, and VO2 stamina enhancement.",
        metadata={"focus_area": "Fat Loss & Conditioning", "intensity": "Extreme", "equipment": "Kettlebells & Plyo Boxes", "tags": "hiit cardio fat loss sweat endurance"}
    )
    vdb.insert(
        doc_id="PLAN_YOGA_03",
        title="Restorative Spine & Hip Mobility Flow",
        description="Low impact yoga postures emphasizing spinal decompression, hamstring flexibility, joint lubrication, and postural alignment for desk workers.",
        metadata={"focus_area": "Mobility & Recovery", "intensity": "Low", "equipment": "Yoga Mat & Foam Roller", "tags": "yoga mobility flexibility spine posture recovery"}
    )
    vdb.insert(
        doc_id="PLAN_REHAB_04",
        title="Knee Friendly Joint Stability & Posterior Chain Rehab",
        description="Zero axial knee compression routine targeting hamstrings, glute activation, core bracing, and physical therapy athletic recovery.",
        metadata={"focus_area": "Rehabilitation & Joint Health", "intensity": "Moderate", "equipment": "Resistance Bands & Cable Machine", "tags": "knee injury recovery joint core rehabilitation"}
    )

    # 2. Vector Semantic Similarity Search
    print("\n--- 2. VECTOR CRUD: READ / SEMANTIC SIMILARITY SEARCH ---")
    member_prompts = [
        "I sit all day and have stiff lower back and hip joints, need gentle mobility",
        "Looking to bulk up and lift heavy barbells with maximum muscle growth",
        "Suffering from a minor knee injury, need safe glute and core rehab without pain"
    ]

    for query_text in member_prompts:
        print(f"\n[USER PROMPT]: \"{query_text}\"")
        matches = vdb.query(query_text, top_k=2)
        for i, match in enumerate(matches, 1):
            print(f"  Rank #{i}: {match['title']} ({match['id']})")
            print(f"    Similarity: {match['similarity_score']:.4f} | Cosine Distance: {match['cosine_distance']:.4f}")
            print(f"    Focus: {match['focus_area']} | Intensity: {match['intensity']}")

    # 3. Vector Update Operation
    print("\n--- 3. VECTOR CRUD: UPDATE & RE-INDEXING ---")
    vdb.update(
        "PLAN_REHAB_04",
        new_description="Enhanced knee stabilization and post-injury rehabilitation with added isometric quad holds and physical therapy protocol.",
        new_metadata={"intensity": "Low-Moderate"}
    )

    # 4. Vector Delete Operation
    print("\n--- 4. VECTOR CRUD: DELETE ---")
    vdb.delete("PLAN_HIIT_02")
    print(f"Remaining active vectors in collection: {len(vdb.documents)}")
    print("=" * 78)


if __name__ == "__main__":
    run_vector_db_demo()