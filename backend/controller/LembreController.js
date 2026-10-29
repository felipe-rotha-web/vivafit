//Requerer as funcionabilidades do Models LembreModel
const Lembre = require("../models/Lembre");

// const { where } = require("sequelize");

//criar a clssse LembreControler para as regras de negocio
module.exports = class LembreController {
  static async register(req, res) {
    const body = req.body || {};
    const lembreText = body.Lembre ?? body.lembreText ?? body.lembre;
    const userListId = body.User_list_id ?? body.userListId ?? body.user_list_id;
    const dataLembre = body.Data_lembre ?? body.dataLembre ?? body.data_lembre;
    // Validaçoes
    if (!lembreText) {
      res.status(422).json({ message: "O Lembrete é obrigatorio!" });
      return;
    }
    if (!userListId) {
      res.status(422).json({ message: "O usuario da lista é obrigatorio!" });
      return;
    }
    if (!dataLembre) {
      res.status(422).json({ message: "A data do lembrete é obrigatória!" });
      return;
    }
    //Verificar se o lembrete ja existe
    const whereCheck = { Lembre: lembreText };
    if (userListId !== undefined) whereCheck.User_list_id = userListId;
    if (dataLembre !== undefined) whereCheck.Data_lembre = dataLembre;
    const LembreExists = await Lembre.findOne({ where: whereCheck });
    if (LembreExists) {
      res.status(422).json({
        message: "Lembrete já existe",
      });
      return;
    }

    try {
      //Criar o novo lembrete
      const newLembre = await Lembre.create({
        Lembre: lembreText,
        User_list_id: userListId,
        Data_lembre: dataLembre,
      });
      res.status(201).json({ message: 'Lembrete criado com sucesso.', lembrete: newLembre });
    } catch (error) {
      res.status(500).json({ message: error });
    }
  }


  //Criar o método de verificação do Lembrete pelo token
  static async checkLembre(req, res) {
    //Criar uma variavel para a verificação
    let currentLembre

    console.log(req.headers.authorization)

    //Verificar se foi enviado um token
    if(req.headers.authorization){
        const token = getToken(req)
        //Verificação com o jwt
        const decoded = jwt.verify(token,'minhaChaveSecreta')
        currentLembre = await Lembre.findByPk(decoded.id)
        currentLembre.senha = undefined

    }else{
        currentLembre = null
    }

    res.status(200).send(currentLembre)

  }

  //Resgatar o lembrete por ID
  static async getLembreByID(req,res){
    //Recebendo por parametro (url) o id do lembrete
    const id = req.params.id

    //Verificar se o lembrete existe no banco
    const lembrete = await Lembre.findByPk(id)

    //Caso o lembrete não exista
    if(!lembrete){
      res.status(422).json({ message: 'Lembrete não encontrado!' });
      return
    }

    //Retornar o lembrete
    res.status(200).json({ lembrete })
  }

  // alias para compatibilidade com rota
  static async getLembreById(req, res) {
    return this.getLembreByID(req, res);
  }

  // Retornar todos os lembretes, opcionalmente por `user_list_id` (query)
  static async getAllLembre(req, res) {
    const query = req.query || {};
    const userListQuery = query.user_list_id ?? query.userListId ?? query.user_listid ?? query.userlistid;
    try {
      const where = {};
      if (userListQuery !== undefined) where.User_list_id = userListQuery;
      const lembretes = await Lembre.findAll({ where });
      res.status(200).json(lembretes);
    } catch (error) {
      res.status(500).json({ message: error.message || error });
    }
  }

  // Retornar lembretes por `User_list_id` via rota /user/:id
  static async getByUserListId(req, res) {
    const userListId = req.params.id;
    try {
      const lembretes = await Lembre.findAll({ where: { User_list_id: userListId } });
      if (!lembretes || lembretes.length === 0) {
        res.status(422).json({ message: 'Nenhum lembrete encontrado para este User_list_id.' });
        return;
      }
      res.status(200).json({ lembretes });
    } catch (error) {
      res.status(500).json({ message: error.message || error });
    }
  }

  //Editar os dados do ususario
  static async editLembre(req,res){
      //recuperar o lembrete pela requesição
      const id = req.params.id

      //verificar se o lembrete existe
      const lembrete = await Lembre.findByPk(id);
      if(!lembrete){
        res.status(422).json({ message:'Lembrete não encontrado' });
        return
      }

      //recuperar novo valor do corpo (aceita variações de nomes)
      const body = req.body || {};
      const lembreText = body.Lembre ?? body.lembreText ?? body.lembre;
      const userListId = body.User_list_id ?? body.userListId ?? body.user_list_id;
      const dataLembre = body.Data_lembre ?? body.dataLembre ?? body.data_lembre;

      //acessar o metado do model para alterar o Lembrete
      try {
        await Lembre.update(
          {
            Lembre: lembreText !== undefined ? lembreText : lembrete.Lembre,
            User_list_id: userListId !== undefined ? userListId : lembrete.User_list_id,
            Data_lembre: dataLembre !== undefined ? dataLembre : lembrete.Data_lembre,
          },
          { where: { id: id } }
        )
        res.status(200).json({ message:'Lembrete alterado com sucesso!' })
      } catch (error) {
          res.status(401).json({ message:'Erro ao editar o lembrete' })
      }
  }

};
