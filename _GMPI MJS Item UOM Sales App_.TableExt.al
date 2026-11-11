tableextension 70146 "MJS Item UOM Sales App" extends "Item Unit of Measure"
{
    // Rolled back in 26.1.0.39: the Sales App Applicable flag is no longer
    // shown on Item Units of Measure or returned by the itemUnitOfMeasures API
    // (page 70118). The field is kept as obsolete instead of deleted because
    // 26.1.0.38 already created it in the database, and removing a table
    // extension field is a destructive schema change BC will not sync.
    fields
    {
        field(70146; "MJS Sales App Applicable"; Boolean)
        {
            Caption = 'Sales App Applicable';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether this unit of measure can be used as entered on Sales App order lines. Otherwise the line is converted to the item''s Sales Unit of Measure.';
            ObsoleteState = Pending;
            ObsoleteReason = 'Sales App UOM rule rolled back; field is no longer used.';
            ObsoleteTag = '26.1.0.39';
        }
    }
}
