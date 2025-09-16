from flask import Blueprint, jsonify
import datetime

health_bp = Blueprint('health', __name__)

@health_bp.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({
        'status': 'healthy',
        'service': 'Rephrasely API',
        'version': '1.0.0',
        'timestamp': datetime.datetime.utcnow().isoformat(),
        'endpoints': {
            'summarize': '/api/summarize',
            'paraphrase': '/api/paraphrase',
            'analyze': '/api/analyze'
        }
    }), 200

@health_bp.route('/status', methods=['GET'])
def status():
    """Service status endpoint"""
    return jsonify({
        'service': 'Rephrasely API',
        'status': 'running',
        'uptime': 'online'
    }), 200