pageextension 50110 "Sales Order Subpage" extends "Sales Order Subform"
{
    actions
    {
        addfirst(processing)
        {
            action(GetPricingDetails)
            {
                ApplicationArea = All;
                Caption = 'Get Pricing Details';
                ToolTip = 'Retrieve and display pricing details for the selected sales line.';
                Image = Price;

                trigger OnAction()
                var
                    PricingModelFactory: Codeunit "Pricing Model Factory";
                    PriceDataTxt: Label 'Price Data:\Unit Price: %1\Unit Cost: %2\Line Discount: %3';
                    PricingData: Interface "Pricing Data";
                begin
                    PricingData := PricingModelFactory.GetPricingModel(Rec).GetEntityPricing(Rec);
                    Message(PriceDataTxt, PricingData.GetUnitPrice(), PricingData.GetUnitCost(), PricingData.GetLineDiscountPercent());
                end;
            }
        }
    }
}
