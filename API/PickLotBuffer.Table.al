table 70104 "MJS Pick Lot Buffer"
{
    // One row of BC's Item Tracking Summary (Lot No. lookup) for a pick line,
    // in the line's unit of measure. Filled per request by the MJS Pick Lot
    // API page; never stored.
    Caption = 'Pick Lot Buffer';
    TableType = Temporary;
    DataClassification = SystemMetadata;

    fields
    {
        field(1; "Pick No."; Code[20])
        {
            Caption = 'Pick No.';
        }
        field(2; "Pick Line No."; Integer)
        {
            Caption = 'Pick Line No.';
        }
        field(3; "Lot No."; Code[50])
        {
            Caption = 'Lot No.';
        }
        field(4; "Expiration Date"; Date)
        {
            Caption = 'Expiration Date';
        }
        field(5; "Total Quantity"; Decimal)
        {
            Caption = 'Total Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(6; "Available Quantity"; Decimal)
        {
            Caption = 'Available Quantity';
            DecimalPlaces = 0 : 5;
        }
        field(7; "Unit of Measure Code"; Code[10])
        {
            Caption = 'Unit of Measure Code';
        }
        field(8; "Bin Code"; Code[20])
        {
            Caption = 'Bin Code';
        }
    }

    keys
    {
        key(PK; "Pick No.", "Pick Line No.", "Lot No.")
        {
            Clustered = true;
        }
    }
}
