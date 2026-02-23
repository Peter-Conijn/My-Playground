codeunit 50114 "Sales Item Pricing" implements "Line Type Pricing Data"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    procedure GetPricingData(RecordVariant: Variant): Interface "Pricing Data"
    var
        PricingData: Codeunit "Pricing Data";
        PricingDataInterface: Interface "Pricing Data";
    begin
        PricingDataInterface := PricingData;
        PricingDataInterface.Initialize(10.00, 8.25, 2.00);

        exit(PricingDataInterface);
    end;
}