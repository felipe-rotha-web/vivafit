//requerer a função de rotas do express
const router = require('express').Router()
//requerer o controllPet
const LembreController = require('../controller/LembreController')
//requerer a middleware
const verifytoken = require('../helpers/verify-token')
//criar 

//rota para registrar o usuário
router.post('/register', LembreController.register)



//rota para retornar(listar) por User_list_id
router.get('/user/:id', LembreController.getByUserListId)

//rota para retornar(listar) o usuário por id
router.get('/:id', LembreController.getLembreById)

//rota para retornar(listar) todos os lembretes
router.get('/', LembreController.getAllLembre)

//rota para editar o usuario com verificação de token
router.patch('/edit/:id',verifytoken, LembreController.editLembre)


module.exports = router


