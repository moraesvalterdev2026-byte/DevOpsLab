import fs from 'fs';

const htmlCode = `
<!DOCTYPE html>
<html>
<head>
  <title>Login</title>
</head>
<body>
  <form id="loginForm">
    <label>Email:</label>
    <input type="email" id="email" required />
    <label>Senha:</label>
    <input type="password" id="password" required />
    <button type="submit">Entrar</button>
  </form>
</body>
</html>
`;

fs.writeFileSync('public/login.html', htmlCode);
console.log("✔ HTML de login gerado em public/login.html");