table 50180 "Item JSON Blob"
{
    Caption = 'Item JSON Blob';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            DataClassification = SystemMetadata;
        }
        field(2; Description; Text[100])
        {
            Caption = 'Description';
            DataClassification = CustomerContent;
        }
        field(3; "JSON Data"; Blob)
        {
            Caption = 'JSON Data';
        }
        field(4; "No. of Items"; Integer)
        {
            Caption = 'No. of Items';
            DataClassification = SystemMetadata;
        }
        field(5; "Created At"; DateTime)
        {
            Caption = 'Created At';
            DataClassification = SystemMetadata;
        }
        field(6; "Parse Started At"; DateTime)
        {
            Caption = 'Parse Started At';
            DataClassification = SystemMetadata;
        }
    }

    keys
    {
        key(PK; "Entry No.")
        {
            Clustered = true;
        }
    }
}
