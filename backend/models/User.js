const DataTypes = require('sequelize')
const db = require('../db/conn')

const User = db.define('users',{
    nome:{
        type: DataTypes.STRING,
        allowNull: false,
    },
    idade:{
        type: DataTypes.STRING,
        allowNull: false,
    },
    nascimento:{
        type: DataTypes.STRING,
        allowNull: false,
    },
    altura:{
        type: DataTypes.STRING,
        allowNull: true,
    },
    peso:{
        type: DataTypes.STRING,
        allowNull: false,
    },
    imc:{
        type: DataTypes.STRING,
        allowNull: true,
    },
    genero:{
        type: DataTypes.STRING,
        allowNull: false,
    },
    email:{
        type: DataTypes.STRING,
        allowNull: false,
    },
    senha:{
        type: DataTypes.STRING,
        allowNull: false,
    },
    lvl_atividade:{
        type: DataTypes.STRING,
        allowNull: false,
    },
    theme_mode:{
        type: DataTypes.STRING,
        allowNull: false,
        defaultValue: 'normal',
    },
    daltonism_variant:{
        type: DataTypes.STRING,
        allowNull: false,
        defaultValue: 'deuteranopia',
    },
    crono_hydro:{
        type: DataTypes.STRING,
        allowNull: true,
    },
    dias_itensivos:{
        type: DataTypes.STRING,
        allowNull: true,
    },
    lvl_adm:{
        type: DataTypes.STRING,
        allowNull: true,
    },
})

module.exports = User