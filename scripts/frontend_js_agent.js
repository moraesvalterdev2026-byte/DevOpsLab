import fs from 'fs';

const jsCode = `
document.getElementById('loginForm').addEventListener('submit', function(e) {
  e.preventDefault();
  const email = document.getElementById('email').value;
  const password = document.getElementById('password').value;
  if(email && password) {
    console.log("Login enviado:", { email, password });
    alert("Login realizado com sucesso!");
  } else {
    alert("Preencha todos os campos.");
  }
});
`;

fs.writeFileSync('public/app.js', jsCode);
console.log("✔ JS de login gerado em public/app.js");