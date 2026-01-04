# backend/src/main.py

from flask import Flask
from flask_cors import CORS
from api.location_api import app as location_app
from api.events_api import events_api
from api.recommend_api import recommend_api

app = location_app
CORS(app)

# Register additional API routes
app.register_blueprint(events_api)

# NEW route
app.register_blueprint(recommend_api)

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)
