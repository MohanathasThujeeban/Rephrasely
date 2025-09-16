import time
import re
from typing import Dict, List, Any

class TextService:
    """Mock service class for text processing operations - for testing UI"""
    
    def __init__(self):
        print("🔧 Initializing Mock TextService...")
        print("✅ Mock TextService initialized successfully")
    
    def summarize(self, text: str, max_length: int = 150, min_length: int = 50) -> Dict[str, Any]:
        """Mock summarization for testing"""
        print(f"📝 Mock summarizing text (length: {len(text)})")
        
        start_time = time.time()
        
        # Simple mock summary - take first few sentences
        sentences = re.split(r'[.!?]+', text)
        sentences = [s.strip() for s in sentences if s.strip()]
        
        # Take first 2-3 sentences as summary
        summary_sentences = sentences[:min(3, len(sentences))]
        summary = '. '.join(summary_sentences)
        
        if summary and not summary.endswith('.'):
            summary += '.'
        
        # Mock word counts
        original_words = len(text.split())
        summary_words = len(summary.split())
        
        processing_time = time.time() - start_time
        
        result = {
            'summary': summary or "This is a mock summary of your text for testing purposes.",
            'original_word_count': original_words,
            'summary_word_count': summary_words,
            'compression_ratio': summary_words / original_words if original_words > 0 else 0,
            'processing_time': processing_time,
            'success': True
        }
        
        print(f"✅ Mock summary completed in {processing_time:.2f}s")
        return result
    
    def paraphrase(self, text: str, num_return_sequences: int = 1) -> Dict[str, Any]:
        """Mock paraphrasing for testing"""
        print(f"🔄 Mock paraphrasing text (length: {len(text)})")
        
        start_time = time.time()
        
        # Simple mock paraphrase - just rearrange or add synonyms
        mock_paraphrases = [
            f"Here is a rephrased version: {text}",
            f"This can be expressed as: {text}",
            f"An alternative way to say this: {text}"
        ]
        
        # Select based on requested variations
        variations = mock_paraphrases[:min(num_return_sequences, len(mock_paraphrases))]
        primary_paraphrase = variations[0] if variations else f"Paraphrased: {text}"
        
        original_words = len(text.split())
        paraphrase_words = len(primary_paraphrase.split())
        
        processing_time = time.time() - start_time
        
        result = {
            'paraphrase': primary_paraphrase,
            'variations': variations[1:] if len(variations) > 1 else [],
            'original_word_count': original_words,
            'paraphrase_word_count': paraphrase_words,
            'processing_time': processing_time,
            'success': True
        }
        
        print(f"✅ Mock paraphrase completed in {processing_time:.2f}s")
        return result
    
    def analyze_text(self, text: str) -> Dict[str, Any]:
        """Mock text analysis for testing"""
        print(f"📊 Mock analyzing text (length: {len(text)})")
        
        start_time = time.time()
        
        # Simple analysis
        word_count = len(text.split())
        char_count = len(text)
        sentence_count = len(re.split(r'[.!?]+', text))
        
        # Mock scores
        readability_score = min(100, max(0, 100 - (word_count / 10)))
        sentiment_score = 0.5  # Neutral
        
        processing_time = time.time() - start_time
        
        result = {
            'word_count': word_count,
            'character_count': char_count,
            'sentence_count': sentence_count,
            'readability_score': readability_score,
            'sentiment_score': sentiment_score,
            'processing_time': processing_time,
            'success': True
        }
        
        print(f"✅ Mock analysis completed in {processing_time:.2f}s")
        return result