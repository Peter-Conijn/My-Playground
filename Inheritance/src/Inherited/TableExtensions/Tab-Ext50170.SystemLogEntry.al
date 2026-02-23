tableextension 50170 "System Log Entry" extends "System Log Entry"
{
    fields
    {
        field(50170; "Application Version"; Text[10])
        {
            Caption = 'Application Version';
            DataClassification = SystemMetadata;
            ToolTip = 'Specifies the application version of the system log entry.';
        }
    }
}
