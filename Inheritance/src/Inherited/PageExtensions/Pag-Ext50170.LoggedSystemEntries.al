pageextension 50170 "Logged System Entries" extends "Logged System Entries"
{
    layout
    {
        addafter("Application Name")
        {
            field("Application Version"; Rec."Application Version")
            {
                ApplicationArea = All;
            }
        }
    }
}