pageextension 50171 "System Log Entries" extends "System Log Entries"
{
    layout
    {
        addafter("Application ID")
        {
            field("Application Version"; Rec."Application Version")
            {
                ApplicationArea = All;
            }
        }
    }
}
