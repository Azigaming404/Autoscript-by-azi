from flask import Flask, request, jsonify
import subprocess

app = Flask(__name__)

@app.route('/api/ssh', methods=['POST'])
def handle_ssh():
    # Mendapatkan data dari request
    user = request.form.get('username')
    pw = request.form.get('password')
    exp = request.form.get('masaaktif')
    ip = request.form.get('ip')

    # Validasi input
    if not user or not pw or not exp or not ip:
        return jsonify({
            'status': 'error',
            'message': 'Semua parameter (username, password, masaaktif, ip) harus diisi.'
        }), 400

    try:
        # Menjalankan perintah pembuatan user SSH
        create_user_cmd = f"useradd -e $(date -d '{exp} days' +'%Y-%m-%d') -s /bin/false -M {user}"
        result_create_user = subprocess.run(create_user_cmd, shell=True, text=True, stderr=subprocess.PIPE)

        if result_create_user.returncode != 0:
            # Jika gagal membuat user
            return jsonify({
                'status': 'error',
                'message': f'Gagal membuat akun SSH: {result_create_user.stderr.strip()}'
            }), 500

        # Menetapkan password menggunakan chpasswd
        set_password_cmd = f"echo '{user}:{pw}' | chpasswd"
        result_set_password = subprocess.run(set_password_cmd, shell=True, text=True, stderr=subprocess.PIPE)

        if result_set_password.returncode != 0:
            # Jika gagal menetapkan password
            return jsonify({
                'status': 'error',
                'message': f'Gagal menetapkan password: {result_set_password.stderr.strip()}'
            }), 500

        # Menyimpan informasi IP ke file
        ip_file_path = f"/etc/cybervpn/limit/ssh/ip/{user}"
        with open(ip_file_path, 'w') as f:
            f.write(ip)

        # Tanggapan sukses
        return jsonify({
            'status': 'success',
            'username': user,
            'expiry_date': f'{exp} days',
            'ip': ip
        }), 200

    except Exception as e:
        return jsonify({
            'status': 'error',
            'message': f'Terjadi kesalahan: {str(e)}'
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=7000)
