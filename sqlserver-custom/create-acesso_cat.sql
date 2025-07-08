-- Cria o banco de dados 'acesso_cat'
IF NOT EXISTS (SELECT name FROM sys.databases WHERE name = 'acesso_cat')
BEGIN
    CREATE DATABASE acesso_cat;
END;
GO
