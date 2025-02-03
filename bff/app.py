from flask import Flask, jsonify
import requests

app = Flask(__name__)

@app.route('/api/data', methods=['GET'])
def get_data():
    try:
        response1 = requests.get('https://api.example.com/service1')
        response2 = requests.get('https://api.example.com/service2')
        response3 = requests.get('https://api.example.com/service3')
        response4 = requests.get('https://api.example.com/service4')

        combined_data = {
            'service1': response1.json(),
            'service2': response2.json(),
            'service3': response3.json(),
            'service4': response4.json(),
        }

        return jsonify(combined_data)
    except Exception as e:
        return jsonify({'error': 'Failed to  fetch data', 'message': str(e)}), 500

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
