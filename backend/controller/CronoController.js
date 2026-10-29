//requerer as funcionalidades do Models CronoModel
const Crono = require('../models/Crono')

//requerer o getToken
const getToken = require('../helpers/get-token')
//requerer a biblioteca jwt 
const jwt = require('jsonwebtoken')

//criar a classe CronoController para as regras de negócio
module.exports = class CronoController {
    static async register(req, res) {
        const { tarefa,progresso,date,User_list_id,} = req.body
        //validações
        if (!tarefa) {
            res.status(422).json({ messCrono_list_id: "a tarefa é obrigatório" })
            return
        }
        if (!User_list_id) {
            res.status(422).json({ messCrono_list_id: "O usuario do crono é obrigatório" })
            return
        }
        if (!progresso) {
            res.status(422).json({ messCrono_list_id: "A progresso é obrigatória" })
            return
        }
        if (!date) {
            res.status(422).json({ messCrono_list_id: "A data da tarefa é obrigatória" })
            return
        }
        try {
            //verificar se já existe um cronograma salvo para o mesmo usuário na mesma data
            const cronoExists = await Crono.findOne({
                where: {
                    User_list_id: User_list_id,
                    date: date
                }
            })

            if (cronoExists) {
                return res.status(422).json({
                    messCrono_list_id: "Já existe um cronograma salvo para este usuário nesta data."
                })
            }

            //criar o novo Cronograma
            const newCrono = await Crono.create({
                tarefa: tarefa,
                User_list_id: User_list_id,
                progresso: progresso,
                date: date,
            })

            return res.status(201).json({
                messCrono_list_id: "Crono Criado!",
                newCrono
            })
        } catch (error) {
            return res.status(500).json({ messCrono_list_id: error })
        }
    }


    //resgatar(listar) a tarefa por id 
    static async getCronoById(req,res){
        //recebendo por parametro (url) o id so Cronograma 
        const id = req.params.id

        //verificar se o Cronograma existe no banco 
        const crono = await Crono.findByPk(
            id,
        )

        //caso a tarefa não existe 
        if(!crono){
            res.status(422).json(
                {messCrono_list_id:'Crono NÂO encontrado!'}
            )
            return
        }
        //retornar o Crono
        res.status(200).json({crono})
    }

    //resgatar(listar) todos os Cronogramas
    static async getAllCronos(req, res) {
        try {
            // aceitar filtro opcional via query: ?user_list_id=1
            const userListId = req.query.user_list_id

            const where = {}
            if (userListId) where.User_list_id = Number(userListId)

            const cronos = await Crono.findAll({ where })

            if (!cronos || cronos.length === 0) {
                return res.status(200).json({ messCrono_list_id: 'Nenhum crono encontrado', cronos: [] })
            }

            return res.status(200).json({ cronos })
        } catch (error) {
            return res.status(500).json({ messCrono_list_id: error.message || error })
        }
    }

    //resgatar(listar) por User_list_id: retornar tarefas, tarefas_completas e progresso
    static async getByUserListId(req, res) {
        // aceitar tanto params quanto query para o id do user_list
        const userListId = req.params.user_list_id || req.query.user_list_id

        if (!userListId) {
            return res.status(400).json({ messCrono_list_id: 'user_list_id é obrigatório' })
        }

        try {
            const items = await Crono.findAll({
                where: { User_list_id: Number(userListId) },
                attributes: ['tarefa', 'progresso', 'tarefa_completa']
            })

            if (!items || items.length === 0) {
                return res.status(200).json({ tarefas: [], tarefas_completas: [], progresso: [] })
            }

            const tarefas = items.map(i => i.tarefa)
            const tarefas_completas = items.map(i => i.tarefa_completa)
            const progresso = items.map(i => i.progresso)

            return res.status(200).json({ tarefas, tarefas_completas, progresso })
        } catch (error) {
            return res.status(500).json({ messCrono_list_id: error.message || error })
        }
    }

    //editar os dados do Cronograma 
    static async editCrono(req,res){
        //recuperar o crono pela requisição
        const id = req.params.id
        
        //recuperar os campos para edição pelo body
        const {tarefa, User_list_id, tarefa_completa} = req.body

    //executar o model para consulta do Cronograma
    const crono = await Crono.findByPk(id)
    
    //caso o Crono nã exista 
    if(!crono){
        res.status(422).json({
            messCrono_list_id:'Crono não encontrado'})
        return
    }
    //acessar o metodo do model para alterar o cronograma
    try {
        await Crono.update({
            tarefa:tarefa,
            User_list_id:User_list_id,
            tarefa_completa:tarefa_completa
        },
        {where:{id:id}}
    )
    res.status(200).json({
        messCrono_list_id:'Crono alterado com SUCESSO!!!'
      })
    } catch (error) {
      res.status(401).json({messCrono_list_id:'Erro ao EDITAR o Crono!'})  
      
    }
 }
}