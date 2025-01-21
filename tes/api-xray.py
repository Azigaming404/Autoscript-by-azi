from flask import Flask, request, jsonify
import subprocess
import re
import os

app = Flask(__name__)

@app.route('/api.php', methods=['POST'])
def handle_request():
    # Mendapatkan parameter
    path = request.args.get('path')
    username = request.form.get('username')
    masaaktif = request.form.get('masaaktif')
    quota = request.form.get('quota')
    ip = request.form.get('ip')

    # Validasi parameter wajib
    if not path:
        return jsonify({
            'status': 'error',
            'message': 'Parameter "path" harus diisi (vmess, vless, trojan).'
        }), 400

    if not all([username, masaaktif, quota, ip]):
        return jsonify({
            'status': 'error',
            'message': 'Parameter (username, masaaktif, quota, ip) harus diisi.'
        }), 400

    # Routing berdasarkan path
    handlers = {
        'vmess': handle_vmess,
        'vless': handle_vless,
        'trojan': handle_trojan
    }

    if path in handlers:
        return handlers[path](username, masaaktif, quota, ip)
    else:
        return jsonify({
            'status': 'error',
            'message': 'Path tidak valid. Gunakan salah satu: vmess, vless, trojan.'
        }), 400

def handle_vmess(username, masaaktif, quota, ip):
    return execute_script('/usr/bin/vmess', username, masaaktif, quota, ip, 'vmess')

def handle_vless(username, masaaktif, quota, ip):
    return execute_script('/usr/bin/vless', username, masaaktif, quota, ip, 'vless')

def handle_trojan(username, masaaktif, quota, ip):
    return execute_script('/usr/bin/trojan', username, masaaktif, quota, ip, 'trojan')

def execute_script(script_path, username, masaaktif, quota, ip, path):
    # Validasi file script
    if not os.path.exists(script_path):
        return jsonify({
            'status': 'error',
            'message': f"File skrip {script_path} tidak ditemukan."
        }), 400

    if not os.access(script_path, os.X_OK):
        return jsonify({
            'status': 'error',
            'message': f"Skrip {script_path} tidak memiliki izin eksekusi."
        }), 400

    # Jalankan skrip Bash
    command = f"bash {script_path} {username} {masaaktif} {quota} {ip}"
    try:
        output = subprocess.check_output(command, shell=True, text=True)
        subprocess.run("/usr/bin/sudo /usr/bin/systemctl restart xray", shell=True)
        subprocess.run("systemctl restart xray", shell=True)
    except subprocess.CalledProcessError as e:
        return jsonify({
            'status': 'error',
            'message': 'Gagal menjalankan skrip: ' + str(e)
        }), 500

    # Regex untuk masing-masing jenis link
    patterns = {
        'vmess': r'vmess://[^\s]+',
        'vless': r'vless://[^\s]+',
        'trojan': r'trojan://[^\s]+'
    }

    matches = re.findall(patterns[path], output)

    # Validasi apakah ada link ditemukan
    if not matches:
        return jsonify({
            'status': 'error',
            'message': f"Tidak ada link {path} ditemukan dalam output."
        }), 400

    # Response berhasil
    return jsonify({
        'status': 'success',
        'path': path,
        'links': matches
    })

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000, debug=True)
