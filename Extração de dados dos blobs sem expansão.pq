let
    Source = DataLake_Connection,
    Arquivos = Table.SelectRows(Source, each Text.EndsWith([Folder Path], "pastadentrodoblobprincipal/")),


       GetDados = (i as number) =>
        let  
         //     i = 0,
             NomeArquivo = Arquivos{i}[Name],   
            CSV = Arquivos{i}[Content],
            #"Imported CSV" = Csv.Document(CSV,[Delimiter=",", Columns=7, Encoding=65001, QuoteStyle=QuoteStyle.None]),
    #"Linhas Principais Removidas" = Table.Skip(#"Imported CSV",0),
    #"Dividir Coluna por Delimitador" = Table.SplitColumn(#"Linhas Principais Removidas", "Column1", Splitter.SplitTextByDelimiter(";", QuoteStyle.None), {"Column1.1"}),
            #"Promoted Headers" = Table.PromoteHeaders(#"Dividir Coluna por Delimitador", [PromoteAllScalars=true]),
            #"Adiciona Nome do Arquivo" = Table.TransformColumnTypes(#"Promoted Headers",{}),
    Dados = Table.AddColumn(#"Adiciona Nome do Arquivo", "Arquivo", each NomeArquivo),
    Result = 
               if i = Table.RowCount(Arquivos) -1 then  
                    Dados 
                else 
                    Table.Combine({Dados,@GetDados(i+1)}) 
        in
            Result,
            Result = GetDados(0)
in
    Result