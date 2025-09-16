# Rephrasely Backend API

A powerful Python Flask API for text processing with AI-powered summarization, paraphrasing, and text analysis.

## 🚀 Features

- **Text Summarization**: Intelligent text summarization using BART models
- **Text Paraphrasing**: Advanced paraphrasing with multiple variations
- **Text Analysis**: Comprehensive text statistics and sentiment analysis
- **Long Text Support**: Handles up to **15,000 words** (75,000 characters)
- **Chunked Processing**: Automatically handles long texts by intelligent chunking

## 📋 API Endpoints

### Health Check
```http
GET /health
```

### Text Summarization
```http
POST /api/summarize
Content-Type: application/json

{
  "text": "Your text here...",
  "max_length": 150,
  "min_length": 50
}
```

### Text Paraphrasing
```http
POST /api/paraphrase
Content-Type: application/json

{
  "text": "Your text here...",
  "variations": 2
}
```

### Text Analysis
```http
POST /api/analyze
Content-Type: application/json

{
  "text": "Your text here..."
}
```

## 🛠️ Installation

1. **Clone the repository**
```bash
git clone https://github.com/MohanathasThujeeban/Rephrasely.git
cd Rephrasely/backend
```

2. **Create virtual environment**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies**
```bash
pip install -r requirements.txt
```

4. **Run the server**
```bash
python run.py
```

The server will start at: http://127.0.0.1:5000

## 📊 Limits

- **Maximum text length**: 15,000 words (~75,000 characters)
- **File size limit**: 32MB
- **Request timeout**: 60 seconds for processing

## 🧪 Testing

Run the test script to verify all endpoints:
```bash
python test_api.py
```

## 🤖 AI Models Used

- **Summarization**: DistilBART-CNN (lightweight and efficient)
- **Paraphrasing**: Pegasus Paraphrase / T5-Small (fallback)
- **Sentiment Analysis**: Twitter-RoBERTa-Base

## 🔧 Configuration

Edit `.env` file to customize:
```env
FLASK_ENV=development
FLASK_DEBUG=True
MAX_WORDS=15000
API_HOST=0.0.0.0
API_PORT=5000
```

## 📱 Flutter Integration

The API is designed to work seamlessly with the Rephrasely Flutter app. CORS is enabled for local development.

## 🔍 Example Response

### Summarization Response
```json
{
  "success": true,
  "original_text": "Your original text...",
  "processed_text": "Summarized version...",
  "processing_time": 2.34,
  "word_count_original": 500,
  "word_count_processed": 75,
  "compression_ratio": 0.15
}
```

### Analysis Response
```json
{
  "success": true,
  "analysis": {
    "word_count": 500,
    "sentence_count": 25,
    "reading_time_minutes": 2.5,
    "readability_score": 65.2,
    "sentiment": {
      "label": "POSITIVE",
      "score": 0.842
    }
  }
}
```

## 🚀 Performance

- **First request**: ~10-30 seconds (model loading)
- **Subsequent requests**: ~1-5 seconds
- **Long texts (10k+ words)**: ~5-15 seconds (chunked processing)

## 🔒 Error Handling

The API provides comprehensive error responses:
- `400`: Bad request / Invalid input
- `413`: Text too long
- `500`: Processing error

## 🌐 Production Deployment

For production, use Gunicorn:
```bash
gunicorn -w 4 -b 0.0.0.0:5000 run:app
```