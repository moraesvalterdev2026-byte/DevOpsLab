import fs from 'fs';

const cssCode = `
body {
  display: flex;
  justify-content: center;
  align-items: center;
  height: 100vh;
  font-family: Arial, sans-serif;
}
form {
  border: 1px solid #ccc;
  padding: 20px;
  border-radius: 8px;
  background: #f9f9f9;
}
label, input, button {
  display: block;
  margin: 10px 0;
}
`;

fs.writeFileSync('public/style.css', cssCode);
console.log("✔ CSS de login gerado em public/style.css");