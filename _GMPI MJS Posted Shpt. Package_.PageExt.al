pageextension 70101 "MJS Posted Shpt. Package" extends "Posted Whse. Shipment Subform"
{
    layout
    {
        addafter("Item No.")
        {
            field("MJS Package No."; Rec."MJS Package No.")
            {
                ApplicationArea = Warehouse;
            }
        }
    }
}
