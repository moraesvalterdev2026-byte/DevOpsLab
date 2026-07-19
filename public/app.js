
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
