let
    Funcion = 
    (#"Ruta Local de las Imagenes" as text) as table =>
        let
            Origen = 
            Folder.Files( #"Ruta Local de las Imagenes" ),

            RemoveOtherColumns = 
            Table.SelectColumns(
                Origen,
                {"Content", "Name"}
            ),

            SplitTextFunction = 
            Splitter.SplitTextByRepeatedLengths(30000),

            ListInput = Table.ToRows(RemoveOtherColumns),

            ConvertOneFile = (InputRow as list) =>
                let
                    BinaryIn = InputRow{0},
                    FileName = InputRow{1},
                    BinaryText = 
                    Binary.ToText(
                        BinaryIn, 
                        BinaryEncoding.Base64
                    ),

                    SplitUpText = SplitTextFunction(BinaryText),
                    AddFileName = 
                    List.Transform(
                        SplitUpText, 
                        each {FileName,_}
                    )
                in
                    AddFileName,

            ConvertAllFiles = 
            List.Transform(
                ListInput, 
                each 
                ConvertOneFile(_)
            ),

            CombineLists = 
            List.Combine(ConvertAllFiles),

            ToTable = 
            #table(
                type table
                [
                    Nombre=text,
                    Imagen=text
                ], 
                CombineLists
            ),

            AddIndexColumn = 
            Table.AddIndexColumn(
                ToTable, 
                "Índice", 
                0, 
                1
            )

        in
            AddIndexColumn,
    Documentacion = 
    [
        Documentation.Name = "Binary_ToMultipleTextCells" ,
        Documentation.LongDescription = " Esta función retorna una tabla con las imagenes de una localización en formato texto divido en mútiples celdas de no más 30mil caracteres" ,
        Documentation.Examples = 
        {
            [
                Description = "Ejemplo para Segmentación con Imagenes" ,
                Code = " Para un ejemplo, visitar: #(lf) https://www.youtube.com/c/ExcelFreeblog/ ",
                Result = ""
            ]
        }
    ] 
in
    Value.ReplaceType(
         Funcion ,
         Value.ReplaceMetadata(
            Value.Type( Funcion ) , 
            Documentacion
         )
    )