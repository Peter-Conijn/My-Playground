codeunit 50115 "Resource Pricing" implements "Line Type Pricing Data"
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
        PricingDataInterface.Initialize(99.00, 78.25, 5.00);

        exit(PricingDataInterface);
    end;
}
