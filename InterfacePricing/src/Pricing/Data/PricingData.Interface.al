interface "Pricing Data"
{
    Access = Public;

    procedure Initialize(UnitPrice: Decimal; UnitCost: Decimal; LineDiscountPercent: Decimal);

    procedure GetUnitPrice(): Decimal;

    procedure GetUnitCost(): Decimal;

    procedure GetLineDiscountPercent(): Decimal;
}
