const DataTypes = require('sequelize')
const db = require('../db/conn')

const PasswordResetCode = db.define('password_reset_codes', {
  user_id: {
    type: DataTypes.INTEGER,
    allowNull: false,
    unique: true,
    references: {
      model: 'users',
      key: 'id',
    },
    onDelete: 'CASCADE',
  },
  code_hash: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  expires_at: {
    type: DataTypes.DATE,
    allowNull: false,
  },
  attempts: {
    type: DataTypes.INTEGER,
    allowNull: false,
    defaultValue: 0,
  },
  last_sent_at: {
    type: DataTypes.DATE,
    allowNull: false,
  },
}, {
  tableName: 'password_reset_codes',
})

module.exports = PasswordResetCode
