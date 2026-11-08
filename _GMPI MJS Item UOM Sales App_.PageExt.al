pageextension 70146 "MJS Item UOM Sales App" extends "Item Units of Measure"
{
    layout
    {
        addafter("Qty. per Unit of Measure")
        {
            field("MJS Sales App Applicable"; Rec."MJS Sales App Applicable")
            {
                ApplicationArea = All;
            }
        }
    }
}
