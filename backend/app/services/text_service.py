import time
import re
import os
from typing import Dict, List, Any
from transformers import pipeline, AutoTokenizer, AutoModelForSeq2SeqLM
import torch
import nltk
import textstat
from app.models.text_models import TextAnalysis

class TextService:
    """Service class for text processing operations"""
    
    def __init__(self):
        self.device = "cuda" if torch.cuda.is_available() else "cpu"
        print(f"🔧 Using device: {self.device}")
        
        # Initialize models lazily
        self._summarizer = None
        self._paraphraser = None
        self._sentiment_analyzer = None
        
        # Download NLTK data if needed
        self._download_nltk_data()
    
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
    
    @property
    def summarizer(self):
        """Lazy load summarization model"""
        if self._summarizer is None:
            print("🤖 Loading summarization model...")
            try:
                self._summarizer = pipeline(
                    "summarization",
                    model="facebook/bart-large-cnn",
                    device=0 if self.device == "cuda" else -1,
                    torch_dtype=torch.float16 if self.device == "cuda" else torch.float32
                )
                print("✅ Summarization model loaded successfully")
            except Exception as e:
                print(f"⚠️ Failed to load BART model, falling back to lighter model: {e}")
                # Fallback to a lighter model
                self._summarizer = pipeline(
                    "summarization",
                    model="sshleifer/distilbart-cnn-12-6",
                    device=0 if self.device == "cuda" else -1
                )
        return self._summarizer
    
    @property
    def paraphraser(self):
        """Lazy load paraphrasing model"""
        if self._paraphraser is None:
            print("🤖 Loading paraphrasing model...")
            try:
                model_name = "tuner007/pegasus_paraphrase"
                tokenizer = AutoTokenizer.from_pretrained(model_name)
                model = AutoModelForSeq2SeqLM.from_pretrained(model_name)
                
                if self.device == "cuda":
                    model = model.half().to(self.device)
                else:
                    model = model.to(self.device)
                    
                self._paraphraser = {
                    'model': model,
                    'tokenizer': tokenizer
                }
                print("✅ Paraphrasing model loaded successfully")
            except Exception as e:
                print(f"⚠️ Failed to load paraphrasing model: {e}")
                # Fallback to T5 small
                self._paraphraser = pipeline(
                    "text2text-generation",
                    model="t5-small",
                    device=0 if self.device == "cuda" else -1
                )
        return self._paraphraser
    
    @property
    def sentiment_analyzer(self):
        """Lazy load sentiment analysis model"""
        if self._sentiment_analyzer is None:
            print("🤖 Loading sentiment analysis model...")
            self._sentiment_analyzer = pipeline(
                "sentiment-analysis",
                model="cardiffnlp/twitter-roberta-base-sentiment-latest",
                device=0 if self.device == "cuda" else -1
            )
            print("✅ Sentiment analysis model loaded successfully")
        return self._sentiment_analyzer
    
    def summarize(self, text: str, max_length: int = 150, min_length: int = 30) -> Dict[str, Any]:
        """Summarize text using BART model with support for long texts"""
        start_time = time.time()
        
        try:
            # Clean and prepare text
            cleaned_text = self._clean_text(text)
            original_word_count = len(cleaned_text.split())
            
            # For very long texts, chunk them and summarize each chunk
            if original_word_count > 1000:
                summary = self._summarize_long_text(cleaned_text, max_length, min_length)
            else:
                # Adjust lengths based on input
                max_length = min(max_length, max(100, original_word_count // 3))
                min_length = min(min_length, max_length // 3)
                
                # Generate summary
                result = self.summarizer(
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
            raise Exception(f"Summarization failed: {str(e)}")
    
    def paraphrase(self, text: str, num_return_sequences: int = 1) -> Dict[str, Any]:
        """Paraphrase text using Pegasus model"""
        start_time = time.time()
        
        try:
            cleaned_text = self._clean_text(text)
            original_word_count = len(cleaned_text.split())
            
            if isinstance(self.paraphraser, dict):
                # Using custom Pegasus model
                model = self.paraphraser['model']
                tokenizer = self.paraphraser['tokenizer']
                
                # Tokenize input
                inputs = tokenizer(
                    f"paraphrase: {cleaned_text}",
                    return_tensors="pt",
                    max_length=512,
                    truncation=True
                ).to(self.device)
                
                # Generate paraphrases
                with torch.no_grad():
                    outputs = model.generate(
                        **inputs,
                        max_length=len(cleaned_text.split()) + 50,
                        num_return_sequences=num_return_sequences,
                        temperature=0.7,
                        do_sample=True,
                        pad_token_id=tokenizer.eos_token_id
                    )
                
                # Decode results
                paraphrases = []
                for output in outputs:
                    paraphrase = tokenizer.decode(output, skip_special_tokens=True)
                    paraphrases.append(paraphrase)
                
                main_paraphrase = paraphrases[0] if paraphrases else cleaned_text
                variations = paraphrases[1:] if len(paraphrases) > 1 else []
                
            else:
                # Using T5 fallback
                prompt = f"paraphrase: {cleaned_text}"
                result = self.paraphraser(
                    prompt,
                    max_length=len(cleaned_text.split()) + 50,
                    num_return_sequences=num_return_sequences,
                    temperature=0.7,
                    do_sample=True
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
            raise Exception(f"Paraphrasing failed: {str(e)}")
    
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
            readability_score = textstat.flesch_reading_ease(text)
            
            # Sentiment analysis
            try:
                sentiment_result = self.sentiment_analyzer(text[:512])[0]  # Limit to 512 chars
                sentiment_score = sentiment_result['score']
                sentiment_label = sentiment_result['label']
            except Exception as e:
                print(f"Sentiment analysis error: {e}")
                sentiment_score = 0.5
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
    
    def _summarize_long_text(self, text: str, max_length: int, min_length: int) -> str:
        """Handle summarization of very long texts by chunking"""
        # Split text into sentences
        sentences = nltk.sent_tokenize(text)
        
        # Group sentences into chunks of ~800 words
        chunks = []
        current_chunk = []
        current_word_count = 0
        
        for sentence in sentences:
            sentence_words = len(sentence.split())
            if current_word_count + sentence_words > 800 and current_chunk:
                chunks.append(' '.join(current_chunk))
                current_chunk = [sentence]
                current_word_count = sentence_words
            else:
                current_chunk.append(sentence)
                current_word_count += sentence_words
        
        if current_chunk:
            chunks.append(' '.join(current_chunk))
        
        # Summarize each chunk
        chunk_summaries = []
        chunk_max_length = max(50, max_length // len(chunks))
        chunk_min_length = max(20, min_length // len(chunks))
        
        for chunk in chunks:
            try:
                result = self.summarizer(
                    chunk,
                    max_length=chunk_max_length,
                    min_length=chunk_min_length,
                    do_sample=False,
                    truncation=True
                )
                chunk_summaries.append(result[0]['summary_text'])
            except Exception as e:
                print(f"Error summarizing chunk: {e}")
                # Fallback: use first few sentences of the chunk
                chunk_sentences = nltk.sent_tokenize(chunk)
                fallback_summary = ' '.join(chunk_sentences[:3])
                chunk_summaries.append(fallback_summary)
        
        # If we have multiple summaries, combine and summarize again
        if len(chunk_summaries) > 1:
            combined_summary = ' '.join(chunk_summaries)
            if len(combined_summary.split()) > max_length:
                try:
                    final_result = self.summarizer(
                        combined_summary,
                        max_length=max_length,
                        min_length=min_length,
                        do_sample=False,
                        truncation=True
                    )
                    return final_result[0]['summary_text']
                except Exception:
                    # Fallback: return truncated combined summary
                    words = combined_summary.split()
                    return ' '.join(words[:max_length])
            else:
                return combined_summary
        else:
            return chunk_summaries[0] if chunk_summaries else text[:500] + "..."
    
    def _clean_text(self, text: str) -> str:
        """Clean and normalize text"""
        # Remove extra whitespace
        text = re.sub(r'\s+', ' ', text.strip())
        
        # Remove special characters but keep punctuation
        text = re.sub(r'[^\w\s\.\,\!\?\;\:\-\(\)\"\']+', '', text)
        
        return text