codeunit 50112 "Sales Pricing" implements "Entity Pricing"
{

    procedure GetEntityPricing(RecordVariant: Variant): Interface "Pricing Data"
    var
        SalesLine: Record "Sales Line";
        RecordRef: RecordRef;
    begin
        RecordRef.GetTable(RecordVariant);
        if RecordRef.Number <> Database::"Sales Line" then
            Error('Invalid record variant passed to sales pricing model.');
        RecordRef.SetTable(SalesLine);

        exit(ImplementLineTypePricingData(SalesLine.Type).GetPricingData(SalesLine));
    end;

    local procedure ImplementLineTypePricingData(Type: Enum "Sales Line Type"): Interface "Line Type Pricing Data"
    var
        SalesItemPricing: Codeunit "Sales Item Pricing";
        ResourcePricing: Codeunit "Resource Pricing";
    begin
        case Type of
            Enum::"Sales Line Type"::Item:
                exit(SalesItemPricing);
            Enum::"Sales Line Type"::Resource:
                exit(ResourcePricing);
            else
                Error('No pricing implementation for this line type');
        end;
    end;

}
