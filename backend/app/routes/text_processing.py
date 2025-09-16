from flask import Blueprint, request, jsonify
from app.services.text_service_lite import TextService
from app.models.text_models import TextRequest, TextResponse
import traceback

text_bp = Blueprint('text_processing', __name__)
text_service = TextService()

@text_bp.route('/summarize', methods=['POST'])
def summarize_text():
    """Summarize text endpoint"""
    try:
        # Get request data
        data = request.get_json()
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        text_request = TextRequest.from_dict(data)
        
        # Validate input
        if not text_request.text or not text_request.text.strip():
            return jsonify({'error': 'Text is required'}), 400
        
        # Calculate approximate word count (average 5 characters per word)
        estimated_words = len(text_request.text) / 5
        if estimated_words > 15000:
            return jsonify({'error': 'Text too long. Maximum 15,000 words (approximately 75,000 characters) allowed'}), 400
        
        # Process summarization
        result = text_service.summarize(
            text_request.text,
            max_length=text_request.max_length,
            min_length=text_request.min_length
        )
        
        response = TextResponse(
            success=True,
            original_text=text_request.text,
            processed_text=result['summary'],
            processing_time=result['processing_time'],
            word_count_original=result['original_word_count'],
            word_count_processed=result['summary_word_count'],
            compression_ratio=result['compression_ratio']
        )
        
        return jsonify(response.to_dict()), 200
        
    except Exception as e:
        print(f"Error in summarize_text: {str(e)}")
        print(traceback.format_exc())
        return jsonify({
            'success': False,
            'error': f'Processing failed: {str(e)}'
        }), 500

@text_bp.route('/paraphrase', methods=['POST'])
def paraphrase_text():
    """Paraphrase text endpoint"""
    try:
        # Get request data
        data = request.get_json()
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        text_request = TextRequest.from_dict(data)
        
        # Validate input
        if not text_request.text or not text_request.text.strip():
            return jsonify({'error': 'Text is required'}), 400
        
        # Calculate approximate word count (average 5 characters per word)
        estimated_words = len(text_request.text) / 5
        if estimated_words > 15000:
            return jsonify({'error': 'Text too long. Maximum 15,000 words (approximately 75,000 characters) allowed'}), 400
        
        # Process paraphrasing
        result = text_service.paraphrase(
            text_request.text,
            num_return_sequences=text_request.variations or 1
        )
        
        response = TextResponse(
            success=True,
            original_text=text_request.text,
            processed_text=result['paraphrase'],
            processing_time=result['processing_time'],
            word_count_original=result['original_word_count'],
            word_count_processed=result['paraphrase_word_count'],
            variations=result.get('variations', [])
        )
        
        return jsonify(response.to_dict()), 200
        
    except Exception as e:
        print(f"Error in paraphrase_text: {str(e)}")
        print(traceback.format_exc())
        return jsonify({
            'success': False,
            'error': f'Processing failed: {str(e)}'
        }), 500

@text_bp.route('/analyze', methods=['POST'])
def analyze_text():
    """Analyze text endpoint"""
    try:
        # Get request data
        data = request.get_json()
        if not data:
            return jsonify({'error': 'No data provided'}), 400
        
        text = data.get('text', '').strip()
        if not text:
            return jsonify({'error': 'Text is required'}), 400
        
        # Process analysis
        result = text_service.analyze(text)
        
        return jsonify({
            'success': True,
            'analysis': result,
            'text_length': len(text)
        }), 200
        
    except Exception as e:
        print(f"Error in analyze_text: {str(e)}")
        print(traceback.format_exc())
        return jsonify({
            'success': False,
            'error': f'Analysis failed: {str(e)}'
        }), 500

@text_bp.errorhandler(413)
def file_too_large(error):
    return jsonify({'error': 'File too large'}), 413

@text_bp.errorhandler(400)
def bad_request(error):
    return jsonify({'error': 'Bad request'}), 400