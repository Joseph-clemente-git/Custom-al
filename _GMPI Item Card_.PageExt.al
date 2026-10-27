#pragma warning disable AL0247
pageextension 70107 "GMPI Item Card" extends "Item Card"
#pragma warning restore AL0247
{
    layout
    {
        addlast(Item)
        {
            field(GMPIPrincipal; Rec."GMPI Principal")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the principal assigned to the item.';
            }
            field(GMPIBrand; Rec."GMPI Brand")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the brand assigned to the item.';
            }
        }
    }
}
