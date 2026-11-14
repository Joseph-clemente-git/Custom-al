pageextension 70102 "MJS Whse. Pick Package" extends "Whse. Pick Subform"
{
    layout
    {
        addafter("Item No.")
        {
            // The shipping box the item is packed in on the pick's warehouse
            // shipment (GMPI 26.1.0.47). Not BC's Package No. (item
            // tracking: the package stock is taken from).
            field(MJSShippingPackages; ShippingPackages)
            {
                ApplicationArea = Warehouse;
                Caption = 'Shipping Package No.';
                Editable = false;
                ToolTip = 'Specifies the shipping package (box label) the item is packed in on the warehouse shipment. Set by Register Pick in the warehouse web app.';
            }
        }
    }
    var
        ShippingPackages: Text;

    trigger OnAfterGetRecord()
    var
        PickMgt: Codeunit "MJS Whse. Pick Mgt.";
    begin
        ShippingPackages := '';
        if Rec."Whse. Document Type" = Rec."Whse. Document Type"::Shipment then
            ShippingPackages := PickMgt.PackagesText(Rec."Whse. Document No.", Rec."Item No.", '');
    end;
}
