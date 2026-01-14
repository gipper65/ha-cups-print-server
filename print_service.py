#!/usr/bin/env python3
"""Simple print service for CUPS add-on."""
import subprocess
import os
from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/print', methods=['POST'])
def print_file():
    """Print a file via CUPS."""
    data = request.get_json()
    
    printer = data.get('printer', 'EPSON')
    filepath = data.get('file', '/config/www/ptm.pdf')
    
    # Don't convert path - use it as-is
    
    try:
        # Execute print command
        result = subprocess.run(
            ['lpr', '-P', printer, filepath],
            capture_output=True,
            text=True,
            timeout=30
        )
        
        if result.returncode == 0:
            return jsonify({
                'status': 'success',
                'message': f'Printed {filepath} to {printer}'
            }), 200
        else:
            return jsonify({
                'status': 'error',
                'message': result.stderr
            }), 500
            
    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': str(e)
        }), 500

@app.route('/health', methods=['GET'])
def health():
    """Health check endpoint."""
    return jsonify({'status': 'ok'}), 200

@app.route('/debug/list', methods=['GET'])
def list_directories():
    """List available directories and their contents."""
    directories = {}
    
    # Check common mount points
    paths_to_check = [
        '/config',
        '/homeassistant', 
        '/share',
        '/data',
        '/root',
        '/backup',
        '/ssl',
        '/addons',
        '/media'
    ]
    
    for path in paths_to_check:
        try:
            if os.path.exists(path):
                contents = os.listdir(path)
                directories[path] = {
                    'exists': True,
                    'contents': contents[:20]  # Limit to first 20 items
                }
            else:
                directories[path] = {'exists': False}
        except Exception as e:
            directories[path] = {'exists': True, 'error': str(e)}
    
    return jsonify(directories), 200

@app.route('/debug/find/<path:filename>', methods=['GET'])
def find_file(filename):
    """Find a file in common locations."""
    import subprocess
    try:
        result = subprocess.run(
            ['find', '/', '-name', filename, '-type', 'f'],
            capture_output=True,
            text=True,
            timeout=10
        )
        
        files = [line for line in result.stdout.split('\n') if line]
        
        return jsonify({
            'filename': filename,
            'found': len(files) > 0,
            'locations': files[:10]  # Limit to first 10 results
        }), 200
    except Exception as e:
        return jsonify({
            'filename': filename,
            'error': str(e)
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
