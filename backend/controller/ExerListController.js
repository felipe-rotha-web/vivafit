// Requerer o model ExerList
const ExerList = require("../models/ExerList");
// Requerer o model Exer para validar existência do exercício
const Exer = require("../models/Exer");

module.exports = class ExerListController {
  // Criar um novo registro de lista de exercício
  static async register(req, res) {
    const { exer_id, exer_completa, User_list_id, list_number } = req.body;

    if (!exer_id) {
      res.status(422).json({ message: "O campo 'exer_id' é obrigatório." });
      return;
    }
    if (exer_completa === undefined || exer_completa === null) {
      res.status(422).json({ message: "O campo 'exer_completa' é obrigatório." });
      return;
    }
    if (!User_list_id) {
      res.status(422).json({ message: "O campo 'User_list_id' é obrigatório." });
      return;
    }


    try {
      // Definir o número da lista como 1 se não for enviado
      const effectiveListNumber = list_number !== undefined && list_number !== null ? list_number : 1;

      // Evitar duplicatas para o mesmo usuário: mesmo exer_id, User_list_id e list_number
      const exists = await ExerList.findOne({
        where: {
          exer_id: exer_id,
          User_list_id: User_list_id,
          list_number: effectiveListNumber,
        },
      });
      if (exists) {
        res.status(422).json({ message: "Lista de exercício já cadastrada para este usuário com este número de lista." });
        return;
      }

      // Verificar se o exercício informado existe na tabela Exer (por id)
      const exerExists = await Exer.findByPk(exer_id);
      if (!exerExists) {
        res.status(422).json({ message: "Exercício não encontrado. Crie o exercício antes de adicioná-lo à lista." });
        return;
      }

      // montar payload: se `list_number` foi enviado, usa-o, senão usa 1
      const createPayload = {
        exer_id,
        exerlist: exerExists.exers,
        exer_completa,
        User_list_id,
        list_number: effectiveListNumber,
      };

      const newExerList = await ExerList.create(createPayload);
      res.status(201).json({ message: "Lista criada com sucesso.", exerlist: newExerList });
    } catch (error) {
      res.status(500).json({ message: error.message || error });
    }
  }

  // Retornar todos os registros de ExerList, com opção de busca por user_list_id e list_number
  static async getAllExerLists(req, res) {
    const { user_list_id, list_number } = req.query;

    try {
      const where = {};
      if (user_list_id !== undefined) {
        where.User_list_id = user_list_id;
      }
      if (list_number !== undefined) {
        where.list_number = list_number;
      }

      const lists = await ExerList.findAll({ where });
      res.status(200).json(lists);
    } catch (error) {
      res.status(500).json({ message: error.message || error });
    }
  }

  // Retornar as listas de exercício por User_list_id
  static async getExerListById(req, res) {
    const userListId = req.params.id;
    try {
      const lists = await ExerList.findAll({ where: { User_list_id: userListId } });
      if (!lists || lists.length === 0) {
        res.status(422).json({ message: "Nenhuma lista encontrada para este User_list_id." });
        return;
      }
      res.status(200).json({ lists });
    } catch (error) {
      res.status(500).json({ message: error.message || error });
    }
  }

  // Editar um registro de ExerList
  static async editExerList(req, res) {
    const id = req.params.id;
    const { exer_id, exer_completa, User_list_id, list_number } = req.body;

    try {
      const list = await ExerList.findByPk(id);
      if (!list) {
        res.status(422).json({ message: "Lista não encontrada." });
        return;
      }

      const updates = {};
      if (exer_id !== undefined) {
        const exerExists = await Exer.findByPk(exer_id);
        if (!exerExists) {
          res.status(422).json({ message: "Exercício informado não existe." });
          return;
        }
        updates.exer_id = exer_id;
        updates.exerlist = exerExists.exers;
      }
      updates.exer_completa = exer_completa !== undefined ? exer_completa : list.exer_completa;
      updates.User_list_id = User_list_id !== undefined ? User_list_id : list.User_list_id;
      updates.list_number = list_number !== undefined ? list_number : list.list_number;

      await ExerList.update(updates, { where: { id: id } });

      res.status(200).json({ message: "Lista atualizada com sucesso." });
    } catch (error) {
      res.status(500).json({ message: error.message || error });
    }
  }
};
