from app import create_app
import os
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

app = create_app()

if __name__ == '__main__':
    host = os.getenv('API_HOST', '0.0.0.0')
    port = int(os.getenv('API_PORT', 5000))
    debug = os.getenv('FLASK_DEBUG', 'True').lower() == 'true'
    
    print(f"🚀 Starting Rephrasely API server on http://{host}:{port}")
    app.run(host=host, port=port, debug=debug)