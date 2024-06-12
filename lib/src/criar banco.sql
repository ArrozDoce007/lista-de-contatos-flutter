create database contatos_db;

use contatos_db;

create table contatos (
id int auto_increment primary key,
nome varchar(255) not null,
numero varchar(50) not null,
email varchar(255) not null
);

drop database contatos;

select * from contatos;