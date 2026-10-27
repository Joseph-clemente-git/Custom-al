codeunit 70146 "MJS Customer Compl. Upgrade"
{
    Subtype = Upgrade;
    Permissions = tabledata Customer = RM;

    trigger OnUpgradePerCompany()
    begin
        DefaultComplianceCheckingToYes();
    end;

    // "Compliance Checking" is a new Boolean, so every customer created before
    // this version stores the SQL default of false. Left alone that would
    // silently exempt the whole customer base from the FDA/S License gate, so
    // existing customers are switched on once; turning one off afterwards is
    // an explicit decision the upgrade tag keeps from being undone.
    local procedure DefaultComplianceCheckingToYes()
    var
        Customer: Record Customer;
        UpgradeTag: Codeunit "Upgrade Tag";
    begin
        if UpgradeTag.HasUpgradeTag(GetComplianceCheckingDefaultTag()) then
            exit;

        Customer.SetRange("GMPI Compliance Checking", false);
        if not Customer.IsEmpty() then
            Customer.ModifyAll("GMPI Compliance Checking", true, false);

        UpgradeTag.SetUpgradeTag(GetComplianceCheckingDefaultTag());
    end;

    // Registering the tag means a brand new company starts already "upgraded"
    // and never has its customers rewritten.
    [EventSubscriber(ObjectType::Codeunit, Codeunit::"Upgrade Tag", 'OnGetPerCompanyUpgradeTags', '', false, false)]
    local procedure RegisterPerCompanyUpgradeTags(var PerCompanyUpgradeTags: List of [Code[250]])
    begin
        PerCompanyUpgradeTags.Add(GetComplianceCheckingDefaultTag());
    end;

    local procedure GetComplianceCheckingDefaultTag(): Code[250]
    begin
        exit('MJS-CustomerComplianceChecking-Default-20260921');
    end;
}
