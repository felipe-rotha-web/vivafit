const { DataTypes } = require("sequelize");
const db = require("../db/conn");

const ExerList = db.define("exerlist", {
  exerlist: {
    type: DataTypes.STRING,
    required: true,
  },
  exer_completa: {
    type: DataTypes.INTEGER,
    required: true,
  },
  User_list_id: {
    type: DataTypes.INTEGER,
    required: true,
  },
  list_number: {
    type: DataTypes.INTEGER,
  },
  exer_id: {
    type: DataTypes.INTEGER,
    required: true,
  },
});
module.exports = ExerList;
