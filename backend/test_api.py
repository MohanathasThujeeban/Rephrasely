#!/usr/bin/env python3
"""
Test script for the Rephrasely API with long text support
"""

import requests
import json

# API base URL
BASE_URL = "http://127.0.0.1:5000/api"

# Test data - a long text (about 200 words)
LONG_TEXT = """
Artificial intelligence (AI) has emerged as one of the most transformative technologies of the 21st century, fundamentally reshaping how we work, communicate, and solve complex problems. At its core, AI refers to computer systems that can perform tasks typically requiring human intelligence, such as learning, reasoning, problem-solving, perception, and language understanding.

Machine learning, a subset of AI, has gained particular prominence due to its ability to analyze vast datasets and identify patterns that would be impossible for humans to detect manually. This capability has led to groundbreaking applications in healthcare, where AI systems can diagnose diseases from medical images with accuracy rivaling that of experienced physicians. In finance, algorithmic trading systems process millions of transactions per second, making split-second decisions based on market conditions and historical data.

The healthcare industry has witnessed remarkable advances through AI implementation. Deep learning algorithms can now detect early signs of cancer in mammograms, predict patient outcomes, and even assist in drug discovery by analyzing molecular structures and predicting their effectiveness. These developments have the potential to save countless lives and reduce healthcare costs globally.

Natural language processing (NLP) has enabled machines to understand and generate human language with increasing sophistication. Virtual assistants, chatbots, and translation services have become integral parts of our daily lives, breaking down language barriers and providing instant access to information and services.

However, the rapid advancement of AI also raises important ethical considerations. Questions about privacy, job displacement, algorithmic bias, and the potential for autonomous systems to make life-altering decisions without human oversight require careful consideration. As we continue to integrate AI into society, it's crucial that we develop frameworks for responsible AI development and deployment.

The future of AI holds immense promise, with potential applications in climate change mitigation, space exploration, education, and countless other fields. As we stand on the brink of even more sophisticated AI systems, including artificial general intelligence, society must prepare for both the opportunities and challenges that lie ahead.
"""

def test_summarization():
    """Test the summarization endpoint with long text"""
    print("🧪 Testing Summarization API...")
    
    data = {
        "text": LONG_TEXT,
        "max_length": 100,
        "min_length": 50
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/summarize",
            json=data,
            headers={"Content-Type": "application/json"},
            timeout=60
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Summarization successful!")
            print(f"📊 Original words: {result.get('word_count_original', 'N/A')}")
            print(f"📊 Summary words: {result.get('word_count_processed', 'N/A')}")
            print(f"⏱️ Processing time: {result.get('processing_time', 'N/A')}s")
            print(f"📝 Summary: {result.get('processed_text', 'N/A')}")
            print(f"📉 Compression ratio: {result.get('compression_ratio', 'N/A')}")
        else:
            print(f"❌ Error: {response.status_code}")
            print(f"Response: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")

def test_paraphrasing():
    """Test the paraphrasing endpoint"""
    print("\n🧪 Testing Paraphrasing API...")
    
    short_text = "AI is transforming healthcare by enabling more accurate diagnoses and personalized treatments."
    
    data = {
        "text": short_text,
        "variations": 2
    }
    
    try:
        response = requests.post(
            f"{BASE_URL}/paraphrase",
            json=data,
            headers={"Content-Type": "application/json"},
            timeout=60
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Paraphrasing successful!")
            print(f"📝 Original: {result.get('original_text', 'N/A')}")
            print(f"📝 Paraphrase: {result.get('processed_text', 'N/A')}")
            print(f"⏱️ Processing time: {result.get('processing_time', 'N/A')}s")
            if result.get('variations'):
                print(f"🔄 Variations: {result.get('variations')}")
        else:
            print(f"❌ Error: {response.status_code}")
            print(f"Response: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")

def test_analysis():
    """Test the text analysis endpoint"""
    print("\n🧪 Testing Analysis API...")
    
    data = {"text": LONG_TEXT}
    
    try:
        response = requests.post(
            f"{BASE_URL}/analyze",
            json=data,
            headers={"Content-Type": "application/json"},
            timeout=30
        )
        
        if response.status_code == 200:
            result = response.json()
            print("✅ Analysis successful!")
            analysis = result.get('analysis', {})
            print(f"📊 Word count: {analysis.get('word_count', 'N/A')}")
            print(f"📊 Sentence count: {analysis.get('sentence_count', 'N/A')}")
            print(f"📊 Reading time: {analysis.get('reading_time_minutes', 'N/A')} minutes")
            print(f"📊 Readability score: {analysis.get('readability_score', 'N/A')}")
            sentiment = analysis.get('sentiment', {})
            print(f"😊 Sentiment: {sentiment.get('label', 'N/A')} ({sentiment.get('score', 'N/A')})")
        else:
            print(f"❌ Error: {response.status_code}")
            print(f"Response: {response.text}")
            
    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed: {e}")

if __name__ == "__main__":
    print("🚀 Starting Rephrasely API Tests")
    print(f"📏 Test text length: {len(LONG_TEXT)} characters (~{len(LONG_TEXT.split())} words)")
    print("=" * 50)
    
    # Test all endpoints
    test_summarization()
    test_paraphrasing()
    test_analysis()
    
    print("\n" + "=" * 50)
    print("🏁 Tests completed!")