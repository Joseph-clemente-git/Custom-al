#pragma warning disable AL0247
pageextension 70101 "GMPI Item Variant Card" extends "Item Variant Card"
#pragma warning restore AL0247
{
    layout
    {
        addlast(ItemVariant)
        {
            field(GMPIBrand; Rec."GMPI Brand")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the brand assigned to the item variant.';
            }
            field(GMPIPrincipal; Rec."GMPI Principal")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the principal assigned to the item variant.';
            }
        }
    }
}
