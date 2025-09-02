from flask import Flask, request, render_template
import os
import subprocess
import shutil

app = Flask(__name__)
UPLOAD_FOLDER = "uploads/"
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route('/')
def index():
    return render_template('upload_new.html')

@app.route('/upload', methods=['POST'])
def upload():
    cram_files = request.files.getlist('cramFiles')
    output_dir_input = request.form.get('outputDir')

    if not cram_files or all(file.filename == '' for file in cram_files):
        return "No files uploaded."

    # Clear the uploads folder first
    if os.path.exists(UPLOAD_FOLDER):
        shutil.rmtree(UPLOAD_FOLDER)
    os.makedirs(UPLOAD_FOLDER, exist_ok=True)

    # Save all uploaded files
    uploaded_files = []
    total_size = 0
    for cram_file in cram_files:
        if cram_file.filename:
            cram_filename = cram_file.filename
            cram_path = os.path.abspath(os.path.join(UPLOAD_FOLDER, cram_filename))
            cram_file.save(cram_path)
            
            file_size = os.path.getsize(cram_path)
            total_size += file_size
            uploaded_files.append(cram_filename)
            print(f"File saved: {cram_path} ({file_size} bytes)")

    output_dir = os.path.abspath(os.path.normpath(output_dir_input))
    os.makedirs(output_dir, exist_ok=True)

    print(f"Total files uploaded: {len(uploaded_files)}")
    print(f"Total size: {total_size} bytes")
    print(f"Files: {uploaded_files}")
    print(f"Output directory: {output_dir}")

    script_path = './backend.sh'
    print(f"Running script: {script_path} {output_dir}")

    try:
        result = subprocess.run(
            ['bash', script_path, output_dir],
            check=True,
            capture_output=True,
            text=True
        )
        print("BACKEND OUTPUT")
        print(result.stdout)
        print("BACKEND ERROR")
        print(result.stderr)
        return f"""
        <h2>Success!</h2>
        <p>Processed {len(uploaded_files)} files:</p>
        <ul>{''.join([f'<li>{file}</li>' for file in uploaded_files])}</ul>
        <h3>Script Output:</h3>
        <pre>{result.stdout}</pre>
        """
    except subprocess.CalledProcessError as e:
        print("Script failed with error")
        print("STDOUT:")
        print(e.stdout)
        print("STDERR:")
        print(e.stderr)
        return f"""
        <h2>Error during script execution</h2>
        <p>Attempted to process {len(uploaded_files)} files:</p>
        <ul>{''.join([f'<li>{file}</li>' for file in uploaded_files])}</ul>
        <h3>Script Output:</h3>
        <pre>{e.stdout}</pre>
        <h3>Error Details:</h3>
        <pre>{e.stderr}</pre>
        """

if __name__ == '__main__':
    app.run(debug=True)