codeunit 50181 "Item JSON Parser"
{
    TableNo = "Item Parse Session";

    /// <summary>
    /// Entry point for a background session.
    /// Rec holds the session configuration (session number and index range) written
    /// by ParseBlobToItems() before StartSession was called.
    /// </summary>
    trigger OnRun()
    begin
        ProcessChunk(Rec."Session No.", Rec."Start Index", Rec."End Index");
    end;

    /// <summary>
    /// Reads the JSON blob, splits it into five equal ranges, clears the parsed
    /// buffer, and starts five background sessions – one per range.
    /// The remainder of an uneven division is absorbed by session 5.
    /// Stores the start time in the blob record so ShowParallelTiming() can
    /// compute wall-clock elapsed time after all sessions have finished.
    /// </summary>
    procedure ParseBlobToItems()
    var
        ItemJSONBlob: Record "Item JSON Blob";
        ParsedItemBuffer: Record "Parsed Item Buffer";
        ItemParseSession: Record "Item Parse Session";
        SessionIds: array[5] of Integer;
        SessionNo: Integer;
        ItemsPerSession: Integer;
        StartedAt: DateTime;
    begin
        if not ItemJSONBlob.Get(1) then
            Error('No item JSON blob found. Please use "Generate Test Blob" first.');

        if ItemJSONBlob.Count() <> 5 then
            Error('Parallel parse requires 5 blob records (one per session). Please use "Generate Test Blob" first.');

        ItemsPerSession := ItemJSONBlob."No. of Items";

        ParsedItemBuffer.DeleteAll();
        ItemParseSession.DeleteAll();
        Commit();

        // StartIndex = Entry No. base offset so each session writes a non-overlapping PK range.
        // Each session fetches its own blob record via Get(SessionNo), so End Index is unused.
        for SessionNo := 1 to 5 do begin
            ItemParseSession.Init();
            ItemParseSession."Session No." := SessionNo;
            ItemParseSession."Start Index" := (SessionNo - 1) * ItemsPerSession;
            ItemParseSession."End Index" := 0;
            ItemParseSession.Insert();
        end;

        // Stamp start time on all blob records
        StartedAt := CurrentDateTime();
        if ItemJSONBlob.FindSet(true) then
            repeat
                ItemJSONBlob."Parse Started At" := StartedAt;
                ItemJSONBlob.Modify();
            until ItemJSONBlob.Next() = 0;
        Commit();

        for SessionNo := 1 to 5 do begin
            ItemParseSession.Get(SessionNo);
            if not StartSession(SessionIds[SessionNo], Codeunit::"Item JSON Parser", CompanyName(), ItemParseSession) then
                Error('Could not start background session %1.', SessionNo);
        end;

        Message('Started 5 background sessions to parse %1 items.\Use "Show Parallel Timing" once all records appear.', 5 * ItemsPerSession);
    end;

    /// <summary>
    /// Parses all blob records sequentially in the current session (no background
    /// sessions). Iterates every "Item JSON Blob" record so it handles both a
    /// single monolithic blob and the 5-record split created by GenerateTestBlob().
    /// Session No. is set to 0 on all records to distinguish from parallel records.
    /// </summary>
    procedure ParseBlobToItemsSequential()
    var
        ItemJSONBlob: Record "Item JSON Blob";
        ParsedItemBuffer: Record "Parsed Item Buffer";
        InStr: InStream;
        JsonText: Text;
        JsonArr: JsonArray;
        JsonToken: JsonToken;
        ItemObj: JsonObject;
        StartTime: DateTime;
        EndTime: DateTime;
        ElapsedMs: Duration;
        i: Integer;
        EntryBase: Integer;
        TotalProcessed: Integer;
    begin
        if not ItemJSONBlob.FindFirst() then
            Error('No item JSON blob found. Please generate test data first.');

        ParsedItemBuffer.DeleteAll();
        Commit();

        StartTime := CurrentDateTime();

        if ItemJSONBlob.FindSet() then
            repeat
                Clear(JsonArr);
                ItemJSONBlob.CalcFields("JSON Data");
                ItemJSONBlob."JSON Data".CreateInStream(InStr, TextEncoding::UTF8);
                InStr.ReadText(JsonText);

                if not JsonArr.ReadFrom(JsonText) then
                    Error('Failed to parse JSON data from blob record %1.', ItemJSONBlob."Entry No.");

                // Base offset ensures unique Entry No. across all blob records
                EntryBase := (ItemJSONBlob."Entry No." - 1) * ItemJSONBlob."No. of Items";

                for i := 0 to ItemJSONBlob."No. of Items" - 1 do begin
                    if JsonArr.Get(i, JsonToken) then begin
                        ItemObj := JsonToken.AsObject();
                        ParsedItemBuffer.Init();
                        ParsedItemBuffer."Entry No." := EntryBase + i + 1;
                        ParsedItemBuffer."Item No." := GetJsonText(ItemObj, 'No');
                        ParsedItemBuffer.Description := GetJsonText(ItemObj, 'Description');
                        ParsedItemBuffer."Unit Price" := GetJsonDecimal(ItemObj, 'UnitPrice');
                        ParsedItemBuffer."Unit Cost" := GetJsonDecimal(ItemObj, 'UnitCost');
                        ParsedItemBuffer.Inventory := GetJsonDecimal(ItemObj, 'Inventory');
                        ParsedItemBuffer."Base Unit of Measure" := GetJsonText(ItemObj, 'BaseUnitOfMeasure');
                        ParsedItemBuffer."Item Category Code" := GetJsonText(ItemObj, 'ItemCategoryCode');
                        ParsedItemBuffer."Session No." := 0;
                        ParsedItemBuffer."Processed At" := CurrentDateTime();
                        ParsedItemBuffer.Insert();
                        TotalProcessed += 1;
                    end;
                end;
            until ItemJSONBlob.Next() = 0;

        Commit();

        EndTime := CurrentDateTime();
        ElapsedMs := EndTime - StartTime;
        Message('Sequential parse complete.\%1 items processed in %2 ms.', TotalProcessed, ElapsedMs);
    end;

    /// <summary>
    /// Computes the wall-clock elapsed time of the last parallel parse by comparing
    /// the stored Parse Started At timestamp against the latest Processed At value
    /// across all Parsed Item Buffer records. Call this after all background sessions
    /// have finished (i.e. the record count equals the expected item count).
    /// </summary>
    procedure ShowParallelTiming()
    var
        ItemJSONBlob: Record "Item JSON Blob";
        ParsedItemBuffer: Record "Parsed Item Buffer";
        MaxProcessedAt: DateTime;
        ElapsedMs: Duration;
        TotalParsed: Integer;
        TotalExpected: Integer;
    begin
        if not ItemJSONBlob.Get(1) then
            Error('No blob record found.');
        if ItemJSONBlob."Parse Started At" = 0DT then
            Error('No parallel parse has been started yet. Use "Parse & Import" first.');

        // Sum across all blob records to get the true total
        if ItemJSONBlob.FindSet() then
            repeat
                TotalExpected += ItemJSONBlob."No. of Items";
            until ItemJSONBlob.Next() = 0;

        ParsedItemBuffer.SetCurrentKey("Processed At");
        if not ParsedItemBuffer.FindLast() then
            Error('No parsed items found. Sessions may still be running.');

        MaxProcessedAt := ParsedItemBuffer."Processed At";
        ParsedItemBuffer.Reset();
        ParsedItemBuffer.ReadIsolation := IsolationLevel::ReadUncommitted;
        TotalParsed := ParsedItemBuffer.Count();

        ItemJSONBlob.Get(1);
        ElapsedMs := MaxProcessedAt - ItemJSONBlob."Parse Started At";
        Message('Parallel parse timing\Items expected : %1\Items parsed   : %2\Elapsed time   : %3 ms\\Note: measured from session launch to the last recorded insert.',
            TotalExpected, TotalParsed, ElapsedMs);
    end;

    /// <summary>
    /// Runs inside a background session. Reads only the blob record for this session
    /// (Entry No. = SessionNo), parses its JSON array, and inserts one Parsed Item Buffer
    /// record per element. EntryBase (= StartIdx) is added to the array position to
    /// produce a globally unique Entry No. without cross-session coordination.
    /// </summary>
    local procedure ProcessChunk(SessionNo: Integer; StartIdx: Integer; EndIdx: Integer)
    var
        ItemJSONBlob: Record "Item JSON Blob";
        ParsedItemBuffer: Record "Parsed Item Buffer";
        InStr: InStream;
        JsonText: Text;
        JsonArr: JsonArray;
        JsonToken: JsonToken;
        ItemObj: JsonObject;
        i: Integer;
    begin
        // Each session only fetches its own dedicated blob record
        if not ItemJSONBlob.Get(SessionNo) then
            exit;

        ItemJSONBlob.CalcFields("JSON Data");
        ItemJSONBlob."JSON Data".CreateInStream(InStr, TextEncoding::UTF8);
        InStr.ReadText(JsonText);

        if not JsonArr.ReadFrom(JsonText) then
            exit;

        // StartIdx is the Entry No. base offset passed from ParseBlobToItems()
        for i := 0 to ItemJSONBlob."No. of Items" - 1 do begin
            if JsonArr.Get(i, JsonToken) then begin
                ItemObj := JsonToken.AsObject();
                ParsedItemBuffer.Init();
                ParsedItemBuffer."Entry No." := StartIdx + i + 1;
                ParsedItemBuffer."Item No." := GetJsonText(ItemObj, 'No');
                ParsedItemBuffer.Description := GetJsonText(ItemObj, 'Description');
                ParsedItemBuffer."Unit Price" := GetJsonDecimal(ItemObj, 'UnitPrice');
                ParsedItemBuffer."Unit Cost" := GetJsonDecimal(ItemObj, 'UnitCost');
                ParsedItemBuffer.Inventory := GetJsonDecimal(ItemObj, 'Inventory');
                ParsedItemBuffer."Base Unit of Measure" := GetJsonText(ItemObj, 'BaseUnitOfMeasure');
                ParsedItemBuffer."Item Category Code" := GetJsonText(ItemObj, 'ItemCategoryCode');
                ParsedItemBuffer."Session No." := SessionNo;
                ParsedItemBuffer."Processed At" := CurrentDateTime();
                ParsedItemBuffer.Insert();
            end;
        end;

        Commit();
    end;

    local procedure GetJsonText(JsonObj: JsonObject; PropertyName: Text): Text
    var
        JsonToken: JsonToken;
    begin
        if JsonObj.Get(PropertyName, JsonToken) then
            exit(JsonToken.AsValue().AsText());
        exit('');
    end;

    local procedure GetJsonDecimal(JsonObj: JsonObject; PropertyName: Text): Decimal
    var
        JsonToken: JsonToken;
    begin
        if JsonObj.Get(PropertyName, JsonToken) then
            exit(JsonToken.AsValue().AsDecimal());
        exit(0);
    end;
}
