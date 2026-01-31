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

<script src="https://cdn.jsdelivr.net/npm/asmcrypto.js@2.3.2/asmcrypto.all.es5.min.js"></script>
<script>
  const ITERATIONS = {{.Iterations}};
  const KEY_LEN = 16;

  function setResult(msg) {
    document.getElementById("result").textContent = msg;
  }

  function getLib() {
    const w = window;
    if (w.AsmCrypto) return w.AsmCrypto;
    if (w.asmCrypto) return w.asmCrypto.default || w.asmCrypto;
    return null;
  }

  function bytesToBase64(arr) {
    let s = "";
    const b = new Uint8Array(arr);
    for (let i = 0; i < b.length; i++) s += String.fromCharCode(b[i]);
    return btoa(s);
  }

  function encrypt(plaintext, password) {
    const lib = getLib();
    if (!lib) throw new Error("asmcrypto не загружен");

    const enc = new TextEncoder();
    const pw = enc.encode(password);
    const salt = crypto.getRandomValues(new Uint8Array(16));
    const iv = crypto.getRandomValues(new Uint8Array(12));
    const data = enc.encode(plaintext);

    const pbkdf2 = lib.Pbkdf2HmacSha256;
    if (!pbkdf2) throw new Error("Pbkdf2HmacSha256 не найден");
    const key = typeof pbkdf2.bytes === "function"
      ? pbkdf2.bytes(pw, salt, ITERATIONS, KEY_LEN)
      : pbkdf2(pw, salt, ITERATIONS, KEY_LEN);
    let keyBytes = key instanceof Uint8Array ? key : new Uint8Array(key);
    const key16 = new Uint8Array(KEY_LEN);
    key16.set(keyBytes.subarray(0, KEY_LEN));

    const aesGcm = lib.AES_GCM || lib.AesGcm;
    if (!aesGcm || typeof aesGcm.encrypt !== "function") throw new Error("AES_GCM не найден");
    const ciphertext = aesGcm.encrypt(data, key16, iv);

    return {
      text: bytesToBase64(ciphertext),
      iv: bytesToBase64(iv),
      salt: bytesToBase64(salt),
    };
  }

  document.getElementById("sendBtn").onclick = async () => {
    try {
      const password = {{.Password}};
      if (!password) {
        setResult("Ошибка: пароль не задан");
        return;
      }

    const files = {{.Files}};

    const texts = [];
    for (const file of files) {
      const text = document.getElementById(file).value;
      if (!text) {
        alert("Пожалуйста, заполните все тексты");
        return;
      }

      const enc = encrypt(text, password);
	  texts.push({ file: file, text: enc.text, iv: enc.iv, salt: enc.salt });
    }

      const resp = await fetch("/submit", {
        method: "POST",
        headers: { "Content-Type": "application/json" },
        body: JSON.stringify({ texts: texts }),
      });

      const text = await resp.text();
      setResult(resp.ok ? text : "Ошибка " + resp.status + ": " + text);
    } catch (err) {
      setResult("Ошибка: " + (err.message || String(err)));
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
