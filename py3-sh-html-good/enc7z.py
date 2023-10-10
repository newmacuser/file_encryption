import os
import subprocess
import base64
from flask import Flask, request, render_template, send_from_directory, session
import random
import glob
import threading
import time

app = Flask(__name__)
app.secret_key = 'your secret key'  # 用于session

def cleanup(file_name, output_file_name):
    os.remove(file_name)
    os.remove(output_file_name)

@app.route('/', methods=['GET', 'POST'])
def index():
    if request.method == 'POST':
        file = request.files['file']
        password = request.form['password']
        decrypt = request.form.get('decrypt')

        file_name = file.filename
        file.save(file_name)

        if decrypt:
            subprocess.call(["./my.sh", "-d", "-i", file_name, "-p", password])
            # 如果是解密模式，那么找到的文件名应该是原始文件名的前半部分加上".de"
            base_file_name, _ = file_name.rsplit('_', 1)  # 获取文件名的前半部分
            name, ext = os.path.splitext(base_file_name)  # 进一步拆分为文件名和扩展名
            output_file_name = glob.glob(name + '.de.*')[0]
        else:
            subprocess.call(["./my.sh", "-i", file_name, "-p", password])
            # 如果不是解密模式，那么找到的文件名应该是原的模式
            output_file_name = glob.glob(file_name + '_*.7z')[0]
        
        session['downloadname'] = output_file_name

        # 创建一个定时器，在30分钟后删除文件
        t = threading.Timer(1800, cleanup, args=(file_name, output_file_name))
        t.start()

        return render_template('index.html', downloadname=session['downloadname'])
    return render_template('index.html')

@app.route('/download/<path:downloadname>')
def download(downloadname):
    return send_from_directory('.', downloadname)

if __name__ == "__main__":
    app.run(debug=True)