from flask import Flask
from flask_cors import CORS
import os
from dotenv import load_dotenv

def create_app():
    app = Flask(__name__)
    
    # Load environment variables
    load_dotenv()
    
    # Configure CORS
    cors_origins = os.getenv('CORS_ORIGINS', '*').split(',')
    CORS(app, origins=cors_origins)
    
    # Configuration
    app.config['MAX_CONTENT_LENGTH'] = 32 * 1024 * 1024  # 32MB max file size
    app.config['JSON_SORT_KEYS'] = False
    
    # Register blueprints
    from app.routes.text_processing import text_bp
    from app.routes.health import health_bp
    
    app.register_blueprint(health_bp)
    app.register_blueprint(text_bp, url_prefix='/api')
    
    return app