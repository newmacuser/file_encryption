from flask import Flask, render_template, request, send_file
import os
from cryptography.fernet import Fernet
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC
from cryptography.hazmat.primitives import hashes
import base64

app = Flask(__name__, template_folder='./')

@app.route('/', methods=['GET', 'POST'])
def index():
    result = None
    downloadname = None
    key = None
    keyname = None
    decrypted_data = None
    decrypted_filename = None

    if request.method == 'POST':
        if request.form.get('action') == 'encrypt':
            file = request.files['file']
            password = request.form['password']

            if file and password:
                # 生成加密密钥
                password_bytes = password.encode()
            
                # Use password to derive a key
                salt = os.urandom(16)
                kdf = PBKDF2HMAC(algorithm=hashes.SHA384(), length=32, salt=salt, iterations=1000)
                key = base64.urlsafe_b64encode(kdf.derive(password_bytes))
                f = Fernet(key)

                # 读取上传的文件
                data = file.read()

                # 加密数据
                encrypted_data = f.encrypt(data)

                # 保存加密后的文件
                filename = file.filename
                downloadname = 'encrypted_' + filename
                with open(downloadname, 'wb') as encrypted_file:
                    encrypted_file.write(encrypted_data)

                # 保存密钥文件
                keyname = 'key_' + filename + '.txt'
                with open(keyname, 'w') as key_file:
                    key_file.write(key.decode('utf-8'))

                result = '文件已成功加密'
                
                return render_template('index.html', result=result, downloadname=downloadname, key=key, keyname=keyname, decrypted_data=decrypted_data, decrypted_filename=decrypted_filename)

        elif request.form.get('action') == 'decrypt':
            file = request.files['encrypted_file']
            key = request.files['key_file']

            if file and key:
                # 读取上传的文件
                data = file.read()

                # 读取密钥文件
                key_file = request.files['key_file']
                key_data = key_file.read()

                # 解密数据
                f = Fernet(key_data)
                decrypted_data = f.decrypt(data)

                # 保存解密后的文件
                filename = file.filename
                decrypted_filename = 'decrypted_' + filename
                with open(decrypted_filename, 'wb') as decrypted_file:
                    decrypted_file.write(decrypted_data)
                return render_template('index.html', result=result, downloadname=downloadname, key=key, keyname=keyname, decrypted_data=decrypted_data, decrypted_filename=decrypted_filename)
        
    return render_template('index.html', result=result, downloadname=downloadname, key=key, keyname=keyname, decrypted_data=decrypted_data, decrypted_filename=decrypted_filename)

@app.route('/download/<path:downloadname>')
def download(downloadname):
    return send_file(downloadname, as_attachment=True)

@app.route('/download_key/<path:keyname>')
def download_key(keyname):
    return send_file(keyname, as_attachment=True)

@app.route('/download_decrypted_file/<path:filename>')
def download_decrypted_file(filename):
    return send_file(filename, as_attachment=True)

if __name__ == '__main__':
    app.run(debug=True)
