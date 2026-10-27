codeunit 70140 "MJS Location Dim. Upgrade"
{
    Subtype = Upgrade;
    Permissions = tabledata "Default Dimension" = RM;

    trigger OnUpgradePerCompany()
    begin
        RelaxGmpiBranchValuePosting();
    end;

    local procedure RelaxGmpiBranchValuePosting()
    var
        DefaultDimension: Record "Default Dimension";
    begin
        // MAIN is an accounting BRANCH value, not a Location Code. A transfer
        // leaving GMPI can legitimately carry its destination branch (for
        // example ILOILO), so requiring the source location's exact default
        // value makes Business Central reject otherwise valid shipments.
        if not DefaultDimension.Get(Database::Location, 'GMPI', 'BRANCH') then
            exit;
        if DefaultDimension."Value Posting" <> DefaultDimension."Value Posting"::"Same Code" then
            exit;

        DefaultDimension.Validate("Value Posting", DefaultDimension."Value Posting"::"Code Mandatory");
        DefaultDimension.Modify(true);
    end;
}
