//requerer a função de rotas do express
const router = require('express').Router()
//requerer o controllPet
const ExerListController = require('../controller/ExerListController')
//requerer a middleware
const verifytoken = require('../helpers/verify-token')
//criar 

//rota para registrar o usuário
router.post('/register', ExerListController.register)


//rota para retornar(listar) o usuário por id
router.get('/:id', ExerListController.getExerListById)

//rota para retornar(listar) todos os pets
router.get('/', ExerListController.getAllExerLists)

//rota para editar o usuario com verificação de token
router.patch('/edit/:id',verifytoken, ExerListController.editExerList)


module.exports = router


