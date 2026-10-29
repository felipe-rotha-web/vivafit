const { DataTypes } = require("sequelize");
const db = require("../db/conn");

const Crono = db.define("cronos", {
  tarefa: {
    type: DataTypes.STRING,
    required: true,
  },
  progresso: {
    type: DataTypes.INTEGER,
    required: true,
  },
  date: {
    type: DataTypes.STRING,
    required: true,
  },
  User_list_id: {
    type: DataTypes.INTEGER,
    required: true,
  },
});
module.exports = Crono;
