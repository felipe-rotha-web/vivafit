//Requerer a biblioteca JWT
const jwt = require("jsonwebtoken");
//Requerer o metodo que recupera o token
const getToken = require("./get-token");
//Metodo para verificar o token
const checkToken = (req, res, next) => {
  const token = getToken(req);

  if (!token) {
    return res.status(401).json({ message: "Acesso Negado!" });
  }

  try {
    const verified = jwt.verify(token, process.env.JWT_SECRET || "minhaChaveSecreta");
    req.user = verified;
    next();
  } catch (error) {
    return res.status(401).json({ message: "Token Inválido!" });
  }
};

module.exports = checkToken;
