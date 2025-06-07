package main

import (
	"html/template"
	"net/http"
)

const pageTemplate = `<!DOCTYPE html>
<html lang="ru">
<head>
<meta charset="UTF-8" />
<meta name="viewport" content="width=device-width, initial-scale=1" />
<title>Шифрование нескольких текстов</title>
<style>
  body {
    background-color: #121212;
    color: #eee;
    font-family: "Segoe UI", Tahoma, Geneva, Verdana, sans-serif;
    padding: 20px;
  }
  textarea {
    width: 100%;
    height: 120px;
    margin-bottom: 12px;
    background: #1e1e1e;
    color: #ccc;
    border: 1px solid #444;
    border-radius: 6px;
    padding: 8px;
    font-size: 1rem;
    resize: vertical;
  }
  button {
    background-color: #ff4081;
    border: none;
    padding: 12px 24px;
    color: white;
    font-size: 1.1rem;
    font-weight: bold;
    border-radius: 8px;
    cursor: pointer;
    transition: background-color 0.3s ease;
  }
  button:hover {
    background-color: #f50057;
  }
  .result {
    margin-top: 20px;
    padding: 12px;
    background-color: #222;
    border-radius: 8px;
    white-space: pre-wrap;
    font-family: monospace;
  }
  label {
    font-weight: 600;
    margin-bottom: 6px;
    display: block;
  }
</style>
</head>
<body>
<h2>Введите тексты для шифрования и сохранения</h2>

<form id="textsForm" onsubmit="return false;">
  {{range $i, $v := .Files}}
    <label for="{{$v}}">Контекст {{$v}}</label>
    <textarea id="{{$v}}" placeholder="Введите текст для {{$v}}..."></textarea>
  {{end}}
  <button id="sendBtn">Отправить</button>
</form>

<div class="result" id="result"></div>

<script>
  function arrayBufferToBase64(buffer) {
    let binary = "";
    const bytes = new Uint8Array(buffer);
    for (let b of bytes) binary += String.fromCharCode(b);
    return btoa(binary);
  }

  async function encryptWithParams(plaintext, password, salt, iv) {
    const encoder = new TextEncoder();
    const data = encoder.encode(plaintext);

    const passKey = await crypto.subtle.importKey(
      "raw",
      encoder.encode(password),
      { name: "PBKDF2" },
      false,
      ["deriveKey"]
    );

    const key = await crypto.subtle.deriveKey(
      {
        name: "PBKDF2",
        salt: salt,
        iterations: {{.Iterations}},
        hash: "SHA-256",
      },
      passKey,
      { name: "AES-GCM", length: 256 },
      false,
      ["encrypt"]
    );

    const ciphertext = await crypto.subtle.encrypt(
      {
        name: "AES-GCM",
        iv: iv,
      },
      key,
      data
    );

    return arrayBufferToBase64(ciphertext);
  }

  document.getElementById("sendBtn").onclick = async () => {
    const password = "{{.Password}}";

    if (!password) {
      alert("Пароль не задан");
      return;
    }

    // Генерируем salt и iv для всех текстов
    const salt = crypto.getRandomValues(new Uint8Array(16));
    const iv = crypto.getRandomValues(new Uint8Array(12));

    const files = new Map();
    for (const f of {{.Files}}) {
      const t = document.getElementById(f).value;
      if (!t) {
        alert("Пожалуйста, заполните все тексты");
        return;
      }
      files.set(f, t);
    }

    const encryptedTexts = [];
    for (const [file, value] of files) {
      const ct = await encryptWithParams(value, password, salt, iv);
      encryptedTexts.push({
		file: file,
        text: ct,
        iv: arrayBufferToBase64(iv),
        salt: arrayBufferToBase64(salt)
      });
    }

    try {
      const resp = await fetch("/submit", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ texts: encryptedTexts }),
      });

      const result = await resp.text();
      document.getElementById("result").textContent = result;
    } catch (err) {
      document.getElementById("result").textContent = "Ошибка: " + err.message;
    }
  };
</script>
</body>
</html>`

func renderTemplate(w http.ResponseWriter, password string, files []string) {
	tmpl := template.Must(template.New("page").Parse(pageTemplate))
	type Data struct {
		Iterations int
		Password   string
		Files      []string
	}

	data := Data{
		Iterations: iterations,
		Password:   password,
		Files:      files,
	}
	w.Header().Set("Content-Type", "text/html; charset=utf-8")
	tmpl.Execute(w, data)
}
