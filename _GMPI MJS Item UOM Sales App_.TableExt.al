tableextension 70146 "MJS Item UOM Sales App" extends "Item Unit of Measure"
{
    // Marks which of an item's Units of Measure may stay on a majesty-pharma-web
    // Sales Order line as entered. A unit left unchecked is converted to the
    // item's Sales Unit of Measure when the line is added, and the line is
    // refused unless that converts to a whole quantity (e.g. Sales UOM BOX =
    // 100 CAPSULE: 100 CAPSULE -> 1 BOX, 105 CAPSULE -> 1.05 BOX is refused).
    // Read through the itemUnitOfMeasures API (page 70118) as salesAppApplicable.
    fields
    {
        field(70146; "MJS Sales App Applicable"; Boolean)
        {
            Caption = 'Sales App Applicable';
            DataClassification = CustomerContent;
            ToolTip = 'Specifies whether this unit of measure can be used as entered on Sales App order lines. Otherwise the line is converted to the item''s Sales Unit of Measure.';
        }
    }
}
