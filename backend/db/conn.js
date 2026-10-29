
// Requerer a biblioteca referente ao banco Sequelize
const Sequelize = require('sequelize')

const createDatabaseIfMissing = async () => {
  const mysql = require('mysql2/promise')

  const connection = await mysql.createConnection({
    host: '127.0.0.1',
    port: 3307,
    user: 'root',
    password: 'etec',
    database: 'mysql',
  })

  await connection.query('CREATE DATABASE IF NOT EXISTS bd_vivafit')
  await connection.end()
}

// Parâmetros de conexão
const conn = new Sequelize('bd_vivafit', 'root', 'etec', {
  host: '127.0.0.1',
  port: 3307,
  dialect: 'mysql',
})

conn.authenticate()
  .then(() => console.info('Banco de Dados Conectado com Sucesso!!'))
  .catch(error => console.info(`Não foi possível conectar ao banco: ${error}`))

module.exports = conn
module.exports.createDatabaseIfMissing = createDatabaseIfMissing