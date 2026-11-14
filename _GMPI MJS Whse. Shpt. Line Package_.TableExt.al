tableextension 70100 "MJS Whse. Shpt. Line Package" extends "Warehouse Shipment Line"
{
    // Custom (GMPI 26.1.0.44): the shipping box the line's item is packed in,
    // set by Register Pick from the web app's Checking page and scanned at
    // Dispatch. Not BC's Package No. (item tracking, field 6515): that one
    // says which package stock is taken from. Field No. must match the Posted
    // Whse. Shipment Line extension, so Whse.-Post Shipment's TransferFields
    // copies it to the posted line.
    fields
    {
        field(70100; "MJS Package No."; Code[50])
        {
            Caption = 'Shipping Package No.';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies the shipping package (box label) that the item on this line is packed in. Set by Register Pick in the warehouse web app.';
        }
    }
    keys
    {
        key(MJSPackageNo; "MJS Package No.") { }
    }
}
