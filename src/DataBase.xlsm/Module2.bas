Attribute VB_Name = "Module2"
' 定数変換用マップの構築
' 戻り値定義データマップ
'   Key : 定数定義名
'   Data : Key 定数名
'   Data : Data 定数名
Public Function ConstructionDefinisionDataMap() As Dictionary
    Dim Worksheet As Worksheet
    Dim definitionCategoryDataArray As Variant

    Dim workCategory As String
    Dim workCategoryKey As String

    Dim rowCounter As Integer
    Dim collumnCounter As Integer
    Dim normalizedRowCounter As Integer
    Dim normalizedCollumnCounter As Integer

    ' Map生成
    Set DefinitionDataMap = New Dictionary

    ' シート取得
    Set Worksheet = Sheets("Definition")

    ' 定義シート分ループ
    normalizedRowCounter = Worksheet.Range(IndexStartName).Row
    normalizedCollumnCounter = Worksheet.Range(IndexStartName).Column

    ' 定義シート分ループ
    collumnCounter = normalizedCollumnCounter + 1
    While True
        ' 定数名取得
        workCategoryKey = Worksheet.Cells(normalizedRowCounter, collumnCounter).value

        If workCategoryKey = "" Then
            GoTo END_LOOP_POINT:
        End If

        ' Map生成
        definitionCategoryDataArray = Array()

        ' 定数名取得
        rowCounter = normalizedRowCounter + 1
        While True
            workCategory = Worksheet.Cells(rowCounter, collumnCounter + 1).value
            If workCategory = "" Then
                GoTo END_LOOP_POINT2:
            End If

            ' データ追加
            ReDim Preserve definitionCategoryDataArray(rowCounter - normalizedRowCounter - 1)
            definitionCategoryDataArray(rowCounter - normalizedRowCounter - 1) = workCategory

            rowCounter = rowCounter + 1
        Wend
END_LOOP_POINT2:

        ' データリスト追加
        Call DefinitionDataMap.Add(workCategoryKey, definitionCategoryDataArray)

        ' 次のインデックスに移動
        collumnCounter = collumnCounter + 2
    Wend
END_LOOP_POINT:

    ' 戻り値
    Set ConstructionDefinisionDataMap = DefinitionDataMap
End Function


' 定数コードの出力処理
Public Function ExportDefinitionSheet(ExportPath As String)
    Dim fso As New FileSystemObject
    Dim file As TextStream
    Dim Worksheet As Worksheet

    Dim workCategory As String
    Dim workCategoryText As String
    Dim rowCounter As Integer
    Dim collumnCounter As Integer
    Dim normalizedRowCounter As Integer
    Dim normalizedCollumnCounter As Integer

    ' シート取得
    Set Worksheet = Sheets("Definition")

    ' 指定のセル名からデータ定義
    normalizedRowCounter = Worksheet.Range(IndexStartName).Row
    normalizedCollumnCounter = Worksheet.Range(IndexStartName).Column

    ' 定義シート分ループ
    collumnCounter = normalizedCollumnCounter + 1
    While True
        ' 定数名取得
        workCategory = Worksheet.Cells(normalizedRowCounter, collumnCounter).value

        ' 定数コメント
        workCategoryText = Worksheet.Cells(normalizedRowCounter - 1, collumnCounter).value

        If workCategory = "" Then
            GoTo END_LOOP_POINT:
        End If

        ' ファイル生成
        Set file = fso.CreateTextFile(ExportPath & "/" & workCategory & ".h", overwrite:=True, Unicode:=False)

        ' 先頭文字列書き込み
        file.WriteLine (CommentPrefixStart)
        file.WriteLine (CommentPrefixFile & workCategory & ".h")
        file.WriteLine (CommentPrefixBrief & AutoGeneratedBrief)
        file.WriteLine (CommentPrefixAutor & ThisWorkbook.name)
        file.WriteLine (CommentPrefixData & Date)
        file.WriteLine (CommentPrefixEnd)
        file.WriteLine (IncludeGurard & vbCrLf)

        ' enum宣言コメント
        file.WriteLine (CommentPrefixStart)
        file.WriteLine (CommentPrefixEnum & workCategory)
        file.WriteLine (CommentPrefixBrief & workCategoryText)
        file.WriteLine (CommentPrefixEnd)

        ' カテゴリー生成開始
        file.WriteLine ("enum" & vbTab & "class" & vbTab & workCategory & vbCrLf & "{")

        ' 定数名取得
        rowCounter = normalizedRowCounter + 1
        While True
            workCategory = Worksheet.Cells(rowCounter, collumnCounter).value
            workCategoryText = Worksheet.Cells(rowCounter, collumnCounter + 1).value
            If workCategory = "" Then
                GoTo END_LOOP_POINT2:
            End If

            ' 書き込み
            file.WriteLine (vbTab & workCategory & "," & vbTab & "//!<" & vbTab & workCategoryText)

            rowCounter = rowCounter + 1
        Wend
END_LOOP_POINT2:

        ' カテゴリー生成終了
        file.WriteLine ("};")

        ' ファイルを閉じる
        file.Close

        ' 次のインデックスに移動
        collumnCounter = collumnCounter + 2
    Wend
END_LOOP_POINT:

End Function


