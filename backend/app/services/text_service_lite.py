import time
import re
import os
from typing import Dict, List, Any
import nltk
import textstat
from app.models.text_models import TextAnalysis

class TextService:
    """Lightweight service class for text processing operations"""
    
    def __init__(self):
        print("🔧 Initializing TextService...")
        
        # Initialize models lazily (only when needed)
        self._summarizer = None
        self._paraphraser = None
        self._sentiment_analyzer = None
        
        # Download NLTK data if needed
        self._download_nltk_data()
        print("✅ TextService initialized successfully")
    
    def _download_nltk_data(self):
        """Download required NLTK data"""
        try:
            nltk.data.find('tokenizers/punkt')
        except LookupError:
            print("📥 Downloading NLTK punkt tokenizer...")
            nltk.download('punkt', quiet=True)
        
        try:
            nltk.data.find('corpora/vader_lexicon')
        except LookupError:
            print("📥 Downloading NLTK vader lexicon...")
            nltk.download('vader_lexicon', quiet=True)
    
    def _load_transformers_model(self, model_type: str):
        """Load transformers model only when needed"""
        try:
            from transformers import pipeline
            
            if model_type == "summarization":
                print("🤖 Loading summarization model (this may take a moment)...")
                # Use a lighter, faster model
                self._summarizer = pipeline(
                    "summarization",
                    model="sshleifer/distilbart-cnn-6-6",
                    device=-1,  # CPU only for better compatibility
                    framework="pt"
                )
                print("✅ Summarization model loaded successfully")
                
            elif model_type == "paraphrasing":
                print("🤖 Loading paraphrasing model...")
                # Use T5-small for better compatibility
                self._paraphraser = pipeline(
                    "text2text-generation",
                    model="t5-small",
                    device=-1,
                    framework="pt"
                )
                print("✅ Paraphrasing model loaded successfully")
                
            elif model_type == "sentiment":
                print("🤖 Loading sentiment analysis model...")
                self._sentiment_analyzer = pipeline(
                    "sentiment-analysis",
                    model="distilbert-base-uncased-finetuned-sst-2-english",
                    device=-1
                )
                print("✅ Sentiment analysis model loaded successfully")
                
        except Exception as e:
            print(f"⚠️ Failed to load {model_type} model: {e}")
            return None
    
    def summarize(self, text: str, max_length: int = 150, min_length: int = 30) -> Dict[str, Any]:
        """Summarize text using DistilBART model"""
        start_time = time.time()
        
        try:
            # Load model if not already loaded
            if self._summarizer is None:
                self._load_transformers_model("summarization")
            
            # If model loading failed, use extractive summarization fallback
            if self._summarizer is None:
                return self._extractive_summarization(text, max_length)
            
            # Clean and prepare text
            cleaned_text = self._clean_text(text)
            original_word_count = len(cleaned_text.split())
            
            # Adjust lengths based on input
            max_length = min(max_length, max(50, original_word_count // 2))
            min_length = min(min_length, max_length // 2)
            
            # Generate summary
            result = self._summarizer(
                cleaned_text,
                max_length=max_length,
                min_length=min_length,
                do_sample=False,
                truncation=True
            )
            
            summary = result[0]['summary_text']
            summary_word_count = len(summary.split())
            
            processing_time = time.time() - start_time
            compression_ratio = summary_word_count / original_word_count if original_word_count > 0 else 0
            
            return {
                'summary': summary,
                'processing_time': processing_time,
                'original_word_count': original_word_count,
                'summary_word_count': summary_word_count,
                'compression_ratio': compression_ratio
            }
            
        except Exception as e:
            print(f"Error in summarization: {e}")
            # Fallback to extractive summarization
            return self._extractive_summarization(text, max_length)
    
    def _extractive_summarization(self, text: str, max_length: int) -> Dict[str, Any]:
        """Fallback extractive summarization using sentence ranking"""
        start_time = time.time()
        
        sentences = nltk.sent_tokenize(text)
        original_word_count = len(text.split())
        
        # Simple extractive summarization: take first few sentences
        target_sentences = min(3, len(sentences), max_length // 20)
        summary_sentences = sentences[:target_sentences]
        summary = ' '.join(summary_sentences)
        
        summary_word_count = len(summary.split())
        processing_time = time.time() - start_time
        compression_ratio = summary_word_count / original_word_count if original_word_count > 0 else 0
        
        return {
            'summary': summary,
            'processing_time': processing_time,
            'original_word_count': original_word_count,
            'summary_word_count': summary_word_count,
            'compression_ratio': compression_ratio
        }
    
    def paraphrase(self, text: str, num_return_sequences: int = 1) -> Dict[str, Any]:
        """Paraphrase text using T5 model"""
        start_time = time.time()
        
        try:
            # Load model if not already loaded
            if self._paraphraser is None:
                self._load_transformers_model("paraphrasing")
            
            # If model loading failed, use simple paraphrasing fallback
            if self._paraphraser is None:
                return self._simple_paraphrasing(text)
            
            cleaned_text = self._clean_text(text)
            original_word_count = len(cleaned_text.split())
            
            # Use T5 with paraphrasing prompt
            prompt = f"paraphrase: {cleaned_text}"
            result = self._paraphraser(
                prompt,
                max_length=len(cleaned_text.split()) + 20,
                num_return_sequences=num_return_sequences,
                temperature=0.7,
                do_sample=True,
                pad_token_id=self._paraphraser.tokenizer.eos_token_id
            )
            
            main_paraphrase = result[0]['generated_text'] if result else cleaned_text
            variations = [r['generated_text'] for r in result[1:]] if len(result) > 1 else []
            
            paraphrase_word_count = len(main_paraphrase.split())
            processing_time = time.time() - start_time
            
            return {
                'paraphrase': main_paraphrase,
                'variations': variations,
                'processing_time': processing_time,
                'original_word_count': original_word_count,
                'paraphrase_word_count': paraphrase_word_count
            }
            
        except Exception as e:
            print(f"Error in paraphrasing: {e}")
            return self._simple_paraphrasing(text)
    
    def _simple_paraphrasing(self, text: str) -> Dict[str, Any]:
        """Fallback simple paraphrasing using synonym replacement"""
        start_time = time.time()
        
        # Simple word replacement paraphrasing
        synonyms = {
            'good': 'excellent', 'bad': 'poor', 'big': 'large', 'small': 'tiny',
            'fast': 'quick', 'slow': 'gradual', 'happy': 'joyful', 'sad': 'melancholy',
            'important': 'significant', 'easy': 'simple', 'hard': 'difficult',
            'beautiful': 'stunning', 'ugly': 'unattractive', 'smart': 'intelligent'
        }
        
        words = text.split()
        paraphrased_words = []
        
        for word in words:
            clean_word = word.lower().strip('.,!?;:"')
            if clean_word in synonyms:
                # Replace with synonym while preserving case and punctuation
                replacement = synonyms[clean_word]
                if word[0].isupper():
                    replacement = replacement.capitalize()
                # Add back punctuation
                for char in '.,!?;:"':
                    if word.endswith(char):
                        replacement += char
                        break
                paraphrased_words.append(replacement)
            else:
                paraphrased_words.append(word)
        
        paraphrase = ' '.join(paraphrased_words)
        processing_time = time.time() - start_time
        
        return {
            'paraphrase': paraphrase,
            'variations': [],
            'processing_time': processing_time,
            'original_word_count': len(text.split()),
            'paraphrase_word_count': len(paraphrase.split())
        }
    
    def analyze(self, text: str) -> Dict[str, Any]:
        """Analyze text for various metrics"""
        try:
            # Basic statistics
            word_count = len(text.split())
            sentence_count = len(nltk.sent_tokenize(text))
            paragraph_count = len([p for p in text.split('\n\n') if p.strip()])
            character_count = len(text)
            character_count_no_spaces = len(text.replace(' ', ''))
            
            # Reading time (average 200 words per minute)
            reading_time_minutes = word_count / 200
            
            # Readability score (Flesch Reading Ease)
            try:
                readability_score = textstat.flesch_reading_ease(text)
            except:
                readability_score = 50.0  # Default neutral score
            
            # Simple sentiment analysis using VADER (via NLTK)
            try:
                from nltk.sentiment import SentimentIntensityAnalyzer
                sia = SentimentIntensityAnalyzer()
                sentiment_scores = sia.polarity_scores(text)
                sentiment_score = sentiment_scores['compound']
                
                if sentiment_score >= 0.05:
                    sentiment_label = "POSITIVE"
                elif sentiment_score <= -0.05:
                    sentiment_label = "NEGATIVE"
                else:
                    sentiment_label = "NEUTRAL"
                    
            except Exception as e:
                print(f"Sentiment analysis error: {e}")
                sentiment_score = 0.0
                sentiment_label = "NEUTRAL"
            
            analysis = TextAnalysis(
                word_count=word_count,
                sentence_count=sentence_count,
                paragraph_count=paragraph_count,
                character_count=character_count,
                character_count_no_spaces=character_count_no_spaces,
                reading_time_minutes=reading_time_minutes,
                readability_score=readability_score,
                sentiment_score=sentiment_score,
                sentiment_label=sentiment_label
            )
            
            return analysis.to_dict()
            
        except Exception as e:
            print(f"Error in text analysis: {e}")
            raise Exception(f"Text analysis failed: {str(e)}")
    
    def _clean_text(self, text: str) -> str:
        """Clean and normalize text"""
        # Remove extra whitespace
        text = re.sub(r'\s+', ' ', text.strip())
        
        # Remove special characters but keep punctuation
        text = re.sub(r'[^\w\s\.\,\!\?\;\:\-\(\)\"\']+', '', text)
        
        return text