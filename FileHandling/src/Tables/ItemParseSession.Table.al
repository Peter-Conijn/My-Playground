table 50182 "Item Parse Session"
{
    Caption = 'Item Parse Session';
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Session No."; Integer)
        {
            Caption = 'Session No.';
        }
        field(2; "Start Index"; Integer)
        {
            Caption = 'Start Index';
        }
        field(3; "End Index"; Integer)
        {
            Caption = 'End Index';
        }
    }

    keys
    {
        key(PK; "Session No.")
        {
            Clustered = true;
        }
    }
}
