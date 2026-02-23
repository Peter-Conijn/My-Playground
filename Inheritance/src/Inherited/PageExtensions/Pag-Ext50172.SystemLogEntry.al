pageextension 50172 "System Log Entry" extends "System Log Entry"
{
    layout
    {
        addlast(General)
        {
            field("Application Version"; Rec."Application Version")
            {
                ApplicationArea = All;
            }
        }
    }
}
