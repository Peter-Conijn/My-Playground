page 50180 "Parsed Items List"
{
    ApplicationArea = All;
    Caption = 'Parsed Items';
    PageType = List;
    SourceTable = "Parsed Item Buffer";
    UsageCategory = Lists;
    Editable = false;

    layout
    {
        area(Content)
        {
            repeater(Lines)
            {
                field("Entry No."; Rec."Entry No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Unique entry number. Equals the item''s position in the JSON array (1-based).';
                }
                field("Item No."; Rec."Item No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'The item number as extracted from the JSON blob.';
                }
                field(Description; Rec.Description)
                {
                    ApplicationArea = All;
                    ToolTip = 'Item description.';
                }
                field("Unit Price"; Rec."Unit Price")
                {
                    ApplicationArea = All;
                    ToolTip = 'Unit selling price of the item.';
                }
                field("Unit Cost"; Rec."Unit Cost")
                {
                    ApplicationArea = All;
                    ToolTip = 'Unit cost of the item.';
                }
                field(Inventory; Rec.Inventory)
                {
                    ApplicationArea = All;
                    ToolTip = 'Current inventory quantity.';
                }
                field("Base Unit of Measure"; Rec."Base Unit of Measure")
                {
                    ApplicationArea = All;
                    ToolTip = 'Base unit of measure for the item.';
                }
                field("Item Category Code"; Rec."Item Category Code")
                {
                    ApplicationArea = All;
                    ToolTip = 'Item category code.';
                }
                field("Session No."; Rec."Session No.")
                {
                    ApplicationArea = All;
                    ToolTip = 'Which session processed this record. 1/2/3 = parallel background session; 0 = sequential (no background sessions).';
                }
                field("Processed At"; Rec."Processed At")
                {
                    ApplicationArea = All;
                    ToolTip = 'Date and time when the background session inserted this record.';
                }
            }
        }
    }

    actions
    {
        area(Processing)
        {
            group(DataManagement)
            {
                Caption = 'Data Management';
                ToolTip = 'Actions to manage the blob and parsed data. Use these to test performance of the parsing and to clear data between tests.';
                action(ClearBlob)
                {
                    Caption = 'Clear Blob';
                    Image = Delete;
                    ApplicationArea = All;
                    ToolTip = 'Delete all records from the Item JSON Blob table.';

                    trigger OnAction()
                    var
                        ItemJSONBlob: Record "Item JSON Blob";
                    begin
                        if not Confirm('Are you sure you want to clear the blob data?') then
                            exit;
                        ItemJSONBlob.DeleteAll();
                        Message('Blob data cleared.');
                    end;
                }
                action(ClearBuffer)
                {
                    Caption = 'Clear Buffer';
                    Image = ClearLog;
                    ApplicationArea = All;
                    ToolTip = 'Delete all records from the Parsed Item Buffer table.';

                    trigger OnAction()
                    var
                        ParsedItemBuffer: Record "Parsed Item Buffer";
                    begin
                        if not Confirm('Are you sure you want to clear all parsed item records?') then
                            exit;

                        if not ParsedItemBuffer.Truncate(true) then
                            ParsedItemBuffer.DeleteAll();
                        CurrPage.Update(false);
                    end;
                }
                action(ExtractItemData)
                {
                    Caption = 'Extract Item Data';
                    Image = Export;
                    ApplicationArea = All;
                    ToolTip = 'Read all items and store them as a single JSON array in the Item JSON Blob table.';

                    trigger OnAction()
                    var
                        ItemJSONExtractor: Codeunit "Item JSON Extractor";
                    begin
                        ItemJSONExtractor.ExtractItemsToBlob();
                    end;
                }
                action(GenerateTestBlob)
                {
                    Caption = 'Generate Test Blob (100,000)';
                    Image = CreateDocument;
                    ApplicationArea = All;
                    ToolTip = 'Generate 100,000 synthetic items and store them as a JSON blob. No real Item records are created. Use this to produce a large dataset for performance testing.';

                    trigger OnAction()
                    var
                        ItemJSONExtractor: Codeunit "Item JSON Extractor";
                    begin
                        ItemJSONExtractor.GenerateTestBlob();
                    end;
                }
            }
            action(ParseAndImport)
            {
                Caption = 'Parse && Import (Parallel)';
                Image = Import;
                ApplicationArea = All;
                ToolTip = 'Clear the buffer table and spawn 3 background sessions that each parse their slice of the JSON blob in parallel. Use Show Parallel Timing once all records have appeared.';

                trigger OnAction()
                var
                    ItemJSONParser: Codeunit "Item JSON Parser";
                begin
                    ItemJSONParser.ParseBlobToItems();
                    CurrPage.Update(false);
                end;
            }
            group(Parsing)
            {
                Caption = 'Parsing Options';
                ToolTip = 'Parsing options. Use these to compare the performance of different parsing approaches.';

                action(ParseAndImportSequential)
                {
                    Caption = 'Parse && Import (Sequential)';
                    Image = ImportExport;
                    ApplicationArea = All;
                    ToolTip = 'Clear the buffer table and parse the JSON blob in a single sequential loop in the current session. Elapsed time is shown on completion.';

                    trigger OnAction()
                    var
                        ItemJSONParser: Codeunit "Item JSON Parser";
                    begin
                        ItemJSONParser.ParseBlobToItemsSequential();
                        CurrPage.Update(false);
                    end;
                }
                action(ShowParallelTiming)
                {
                    Caption = 'Show Parallel Timing';
                    Image = Clock;
                    ApplicationArea = All;
                    ToolTip = 'Show the wall-clock elapsed time of the last parallel parse, measured from session launch to the last recorded insert. Call this after all background sessions have finished.';

                    trigger OnAction()
                    var
                        ItemJSONParser: Codeunit "Item JSON Parser";
                    begin
                        ItemJSONParser.ShowParallelTiming();
                    end;
                }
            }
        }
        area(Promoted)
        {
            group(Category_DataManagement)
            {
                Caption = 'Data Management';
                actionref(GenerateTestBlob_Promoted; GenerateTestBlob) { }
                actionref(ExtractItemData_Promoted; ExtractItemData) { }
                actionref(ClearBlob_Promoted; ClearBlob) { }
                actionref(ClearBuffer_Promoted; ClearBuffer) { }
            }
            group(Category_Parsing)
            {
                Caption = 'Parsing';
                actionref(ParseAndImport_Promoted; ParseAndImport) { }
                actionref(ParseAndImportSequential_Promoted; ParseAndImportSequential) { }
                actionref(ShowParallelTiming_Promoted; ShowParallelTiming) { }
            }
        }
    }
}
