page 50170 "System Log Entries"
{
    ApplicationArea = All;
    Caption = 'System Log Entries';
    PageType = List;
    SourceTable = "System Log Entry";
    UsageCategory = Lists;
    Editable = false;
    CardPageId = "System Log Entry";

    layout
    {
        area(Content)
        {
            repeater(General)
            {
                field("Entry No."; Rec."Entry No.")
                {
                }
                field("Application ID"; Rec."Application ID")
                {
                }
                field("Application Name"; Rec."Application Name")
                {
                }
            }
        }
    }
}
