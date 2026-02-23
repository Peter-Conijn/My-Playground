codeunit 50113 "Pricing Model Factory"
{
    Access = Public;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure GetPricingModel(RecordVariant: Variant): Interface "Entity Pricing"
    var
        SalesPricing: Codeunit "Sales Pricing";
        RecordRef: RecordRef;
        InvalidTypeErr: Label 'Invalid record variant passed to pricing model.';
    begin
        if not RecordVariant.IsRecord() then
            Error(InvalidTypeErr);

        RecordRef.GetTable(RecordVariant);
        case RecordRef.Number of
            Database::"Sales Line":
                exit(SalesPricing);
            else
                Error(InvalidTypeErr);
        end;
    end;


}
