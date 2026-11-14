tableextension 70101 "MJS Posted Shpt. Line Package" extends "Posted Whse. Shipment Line"
{
    // Same Field No. as the Warehouse Shipment Line extension (70100):
    // Whse.-Post Shipment copies it with TransferFields.
    fields
    {
        field(70100; "MJS Package No."; Code[50])
        {
            Caption = 'Shipping Package No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the shipping package (box label) that the item on this line was packed in.';
        }
    }
    keys
    {
        key(MJSPackageNo; "MJS Package No.") { }
    }
}
