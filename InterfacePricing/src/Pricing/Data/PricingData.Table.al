table 50110 "Pricing Data"
{
    Caption = 'Pricing Data';
    DataClassification = CustomerContent;
    TableType = Temporary;
    InherentEntitlements = RIMDX;
    InherentPermissions = RIMDX;

    fields
    {
        field(1; ID; Guid)
        {
            Caption = 'ID';
        }
        field(2; "Unit Price"; Decimal)
        {
            Caption = 'Unit Price';
        }
        field(3; "Unit Cost"; Decimal)
        {
            Caption = 'Unit Cost';
        }
        field(4; "Line Discount %"; Decimal)
        {
            Caption = 'Line Discount %';
        }
    }
    keys
    {
        key(PK; ID)
        {
            Clustered = true;
        }
    }
}
