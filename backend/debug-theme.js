const User = require('./models/User');
const db = require('./db/conn');

async function postJson(url, payload) {
  const response = await fetch(url, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload),
  });

  const text = await response.text();
  console.log('URL', url);
  console.log('STATUS', response.status);
  console.log(text);
  return text;
}

(async () => {
  await db.sync({ alter: true });

  const nome = 'debugtheme2';
  const email = 'debugtheme2@test.local';
  const senha = '123456';

  await postJson('http://localhost:5000/users/register', {
    nome,
    email,
    senha,
    confirmsenha: senha,
    idade: 25,
    nascimento: '2000-01-01',
    altura: 1.75,
    peso: 70,
    genero: 'Masculino',
    lvl_atividade: 'Moderado',
    theme_mode: 'accessible',
    daltonism_variant: 'tritanopia',
  });

  await postJson('http://localhost:5000/users/login', {
    nome,
    senha,
  });

  process.exit(0);
})();
