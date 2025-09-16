import sys
print("Python version:", sys.version)
print("Python path:", sys.executable)

try:
    import flask
    print("✅ Flask is available, version:", flask.__version__)
except ImportError as e:
    print("❌ Flask import error:", e)

try:
    import torch
    print("✅ PyTorch is available, version:", torch.__version__)
except ImportError as e:
    print("❌ PyTorch import error:", e)

try:
    from transformers import pipeline
    print("✅ Transformers is available")
except ImportError as e:
    print("❌ Transformers import error:", e)

print("Current working directory:", sys.path[0])