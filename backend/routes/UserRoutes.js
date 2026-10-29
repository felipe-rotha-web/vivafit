//Requerer a função de rotas do express
const router = require("express").Router();
//Requerer o controller UserController
const UserController = require("../controller/UserController");
const rateLimit = require("express-rate-limit");

//requerer a middleware
const verifyToken = require("../helpers/verify-token");
const passwordResetLimiter = rateLimit({
  windowMs: 15 * 60 * 1000,
  limit: 10,
  standardHeaders: true,
  legacyHeaders: false,
  message: { message: "Muitas tentativas. Aguarde antes de tentar novamente." },
});

//Rota Register
router.post("/register", UserController.register);
router.post("/user/register", UserController.register);

//Rota de login
router.post("/login", UserController.login);
router.post("/user/login", UserController.login);
router.post(
  "/password-reset/request",
  passwordResetLimiter,
  UserController.requestPasswordReset,
);
router.post(
  "/password-reset/confirm",
  passwordResetLimiter,
  UserController.confirmPasswordReset,
);

//Rota para verificação de usuário
router.get("/checkuser", UserController.checkUser);

//Rota para Listar o usuario por id
router.get("/:id", UserController.getUserByID);

//rota para editar o usuario com vereficação de token
router.patch('/edit/:id',verifyToken,UserController.editUser)

module.exports = router;
