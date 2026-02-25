codeunit 50180 "Item JSON Extractor"
{
    /// <summary>
    /// Reads all Item records, serialises the extended fields into a JSON array,
    /// and stores the result as a single Blob record in the "Item JSON Blob" table.
    /// Any existing blob record is deleted first.
    /// </summary>
    procedure ExtractItemsToBlob()
    var
        Item: Record Item;
        ItemJSONBlob: Record "Item JSON Blob";
        JsonArr: JsonArray;
        ItemObj: JsonObject;
        JsonText: Text;
        OutStr: OutStream;
        ItemCount: Integer;
    begin
        ItemJSONBlob.DeleteAll();

        if Item.FindSet() then
            repeat
                Clear(ItemObj);
                ItemObj.Add('No', Item."No.");
                ItemObj.Add('Description', Item.Description);
                ItemObj.Add('UnitPrice', Item."Unit Price");
                ItemObj.Add('UnitCost', Item."Unit Cost");
                ItemObj.Add('Inventory', Item.Inventory);
                ItemObj.Add('BaseUnitOfMeasure', Item."Base Unit of Measure");
                ItemObj.Add('ItemCategoryCode', Item."Item Category Code");
                JsonArr.Add(ItemObj);
                ItemCount += 1;
            until Item.Next() = 0;

        JsonArr.WriteTo(JsonText);

        ItemJSONBlob.Init();
        ItemJSONBlob."Entry No." := 1;
        ItemJSONBlob.Description := 'Items export';
        ItemJSONBlob."No. of Items" := ItemCount;
        ItemJSONBlob."Created At" := CurrentDateTime();
        ItemJSONBlob."JSON Data".CreateOutStream(OutStr, TextEncoding::UTF8);
        OutStr.WriteText(JsonText);
        ItemJSONBlob.Insert();

        Commit();
        Message('Extracted %1 items to blob.', ItemCount);
    end;

    /// <summary>
    /// Generates 100,000 synthetic item records split across 5 blob records
    /// (20,000 items each) in the "Item JSON Blob" table so that each background
    /// session only needs to read and parse its own 1/5 of the data.
    /// No real Item records are created.
    /// </summary>
    procedure GenerateTestBlob()
    var
        ItemJSONBlob: Record "Item JSON Blob";
        JsonArr: JsonArray;
        ItemObj: JsonObject;
        JsonText: Text;
        OutStr: OutStream;
        i: Integer;
        SessionNo: Integer;
        TotalSessions: Integer;
        ItemsPerSession: Integer;
        BaseIndex: Integer;
        AbsoluteIndex: Integer;
        Categories: array[5] of Text;
        UoMs: array[3] of Text;
        CreatedAt: DateTime;
    begin
        TotalSessions := 5;
        ItemsPerSession := 20000;
        Categories[1] := 'ELECTRONICS';
        Categories[2] := 'FURNITURE';
        Categories[3] := 'CLOTHING';
        Categories[4] := 'FOOD';
        Categories[5] := 'TOOLS';
        UoMs[1] := 'PCS';
        UoMs[2] := 'BOX';
        UoMs[3] := 'KG';

        ItemJSONBlob.DeleteAll();
        CreatedAt := CurrentDateTime();

        for SessionNo := 1 to TotalSessions do begin
            Clear(JsonArr);
            BaseIndex := (SessionNo - 1) * ItemsPerSession;

            for i := 1 to ItemsPerSession do begin
                AbsoluteIndex := BaseIndex + i;
                Clear(ItemObj);
                ItemObj.Add('No', 'TEST-' + Format(AbsoluteIndex, 0, '<Integer,6><Filler,0>'));
                ItemObj.Add('Description', 'Test Item ' + Format(AbsoluteIndex, 0, '<Integer,6><Filler,0>'));
                ItemObj.Add('UnitPrice', (AbsoluteIndex mod 900) + 10 + ((AbsoluteIndex mod 99) / 100));
                ItemObj.Add('UnitCost', ((AbsoluteIndex mod 900) + 10 + ((AbsoluteIndex mod 99) / 100)) * 0.6);
                ItemObj.Add('Inventory', (AbsoluteIndex mod 500));
                ItemObj.Add('BaseUnitOfMeasure', UoMs[(AbsoluteIndex mod 3) + 1]);
                ItemObj.Add('ItemCategoryCode', Categories[(AbsoluteIndex mod 5) + 1]);
                JsonArr.Add(ItemObj);
            end;

            JsonArr.WriteTo(JsonText);

            ItemJSONBlob.Init();
            ItemJSONBlob."Entry No." := SessionNo;
            ItemJSONBlob.Description := StrSubstNo('Session %1 (%2 items)', SessionNo, ItemsPerSession);
            ItemJSONBlob."No. of Items" := ItemsPerSession;
            ItemJSONBlob."Created At" := CreatedAt;
            ItemJSONBlob."JSON Data".CreateOutStream(OutStr, TextEncoding::UTF8);
            OutStr.WriteText(JsonText);
            ItemJSONBlob.Insert();
        end;

        Commit();
        Message('Generated %1 synthetic items across %2 blob records (%3 items each).',
            TotalSessions * ItemsPerSession, TotalSessions, ItemsPerSession);
    end;
}
