# backend/src/api/recommend_api.py

from flask import Blueprint, request, jsonify
import pandas as pd
import joblib
import numpy as np
import os
from math import radians, sin, cos, sqrt, atan2

recommend_api = Blueprint("recommend_api", __name__)

# Load model + scaler + dataset only once (FAST - cached)
CURRENT_DIR = os.path.dirname(os.path.abspath(__file__))    # backend/src/api
BACKEND_DIR = os.path.abspath(os.path.join(CURRENT_DIR, "..", ".."))  # backend/
MODELS_DIR = os.path.join(BACKEND_DIR, "models")
DATA_DIR = os.path.join(BACKEND_DIR, "data")

model = joblib.load(os.path.join(MODELS_DIR, "model.pkl"))
scaler = joblib.load(os.path.join(MODELS_DIR, "scaler.pkl"))
df = pd.read_csv(os.path.join(DATA_DIR, "heritage_clustered.csv"))

# Helper: Haversine Distance
def haversine(lat1, lon1, lat2, lon2):
    R = 6371000  # meters

    dLat = radians(lat2 - lat1)
    dLon = radians(lon2 - lon1)

    a = (sin(dLat / 2) ** 2 +
         cos(radians(lat1)) * cos(radians(lat2)) * sin(dLon / 2) ** 2)

    c = 2 * atan2(sqrt(a), sqrt(1 - a))
    return R * c

# API 1: Predict cluster for user's GPS location
@recommend_api.route("/predict-cluster", methods=["POST"])
def predict_cluster():
    data = request.get_json()
    lat, lon = data.get("lat"), data.get("lon")

    if lat is None or lon is None:
        return jsonify({"error": "lat & lon required"}), 400

    # scale input
    scaled = scaler.transform(np.array([[lat, lon]]))

    # predict cluster
    cluster_id = int(model.predict(scaled)[0])

    return jsonify({"cluster": cluster_id})

# API 2: Get all sites inside a cluster
@recommend_api.route("/cluster-sites/<int:cluster_id>", methods=["GET"])
def cluster_sites(cluster_id):
    sites = df[df["cluster"] == cluster_id][["site_id", "site_name", "lat", "lon"]]

    return jsonify({
        "cluster_id": cluster_id,
        "count": len(sites),
        "sites": sites.to_dict(orient="records")
    })

# API 3: Hybrid Recommendation (ML + Geofence + Events)
@recommend_api.route("/recommend-nearby", methods=["POST"])
def recommend_nearby():
    data = request.get_json()
    lat, lon = data.get("lat"), data.get("lon")

    # Default radius = 1500 m
    radius_m = data.get("radius_m", 1500)

    if lat is None or lon is None:
        return jsonify({"error": "lat & lon required"}), 400

    # 1. Predict ML cluster
    cluster_scaled = scaler.transform(np.array([[lat, lon]]))
    cluster_id = int(model.predict(cluster_scaled)[0])

    # 2. Filter to sites in that cluster
    cluster_subset = df[df["cluster"] == cluster_id]

    final_results = []

    # 3. Check geofence & return events for that site
    unique_sites = cluster_subset.drop_duplicates(subset=["site_id"])

    for _, row in unique_sites.iterrows():

        dist = haversine(lat, lon, row["lat"], row["lon"])

        if dist <= radius_m:

            # extract all events for this site
            site_events = df[df["site_id"] == row["site_id"]][
                ["event_name", "year", "description"]
            ].to_dict(orient="records")

            final_results.append({
                "site_id": row["site_id"],
                "site_name": row["site_name"],
                "distance_m": round(dist, 2),
                "events": site_events
            })

    return jsonify({
        "user_cluster": cluster_id,
        "radius_m": radius_m,
        "nearby": final_results
    })
