const { DataTypes } = require("sequelize");
const db = require("../db/conn");

const Lembre = db.define("lembre", {
  Lembre: {
    type: DataTypes.STRING,
    required: true,
  },
  User_list_id: {
    type: DataTypes.INTEGER,
    required: true,
  },
  Data_lembre: {
    type: DataTypes.STRING,
    required: true,
  },
});
module.exports = Lembre;
