// Requerer as funcionalidades do model Exer
const Exer = require("../models/Exer");

// Classe controlador para Exercícios
module.exports = class ExerController {
  static async register(req, res) {
    const { exers, exer_dificuldade } = req.body;

    // Validações
    if (!exers) {
      res.status(422).json({ message: "O campo 'exers' é obrigatório." });
      return;
    }
    if (exer_dificuldade === undefined || exer_dificuldade === null) {
      res.status(422).json({ message: "O campo 'exer_dificuldade' é obrigatório." });
      return;
    }

    // Verificar se já existe um exercício com o mesmo nome
    const exerExists = await Exer.findOne({ where: { exers: exers } });
    if (exerExists) {
      res.status(422).json({ message: "Exercício já cadastrado." });
      return;
    }

    try {
      const newExer = await Exer.create({
        exers: exers,
        exer_dificuldade: exer_dificuldade,
      });

      res.status(201).json({ message: "Exercício criado com sucesso.", exer: newExer });
    } catch (error) {
      res.status(500).json({ message: error.message || error });
    }
  }

  // Retornar todos os exercícios
  static async checkExercicios(req, res) {
    try {
      const exercicios = await Exer.findAll();
      res.status(200).json(exercicios);
    } catch (error) {
      res.status(500).json({ message: error.message || error });
    }
  }

  // Resgatar o exercício por ID
  static async getExerciciosByID(req, res) {
    const id = req.params.id;

    try {
      const exercicio = await Exer.findByPk(id);

      if (!exercicio) {
        res.status(422).json({ message: "Exercício não encontrado." });
        return;
      }

      res.status(200).json({ exercicio });
    } catch (error) {
      res.status(500).json({ message: error.message || error });
    }
  }

  // Editar os dados do exercício
  static async editExercicios(req, res) {
    const id = req.params.id;
    const { exers, exer_dificuldade } = req.body;

    try {
      const exercicio = await Exer.findByPk(id);
      if (!exercicio) {
        res.status(422).json({ message: "Exercício não encontrado." });
        return;
      }

      await Exer.update(
        {
          exers: exers !== undefined ? exers : exercicio.exers,
          exer_dificuldade:
            exer_dificuldade !== undefined ? exer_dificuldade : exercicio.exer_dificuldade,
        },
        { where: { id: id } }
      );

      res.status(200).json({ message: "Exercício alterado com sucesso." });
    } catch (error) {
      res.status(500).json({ message: error.message || error });
    }
  }
};
