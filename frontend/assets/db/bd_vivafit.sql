create database bd_vivafit;

use bd_vivafit;

create table User (
ID_DO_USUARIO int auto_increment,
NOME varchar(40) not null,
IDADE varchar(40) not null, 
NASCIMENTO date not null,
ALTURA float(7,2) not null,
PESO float(7,2) not null,
IMC float(7,2) not null,
SEXO varchar(1) not null,
EMAIL varchar(60) not null,
SENHA_HASH varchar(99) not null,
LEVE_DE_ATIVIDADE int not null,
LEVEL_DE_ADM int,
primary key(ID_DO_USUARIO)) engine InnoDB;

create table Cronograma (
CRONOGRAMA_USUARIO int auto_increment,
TAREFAS varchar(999),
POGRESSO INT,
TAREFAS_CONCLUIDAS INT,
CRONOGRAMA_HYDRATAÇÃO varchar(999),
DIAS_ITENSIVOS DATE,
primary key(CRONOGRAMA_USUARIO)) engine InnoDB;

create table Points (
PONTOS_USER_ID int auto_increment,
PONTOS int not null,
primary key(PONTOS_USER_ID)) engine InnoDB;

create table Lembretes (
USER_LEMBRETES_ID int auto_increment,
TIPO_LEMBRETE INT,
ATIVO_DESATIVADO_LEMBRETE INT,
LISTA_LEMBRETES varchar(999) not null,
primary key(USER_LEMBRETES_ID)) engine InnoDB;

create table Exercises_List (
LISTA_EXERCICIOS_ID int auto_increment,
LISTA_EXERCICIOS varchar(40) not null,
EXERCICIOS_COMPLETED INT,
primary key(LISTA_EXERCICIOS_ID)) engine InnoDB;

create table Exercises (
EXERCICIOS_ID int auto_increment,
EXERCICIOS_NOME varchar(40) not null,
EXERCICIOS_DIFICULDADE INT NOT NULL,
primary key(EXERCICIOS_ID)) engine InnoDB;