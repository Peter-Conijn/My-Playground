page 50171 "Logged System Entries"
{
    ApplicationArea = All;
    Caption = 'Logged System Entries';
    PageType = ListPart;
    SourceTable = "System Log Entry";

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
