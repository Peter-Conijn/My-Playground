codeunit 50111 "Pricing Data" implements "Pricing Data"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        GlobalPricingData: Record "Pricing Data";
        Initialized: Boolean;

    procedure Initialize(UnitPrice: Decimal; UnitCost: Decimal; LineDiscountPercent: Decimal)
    begin
        if IsInitialized() then
            this.Clear();

        GlobalPricingData.Init();
        GlobalPricingData."Unit Price" := UnitPrice;
        GlobalPricingData."Unit Cost" := UnitCost;
        GlobalPricingData."Line Discount %" := LineDiscountPercent;
        GlobalPricingData.Insert();

        SetInitialized(true);
    end;

    procedure GetUnitPrice(): Decimal
    begin
        CheckInitialized();
        exit(GlobalPricingData."Unit Price");
    end;

    procedure GetUnitCost(): Decimal
    begin
        CheckInitialized();
        exit(GlobalPricingData."Unit Cost");
    end;

    procedure GetLineDiscountPercent(): Decimal
    begin
        CheckInitialized();
        exit(GlobalPricingData."Line Discount %");
    end;

    local procedure Clear()
    begin
        SetInitialized(false);
        ClearAll();
    end;


    local procedure SetInitialized(NewInitialized: Boolean)
    begin
        this.Initialized := NewInitialized;
    end;

    local procedure IsInitialized(): Boolean
    begin
        exit(this.Initialized);
    end;

    local procedure CheckInitialized()
    var
        InitializedErr: Label 'Pricing data is not initialized.';
    begin
        if not IsInitialized() then
            Error(InitializedErr);
    end;
}
