CREATE TABLE acesso_cat.dbo.Pessoas (
	COD_PESSOA int IDENTITY(1,1) NOT NULL,
	Tipo tinyint NULL,
	Identificador_Facial bigint NULL,
	CONSTRAINT PK_Pessoas PRIMARY KEY (COD_PESSOA)
);
 CREATE UNIQUE NONCLUSTERED INDEX idx_Identificador_Facial ON acesso_cat.dbo.Pessoas (  Identificador_Facial ASC  )  
	 WHERE  ([Identificador_Facial] IS NOT NULL)
	 WITH (  PAD_INDEX = OFF ,FILLFACTOR = 100  ,SORT_IN_TEMPDB = OFF , IGNORE_DUP_KEY = OFF , STATISTICS_NORECOMPUTE = OFF , ONLINE = OFF , ALLOW_ROW_LOCKS = ON , ALLOW_PAGE_LOCKS = ON  )
	 ON [PRIMARY ] ;



CREATE TABLE acesso_cat.dbo.Visitantes (
	COD_PESSOA int NOT NULL,
	Nome nvarchar(50) COLLATE Latin1_General_CI_AS NOT NULL,
	Documento nvarchar(25) COLLATE Latin1_General_CI_AS NULL,
	Empresa nvarchar(100) COLLATE Latin1_General_CI_AS NULL,
	Fone nvarchar(25) COLLATE Latin1_General_CI_AS NULL,
	Observacao nvarchar(255) COLLATE Latin1_General_CI_AS NULL,
	COD_ZT int DEFAULT 0 NOT NULL,
	COD_PERFIL int DEFAULT 0 NOT NULL,
	Bloqueado bit NOT NULL,
	IgnorarRota bit NOT NULL,
	IgnorarAntiPassback bit NOT NULL,
	IgnorarEntradas bit NOT NULL,
	IDExportacao nvarchar(20) COLLATE Latin1_General_CI_AS NULL,
	SenhaAcesso nvarchar(10) COLLATE Latin1_General_CI_AS NULL,
	enviarCartaoSemFace bit NULL,
	CONSTRAINT PK_Visitantes PRIMARY KEY (COD_PESSOA),
	CONSTRAINT FK_Visitantes_Pessoas FOREIGN KEY (COD_PESSOA) REFERENCES acesso_cat.dbo.Pessoas(COD_PESSOA) ON DELETE CASCADE ON UPDATE CASCADE
);


-- Habilitar CDC no banco de dados:

USE acesso_cat;
EXEC sys.sp_cdc_enable_db;

    --Habilitar CDC na tabela desejada:

-- Ativar CDC na tabela
EXEC sys.sp_cdc_enable_table
  @source_schema = 'dbo',
  @source_name   = 'Visitantes',
  @role_name     = NULL;

    --(Opcional) Verificar se o CDC foi habilitado:

SELECT is_cdc_enabled FROM sys.databases WHERE name = 'acesso_cat';

SELECT name, is_tracked_by_cdc FROM sys.tables WHERE name = 'Visitantes';
