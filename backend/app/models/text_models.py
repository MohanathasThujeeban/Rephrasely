from dataclasses import dataclass
from typing import Optional, List, Dict, Any

@dataclass
class TextRequest:
    """Text processing request model"""
    text: str
    max_length: Optional[int] = 150
    min_length: Optional[int] = 30
    variations: Optional[int] = 1
    
    @classmethod
    def from_dict(cls, data: Dict[str, Any]) -> 'TextRequest':
        return cls(
            text=data.get('text', ''),
            max_length=data.get('max_length', 150),
            min_length=data.get('min_length', 30),
            variations=data.get('variations', 1)
        )

@dataclass
class TextResponse:
    """Text processing response model"""
    success: bool
    original_text: str
    processed_text: str
    processing_time: float
    word_count_original: int
    word_count_processed: int
    compression_ratio: Optional[float] = None
    variations: Optional[List[str]] = None
    error: Optional[str] = None
    
    def to_dict(self) -> Dict[str, Any]:
        result = {
            'success': self.success,
            'original_text': self.original_text,
            'processed_text': self.processed_text,
            'processing_time': round(self.processing_time, 3),
            'word_count_original': self.word_count_original,
            'word_count_processed': self.word_count_processed
        }
        
        if self.compression_ratio is not None:
            result['compression_ratio'] = round(self.compression_ratio, 2)
        
        if self.variations:
            result['variations'] = self.variations
        
        if self.error:
            result['error'] = self.error
            
        return result

@dataclass
class TextAnalysis:
    """Text analysis result model"""
    word_count: int
    sentence_count: int
    paragraph_count: int
    character_count: int
    character_count_no_spaces: int
    reading_time_minutes: float
    readability_score: float
    sentiment_score: float
    sentiment_label: str
    
    def to_dict(self) -> Dict[str, Any]:
        return {
            'word_count': self.word_count,
            'sentence_count': self.sentence_count,
            'paragraph_count': self.paragraph_count,
            'character_count': self.character_count,
            'character_count_no_spaces': self.character_count_no_spaces,
            'reading_time_minutes': round(self.reading_time_minutes, 1),
            'readability_score': round(self.readability_score, 1),
            'sentiment': {
                'score': round(self.sentiment_score, 3),
                'label': self.sentiment_label
            }
        }