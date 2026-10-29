const { DataTypes } = require("sequelize");
const db = require("../db/conn");

const Exer = db.define("exer", {
  exers: {
    type: DataTypes.STRING,
    required: true,
  },
  exer_dificuldade: {
    type: DataTypes.INTEGER,
    required: true,
  },
});
module.exports = Exer;
