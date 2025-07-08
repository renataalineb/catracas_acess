BEGIN
	DECLARE @cod_pessoa INT;

	-- Inserir uma nova pessoa
	INSERT INTO dbo.Pessoas (Tipo, Identificador_Facial)
	VALUES (1, 123456789012344);

	-- Capturar o ID gerado automaticamente (COD_PESSOA)
	SET @cod_pessoa = SCOPE_IDENTITY();

	-- Inserir o visitante associado à pessoa
	INSERT INTO dbo.Visitantes (
		COD_PESSOA,
		Nome,
		Documento,
		Empresa,
		Fone,
		Observacao,
		COD_ZT,
		COD_PERFIL,
		Bloqueado,
		IgnorarRota,
		IgnorarAntiPassback,
		IgnorarEntradas,
		IDExportacao,
		SenhaAcesso,
		enviarCartaoSemFace
	)
	VALUES (
		@cod_pessoa,
		N'João da Costa',
		N'12345678901',
		N'Empresa Teste',
		N'(99)99999-9990',
		N'Primeira visita',
		0,
		1,
		0,
		0,
		0,
		0,
		NULL,
		NULL,
		0
	);
END





-------------------------------------------------------------------------------------------------------------------------------------------------------------

-- Certifique-se de que o banco acesso_cat está selecionado
BEGIN
	DECLARE @cod_pessoa INT;

	-- 1
	INSERT INTO dbo.Pessoas (Tipo, Identificador_Facial) VALUES (1, 100000000000001);
	SET @cod_pessoa = SCOPE_IDENTITY();
	INSERT INTO dbo.Visitantes VALUES (@cod_pessoa, N'Ana Souza', N'11111111111', N'ABC Corp', N'(11)91111-1111', N'Visita técnica', 0, 1, 0, 0, 0, 0, NULL, NULL, 1);

	-- 2
	INSERT INTO dbo.Pessoas (Tipo, Identificador_Facial) VALUES (2, 100000000000002);
	SET @cod_pessoa = SCOPE_IDENTITY();
	INSERT INTO dbo.Visitantes VALUES (@cod_pessoa, N'Carlos Mendes', N'22222222222', N'XYZ Ltda', N'(21)92222-2222', N'Reunião comercial', 1, 2, 0, 0, 0, 0, NULL, NULL, 0);

	-- 3
	INSERT INTO dbo.Pessoas (Tipo, Identificador_Facial) VALUES (1, 100000000000003);
	SET @cod_pessoa = SCOPE_IDENTITY();
	INSERT INTO dbo.Visitantes VALUES (@cod_pessoa, N'Mariana Lima', N'33333333333', N'Construtora Alpha', N'(31)93333-3333', N'Acompanhamento de obra', 0, 1, 0, 0, 0, 0, NULL, NULL, 1);

	-- 4
	INSERT INTO dbo.Pessoas (Tipo, Identificador_Facial) VALUES (1, 100000000000004);
	SET @cod_pessoa = SCOPE_IDENTITY();
	INSERT INTO dbo.Visitantes VALUES (@cod_pessoa, N'Bruno Rocha', N'44444444444', N'BetaTech', N'(41)94444-4444', N'Treinamento interno', 0, 1, 0, 0, 0, 0, NULL, NULL, 0);

	-- 5
	INSERT INTO dbo.Pessoas (Tipo, Identificador_Facial) VALUES (2, 100000000000005);
	SET @cod_pessoa = SCOPE_IDENTITY();
	INSERT INTO dbo.Visitantes VALUES (@cod_pessoa, N'Fernanda Dias', N'55555555555', N'Segurança Max', N'(51)95555-5555', N'Acesso autorizado', 1, 2, 0, 0, 0, 0, NULL, NULL, 1);

	-- 6
	INSERT INTO dbo.Pessoas (Tipo, Identificador_Facial) VALUES (2, 100000000000006);
	SET @cod_pessoa = SCOPE_IDENTITY();
	INSERT INTO dbo.Visitantes VALUES (@cod_pessoa, N'José Almeida', N'66666666666', N'Delta Consultoria', N'(61)96666-6666', N'Reunião com diretor', 0, 1, 0, 0, 0, 0, NULL, NULL, 1);

	-- 7
	INSERT INTO dbo.Pessoas (Tipo, Identificador_Facial) VALUES (1, 100000000000007);
	SET @cod_pessoa = SCOPE_IDENTITY();
	INSERT INTO dbo.Visitantes VALUES (@cod_pessoa, N'Lúcia Ferreira', N'77777777777', N'Gamma Serviços', N'(71)97777-7777', N'Visita institucional', 1, 2, 0, 0, 0, 0, NULL, NULL, 0);

	-- 8
	INSERT INTO dbo.Pessoas (Tipo, Identificador_Facial) VALUES (2, 100000000000008);
	SET @cod_pessoa = SCOPE_IDENTITY();
	INSERT INTO dbo.Visitantes VALUES (@cod_pessoa, N'André Costa', N'88888888888', N'Alpha Engenharia', N'(81)98888-8888', N'Coordenador visitante', 0, 1, 0, 0, 0, 0, NULL, NULL, 1);

	-- 9
	INSERT INTO dbo.Pessoas (Tipo, Identificador_Facial) VALUES (1, 100000000000009);
	SET @cod_pessoa = SCOPE_IDENTITY();
	INSERT INTO dbo.Visitantes VALUES (@cod_pessoa, N'Juliana Nogueira', N'99999999999', N'Finanças PJ', N'(91)99999-9999', N'Reunião com RH', 0, 1, 0, 0, 0, 0, NULL, NULL, 0);

	-- 10
	INSERT INTO dbo.Pessoas (Tipo, Identificador_Facial) VALUES (1, 100000000000010);
	SET @cod_pessoa = SCOPE_IDENTITY();
	INSERT INTO dbo.Visitantes VALUES (@cod_pessoa, N'Mateus Cunha', N'10101010101', N'Empresa Zeta', N'(83)91010-1010', N'Teste de acesso', 1, 2, 0, 0, 0, 0, NULL, NULL, 0);

	-- 11
	INSERT INTO dbo.Pessoas (Tipo, Identificador_Facial) VALUES (1, 100000000000011);
	SET @cod_pessoa = SCOPE_IDENTITY();
	INSERT INTO dbo.Visitantes VALUES (@cod_pessoa, N'Cláudia Rezende', N'12121212121', N'Solar Engenharia', N'(85)91212-1212', N'Visita ao setor', 0, 1, 0, 0, 0, 0, NULL, NULL, 1);

	-- 12
	INSERT INTO dbo.Pessoas (Tipo, Identificador_Facial) VALUES (1, 100000000000012);
	SET @cod_pessoa = SCOPE_IDENTITY();
	INSERT INTO dbo.Visitantes VALUES (@cod_pessoa, N'Thiago Ribeiro', N'13131313131', N'Eco Ambiental', N'(87)91313-1313', N'Supervisão externa', 0, 2, 0, 0, 0, 0, NULL, NULL, 0);

	-- 13
	INSERT INTO dbo.Pessoas (Tipo, Identificador_Facial) VALUES (1, 100000000000013);
	SET @cod_pessoa = SCOPE_IDENTITY();
	INSERT INTO dbo.Visitantes VALUES (@cod_pessoa, N'Isabela Silva', N'14141414141', N'Unidade Saúde', N'(89)91414-1414', N'Representante médica', 0, 2, 0, 0, 0, 0, NULL, NULL, 1);

	-- 14
	INSERT INTO dbo.Pessoas (Tipo, Identificador_Facial) VALUES (2, 100000000000014);
	SET @cod_pessoa = SCOPE_IDENTITY();
	INSERT INTO dbo.Visitantes VALUES (@cod_pessoa, N'Paulo Martins', N'15151515151', N'Tecnologia Inova', N'(91)91515-1515', N'Treinamento de TI', 1, 2, 0, 0, 0, 0, NULL, NULL, 0);

	-- 15
	INSERT INTO dbo.Pessoas (Tipo, Identificador_Facial) VALUES (1, 100000000000015);
	SET @cod_pessoa = SCOPE_IDENTITY();
	INSERT INTO dbo.Visitantes VALUES (@cod_pessoa, N'Aline Torres', N'16161616161', N'Marketing BR', N'(93)91616-1616', N'Evento corporativo', 0, 1, 0, 0, 0, 0, NULL, NULL, 0);

	-- 16
	INSERT INTO dbo.Pessoas (Tipo, Identificador_Facial) VALUES (1, 100000000000016);
	SET @cod_pessoa = SCOPE_IDENTITY();
	INSERT INTO dbo.Visitantes VALUES (@cod_pessoa, N'Roberto Castro', N'17171717171', N'Rádio Mix', N'(95)91717-1717', N'Entrevista institucional', 0, 2, 0, 0, 0, 0, NULL, NULL, 1);

	-- 17
	INSERT INTO dbo.Pessoas (Tipo, Identificador_Facial) VALUES (2, 100000000000017);
	SET @cod_pessoa = SCOPE_IDENTITY();
	INSERT INTO dbo.Visitantes VALUES (@cod_pessoa, N'Sabrina Lopes', N'18181818181', N'MidiaCheck', N'(97)91818-1818', N'Mídia autorizada', 1, 2, 0, 0, 0, 0, NULL, NULL, 1);

	-- 18
	INSERT INTO dbo.Pessoas (Tipo, Identificador_Facial) VALUES (2, 100000000000018);
	SET @cod_pessoa = SCOPE_IDENTITY();
	INSERT INTO dbo.Visitantes VALUES (@cod_pessoa, N'Rafael Mendes', N'19191919191', N'Controle Interno', N'(99)91919-1919', N'Relatório auditoria', 0, 1, 0, 0, 0, 0, NULL, NULL, 0);
	
	END



