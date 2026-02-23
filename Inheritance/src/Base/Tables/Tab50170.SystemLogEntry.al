table 50170 "System Log Entry"
{
    Caption = 'System Log Entry';
    DataClassification = ToBeClassified;

    fields
    {
        field(1; "Entry No."; Integer)
        {
            Caption = 'Entry No.';
            ToolTip = 'Specifies the value of the Entry No. field.', Comment = '%';
        }
        field(2; "Application ID"; Guid)
        {
            Caption = 'Application ID';
            ToolTip = 'Specifies the value of the Application ID field.', Comment = '%';
        }
        field(3; "Application Name"; Text[100])
        {
            Caption = 'Application Name';
            ToolTip = 'Specifies the value of the Application Name field.', Comment = '%';
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
