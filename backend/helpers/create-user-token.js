//Requerer a biblioteca JWT para criar o token
const jwt = require("jsonwebtoken");

//Criar o metodo para criar o token (não retorna a senha)
const createUserToken = async (user, req, res) => {
  const token = jwt.sign({
    nome: user.nome,
    id: user.id,
  }, process.env.JWT_SECRET || "minhaChaveSecreta");

  // Retornar usuário sem a senha
  const safeUser = {
    nome: user.nome,
    email: user.email,
    phone: user.phone,
    idade: user.idade,
    nascimento: user.nascimento,
    altura: user.altura,
    peso: user.peso,
    genero: user.genero,
    lvl_atividade: user.lvl_atividade,
    lvl_adm: user.lvl_adm,
    theme_mode: user.theme_mode || 'normal',
    daltonism_variant: user.daltonism_variant || 'deuteranopia',
    crono_hydro: user.crono_hydro,
    dias_itensivos: user.dias_itensivos,
    id: user.id,
  };

  return res.status(200).json({
    message: "Você está autenticado",
    user: safeUser,
    token: token,
  });
};

module.exports = createUserToken;
