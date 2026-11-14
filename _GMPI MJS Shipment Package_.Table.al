table 70100 "MJS Shipment Package"
{
    // Custom (GMPI 26.1.0.45): how much of an item on a warehouse shipment is
    // packed in each shipping box. One item can be split across boxes. Set by
    // Register Pick from the web app's Checking page. Keyed by the Whse.
    // Shipment No., so the rows stay valid after Whse.-Post Shipment (the
    // posted lines keep "Whse. Shipment No.").
    Caption = 'Shipment Package';
    DataClassification = CustomerContent;

    fields
    {
        field(1; "Whse. Shipment No."; Code[20])
        {
            Caption = 'Whse. Shipment No.';
        }
        field(2; "Item No."; Code[20])
        {
            Caption = 'Item No.';
        }
        field(3; "Package No."; Code[50])
        {
            Caption = 'Shipping Package No.';
        }
        field(4; Quantity; Decimal)
        {
            Caption = 'Quantity';
            DecimalPlaces = 0 : 5;
        }
    }
    keys
    {
        key(PK; "Whse. Shipment No.", "Item No.", "Package No.")
        {
            Clustered = true;
        }
        key(PackageNo; "Package No.") { }
    }
}
