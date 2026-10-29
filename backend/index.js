require('dotenv').config()

//requerer o express
const express = require('express')
//requerer o cors
const cors = require('cors')
//requerer a conexão com o banco
const db = require('./db/conn')
const { createDatabaseIfMissing } = db
//Requerer os Models
const user = require('./models/User')
const crono = require('./models/Crono')
//Requerer as rotas
const UserRoutes = require('./routes/UserRoutes')
const CronoRoutes = require('./routes/CronoRoutes')
const ExerRoutes = require('./routes/ExerRoutes')
const ExerListRoutes = require('./routes/ExerListRoutes')
const LembreRoutes = require('./routes/LembreRoutes')

//instanciar a classe express para api
const api = express()

//configurar JSON response
api.use(express.json())

//Solve cors
api.use(cors({
  credentials: true,
  origin: true,
}))

//Publicação da pasta para imagens
api.use(express.static('public'))

//Routes 
api.use('/users', UserRoutes)
api.use('/cronos', CronoRoutes)
api.use('/exers', ExerRoutes)
api.use('/exerlist', ExerListRoutes)
api.use('/lembres', LembreRoutes)



//start api
createDatabaseIfMissing()
   .then(() => db.sync({ alter: true }))
   .then(() => {
      api.listen(5000, () => console.info('API iniciada na porta 5000'))
   })
   .catch(error => { console.info(error) })
