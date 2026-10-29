//requerer a função de rotas do express
const router = require('express').Router()
//requerer o controllPet
const CronoController = require('../controller/CronoController')
//requerer a middleware
const verifytoken = require('../helpers/verify-token')
//criar 

//rota para registrar o usuário
router.post('/register', CronoController.register)


//rota para retornar(listar) por User_list_id
router.get('/user/:user_list_id', CronoController.getByUserListId)

//rota para retornar(listar) o usuário por id
router.get('/:id', CronoController.getCronoById)

//rota para retornar(listar) todos os pets
router.get('/', CronoController.getAllCronos)

//rota para editar o usuario com verificação de token
router.patch('/edit/:id',verifytoken, CronoController.editCrono)


module.exports = router


