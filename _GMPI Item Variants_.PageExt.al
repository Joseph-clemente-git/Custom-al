#pragma warning disable AL0247
pageextension 70102 "GMPI Item Variants" extends "Item Variants"
#pragma warning restore AL0247
{
    layout
    {
        addlast(Control1)
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
