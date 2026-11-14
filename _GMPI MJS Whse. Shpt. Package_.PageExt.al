pageextension 70100 "MJS Whse. Shpt. Package" extends "Whse. Shipment Subform"
{
    layout
    {
        addafter("Item No.")
        {
            field("MJS Package No."; Rec."MJS Package No.")
            {
                ApplicationArea = Warehouse;
                Editable = false;
            }
        }
    }
}
