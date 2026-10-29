//Requerer as funcionabilidades do Models UserModel
const User = require("../models/User");
//Requerer o Bcrypt para criptografia da senhas
const bcrypt = require("bcrypt");
const crypto = require("crypto");
const db = require("../db/conn");
const PasswordResetCode = require("../models/PasswordResetCode");
const passwordResetMailer = require("../helpers/password-reset-mailer");
//Requerer o criador de token
const createUserToken = require("../helpers/create-user-token");
//Requerer get-token
const getToken = require('../helpers/get-token')
const { where, fn, col } = require("sequelize");
//Requerer a biblioteca jwt
const jwt = require("jsonwebtoken")

//criar a clssse UserControler para as regras de negocio
module.exports = class UserController {
  static async requestPasswordReset(req, res) {
    const email = typeof req.body.email === "string"
      ? req.body.email.trim().toLowerCase()
      : "";
    if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
      return res.status(422).json({ message: "Informe um email válido." });
    }

    if (!passwordResetMailer.isConfigured()) {
      return res.status(503).json({
        message: "A recuperação por email ainda não está configurada no servidor.",
      });
    }

    const genericMessage =
      "Se houver uma conta associada a esse email, enviaremos um código de recuperação.";
    const emailCondition = where(fn("LOWER", col("email")), email);
    const user = await User.findOne({ where: emailCondition });
    if (!user) {
      return res.status(200).json({ message: genericMessage });
    }

    const now = new Date();
    const existingCode = await PasswordResetCode.findOne({
      where: { user_id: user.id },
    });
    if (
      existingCode &&
      now.getTime() - new Date(existingCode.last_sent_at).getTime() < 60_000
    ) {
      return res.status(200).json({ message: genericMessage });
    }

    const code = crypto.randomInt(100000, 1000000).toString();
    const codeHash = await bcrypt.hash(code, 10);
    await PasswordResetCode.upsert({
      user_id: user.id,
      code_hash: codeHash,
      expires_at: new Date(now.getTime() + 10 * 60_000),
      attempts: 0,
      last_sent_at: now,
    });

    try {
      await passwordResetMailer.sendPasswordResetCode(email, code);
    } catch (error) {
      await PasswordResetCode.destroy({ where: { user_id: user.id } });
      console.error("Falha ao enviar email de redefinição de senha:", error);
      return res.status(503).json({
        message: "Não foi possível enviar o email agora. Tente novamente mais tarde.",
      });
    }

    return res.status(200).json({ message: genericMessage });
  }

  static async confirmPasswordReset(req, res) {
    const email = typeof req.body.email === "string"
      ? req.body.email.trim().toLowerCase()
      : "";
    const code = typeof req.body.code === "string" ? req.body.code.trim() : "";
    const novaSenha = typeof req.body.novaSenha === "string"
      ? req.body.novaSenha.trim()
      : "";

    if (!/^[^@\s]+@[^@\s]+\.[^@\s]+$/.test(email)) {
      return res.status(422).json({ message: "Informe um email válido." });
    }
    if (!/^\d{6}$/.test(code)) {
      return res.status(422).json({ message: "Informe o código de 6 dígitos." });
    }
    if (novaSenha.length < 6) {
      return res.status(422).json({
        message: "A nova senha deve ter pelo menos 6 caracteres.",
      });
    }

    let codeInvalid = false;
    await db.transaction(async (transaction) => {
      const user = await User.findOne({
        where: where(fn("LOWER", col("email")), email),
        transaction,
        lock: transaction.LOCK.UPDATE,
      });
      if (!user) {
        codeInvalid = true;
        return;
      }

      const resetRequest = await PasswordResetCode.findOne({
        where: { user_id: user.id },
        transaction,
        lock: transaction.LOCK.UPDATE,
      });
      if (
        !resetRequest ||
        new Date(resetRequest.expires_at).getTime() <= Date.now()
      ) {
        codeInvalid = true;
        return;
      }

      const isCodeValid = await bcrypt.compare(code, resetRequest.code_hash);
      if (!isCodeValid) {
        codeInvalid = true;
        return;
      }

      const salt = await bcrypt.genSalt(12);
      user.senha = await bcrypt.hash(novaSenha, salt);
      await user.save({ transaction });
      await resetRequest.destroy({ transaction });
    });

    if (codeInvalid) {
      return res.status(400).json({
        message: "Código inválido ou expirado. Solicite um novo código.",
      });
    }

    return res.status(200).json({ message: "Senha redefinida com sucesso." });
  }

  static async register(req, res) {
    const {
      nome,
      email,
      senha,
      confirmsenha,
      phone,
      idade,
      nascimento,
      altura,
      peso,
      genero,
      lvl_atividade,
      lvl_adm,
      points,
      crono_hydro,
      dias_itensivos,
      theme_mode,
      daltonism_variant,
    } = req.body;

    const safeEmail = email || `${(nome || 'usuario').trim().toLowerCase().replace(/\s+/g, '.')}@appvivafit.local`;
    const safePhone = phone || '00000000000';
    const safeNascimento = nascimento || '2000-01-01';
    const safeAltura = altura ?? 1.7;
    const safePeso = peso ?? 70;
    const safeGenero = genero || 'Outro';
    const safeLvlAtividade = lvl_atividade || 'Sedentário';
    const safeLvlAdm = lvl_adm ?? '0';
    const safePoints = points ?? 0;
    const safeCronoHydro = crono_hydro ?? 0;
    const safeDiasIntensivos = dias_itensivos ?? '0';
    const safeThemeMode = theme_mode || 'normal';
    const safeDaltonismVariant = daltonism_variant || 'deuteranopia';

    // Validações mínimas
    if (!nome) {
      res.status(422).json({ message: "O Nome é obrigatorio!" });
      return;
    }
    if (!email && !nome) {
      res.status(422).json({ message: "O Email é obrigatorio!" });
      return;
    }
    if (!senha) {
      res.status(422).json({ message: "A Senha é obrigatoria!" });
      return;
    }
    if (!confirmsenha) {
      res.status(422).json({ message: "A Confirmação é obrigatoria!" });
      return;
    }
    if (senha !== confirmsenha) {
      res.status(422).json({ message: "As senhas precisam ser iguais" });
      return;
    }
    if (idade === undefined || idade === null) {
      res.status(422).json({ message: "A Idade é obrigatorio!" });
      return;
    }
    if (safePoints === undefined || safePoints === null) {
      res.status(422).json({ message: "A quantidade de pontos é obrigatorio!" });
      return;
    }

    //Verificar se o usuario ja existe
    const userExists = await User.findOne({ where: { email: safeEmail } });
    if (userExists) {
      res.status(422).json({
        message: "Usuario já existe",
      });
      return;
    }
    //Criptografar a senha
    const salt = await bcrypt.genSalt(12);
    const senhaHash = await bcrypt.hash(senha, salt);

    try {
      //Criar o novo usuario
      const newUser = await User.create({
        nome: nome,
        email: safeEmail,
        senha: senhaHash,
        phone: safePhone,
        idade: idade,
        nascimento: safeNascimento,
        altura: safeAltura,
        peso: safePeso,
        genero: safeGenero,
        lvl_atividade: safeLvlAtividade,
        lvl_adm: safeLvlAdm,
        pontos: safePoints,
        theme_mode: safeThemeMode,
        daltonism_variant: safeDaltonismVariant,
        crono_hydro: safeCronoHydro,
        dias_itensivos: safeDiasIntensivos,
      });
      //Instanciar o metodo para criar o token
      await createUserToken(newUser, req, res);
    } catch (error) {
      res.status(500).json({ message: error.message || error });
    }
  }

  //Criar um método de login
  static async login(req, res) {
    //Requerendo pelo corpo da requesição os parametros
    const email = req.body.email || req.body.nome;
    const nome = req.body.nome;
    // aceitar tanto `senha` (pt-BR) quanto `password` (caso o cliente envie em inglês)
    const senha = req.body.senha || req.body.password;

    // Validar presença da senha
    if (!senha) {
      res.status(422).json({ message: "A Senha é obrigatoria!" });
      return;
    }

    //Verificar se o email ou nome existe
    const user = await User.findOne({
      where: {
        [require('sequelize').Op.or]: [
          { email: email },
          { nome: nome || email },
        ],
      },
    });

    //Retorno caso o usuario não exista!
    if (!user) {
      res.status(422).json({
        message: "Não a usuario cadastrado com esse email ou nome",
      });
      return;
    }

    //Garantir que o hash está presente antes de comparar
    if (!user.senha) {
      res.status(500).json({ message: "Erro no servidor: hash de senha não encontrado." });
      return;
    }

    //Verificar se a senha depois do hash existe
    const checksenha = await bcrypt.compare(senha, user.senha);
    //Retorno a mensagem se a senha estiver incorreta
    if (!checksenha) {
      res.status(422).json({
        message: "senha Invalida",
      });
      return;
    }

    //O usuario será autenticado gerando o token
    await createUserToken(user, req, res);
  }

  //Criar o método de verificação do usuário pelo token
  static async checkUser(req, res) {
    //Criar uma variavel para a verificação
    let currentUser

    console.log(req.headers.authorization)

    //Verificar se foi enviado um token
    if(req.headers.authorization){
        const token = getToken(req)
        //Verificação com o jwt
        const decoded = jwt.verify(token,'minhaChaveSecreta')
        currentUser = await User.findByPk(decoded.id)
        currentUser.senha = undefined

    }else{
        currentUser = null
    }

    res.status(200).send(currentUser)

  }

  //Resgatar o usuario por ID
  static async getUserByID(req,res){
    //Recebendo por parametro (url) o id do usuario
    const id = req.params.id

    //Verificar se o Usuario existe no banco
    const user = await User.findByPk(id, {attributes: {exclude: ['senha']}})

    //Caso o usuario não exista
    if(!user){
      res.status(422).json(
        {message: 'Usuario não encontrado!'}
      )
      return
    }

    //Retornar o usuario
    res.status(200).json(
      {user}
    ) 
  }

  //Editar os dados do ususario
  static async editUser(req,res){
      //recuperar o usuario pela requesição
      const id = req.params.id

      //recuperar os campos para edição pelo body
      const {nome, email, phone, peso, altura, lvl_atividade, lvl_adm, points, crono_hydro, dias_itensivos, theme_mode, daltonism_variant} = req.body

      let image = ''

      //executar o model para pesquisa ou consulta do usuario
      const user = await User.findByPk(id)

      //caso o usuario não exista
      if(!user){
        res.status(422).json({
          message:'Usuário não encontrado'
        })
        return
      }

      //acessar o metado do model para alterar o usuário
      try {
        //!
        await User.update(
          {
            nome: nome,
            email: email,
            phone: phone,
            peso: peso,
            altura: altura,
            lvl_atividade: lvl_atividade,
            lvl_adm: lvl_adm,
            pontos: points,
            theme_mode: theme_mode || user.theme_mode || 'normal',
            daltonism_variant: daltonism_variant || user.daltonism_variant || 'deuteranopia',
            crono_hydro: crono_hydro,
            dias_itensivos: dias_itensivos,
          },
          {where:{id:id}}
        )
        res.status(200).json({
          message:'Usuário alterado com sucesso!'
        })
      } catch (error) {
          res.status(401).json({
            message:'Erro ao editar o usuario'
          })
      }
  }

};
