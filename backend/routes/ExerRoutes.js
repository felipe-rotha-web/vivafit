//requerer a função de rotas do express
const router = require('express').Router()
//requerer o controllPet
const ExerController = require('../controller/ExerController')
//requerer a middleware
const verifytoken = require('../helpers/verify-token')
//criar 

// rota para registrar um exercício
router.post('/register', ExerController.register)

// rota para retornar (listar) todos os exercícios
router.get('/', ExerController.checkExercicios)

// rota para retornar (listar) um exercício por id
router.get('/:id', ExerController.getExerciciosByID)

// rota para editar o exercício (com verificação de token)
router.patch('/edit/:id', verifytoken, ExerController.editExercicios)


module.exports = router


