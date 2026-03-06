pageextension 50150 "Sales Order" extends "Sales Order"
{
    layout
    {
        addlast(General)
        {
            field("User Phone No."; Rec."User Phone No.")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the phone number of the user who created the sales order.';
            }
        }
    }
}
