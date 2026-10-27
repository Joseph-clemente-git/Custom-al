#pragma warning disable AL0247
pageextension 70108 "GMPI Itm Avail.byVar.Lines" extends "Item Avail. by Variant Lines"
#pragma warning restore AL0247
{
    layout
    {
        addlast(Control1)
        {
            field(GMPIPrincipal; Rec."GMPI Principal")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the principal assigned to the item variant.';
            }
            field(GMPIBrand; Rec."GMPI Brand")
            {
                ApplicationArea = All;
                ToolTip = 'Specifies the brand assigned to the item.';
            }
        }
    }
}
